"""
Standalone contractor scraper + FastAPI endpoint.

Environment variables:
  SUPABASE_URL=<your-supabase-url>
  SUPABASE_KEY=<your-supabase-service-or-anon-key>
  SUPABASE_TABLE=contractors
  SERPAPI_API_KEY=<optional-serpapi-key>
"""

from __future__ import annotations

import logging
import os
import re
import time
from datetime import datetime, timezone
from typing import Any

import requests
from bs4 import BeautifulSoup
from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel, Field
from supabase import Client, create_client

try:
    from slowapi import Limiter, _rate_limit_exceeded_handler
    from slowapi.errors import RateLimitExceeded
    from slowapi.util import get_remote_address

    SLOWAPI_AVAILABLE = True
except Exception:  # noqa: BLE001
    SLOWAPI_AVAILABLE = False

    class RateLimitExceeded(Exception):
        pass

    def get_remote_address(_: Request) -> str:
        return "unknown"

    class Limiter:  # type: ignore[override]
        def __init__(self, key_func: Any | None = None) -> None:
            self.key_func = key_func

        def limit(self, _: str) -> Any:
            def decorator(func: Any) -> Any:
                return func

            return decorator

    def _rate_limit_exceeded_handler(request: Request, exc: Exception) -> Any:  # noqa: ARG001
        return {"detail": "rate limit exceeded"}

logger = logging.getLogger("contractor_scraper")
logging.basicConfig(level=logging.INFO)

PRIORITY_PHONE = "9000570010"
DEFAULT_AREAS = ["Kukatpally", "Patancheru"]
PHONE_PATTERN = re.compile(r"(?:\+91[-\s]?)?[6-9]\d{9}")


class ScrapeRequest(BaseModel):
    areas: list[str] = Field(default_factory=lambda: DEFAULT_AREAS.copy())
    max_results_per_area: int = 10
    source: str = "auto"  # auto | serpapi | duckduckgo


class ScrapedContractor(BaseModel):
    name: str
    phone: str
    location: str
    rating: float | None = None
    specialty: str | None = None
    last_updated: str


def normalize_phone(phone: str) -> str:
    digits = re.sub(r"\D", "", phone)
    if digits.startswith("91") and len(digits) == 12:
        digits = digits[2:]
    return digits


def extract_phone(text: str) -> str | None:
    match = PHONE_PATTERN.search(text or "")
    if not match:
        return None
    return normalize_phone(match.group(0))


def ddg_search(query: str, timeout: int = 20) -> list[dict[str, Any]]:
    """
    Use DuckDuckGo HTML endpoint to get top links.
    """
    url = "https://html.duckduckgo.com/html/"
    resp = requests.get(url, params={"q": query}, timeout=timeout)
    resp.raise_for_status()
    soup = BeautifulSoup(resp.text, "html.parser")
    results: list[dict[str, Any]] = []
    for a in soup.select("a.result__a"):
        href = a.get("href")
        name = a.get_text(" ", strip=True)
        if href and name:
            results.append({"name": name, "link": href})
    return results


def scrape_phone_from_page(url: str, timeout: int = 20) -> str | None:
    try:
        resp = requests.get(url, timeout=timeout, headers={"User-Agent": "Mozilla/5.0"})
        resp.raise_for_status()
        phone = extract_phone(resp.text)
        return phone
    except Exception as exc:  # noqa: BLE001
        logger.warning("Phone scrape failed for %s: %s", url, exc)
        return None


def scrape_from_duckduckgo(area: str, max_results: int) -> list[ScrapedContractor]:
    query = f"top rated construction contractors in {area} Hyderabad phone rating"
    raw = ddg_search(query)
    out: list[ScrapedContractor] = []
    for item in raw[:max_results]:
        phone = scrape_phone_from_page(item["link"]) or ""
        if not phone:
            continue
        out.append(
            ScrapedContractor(
                name=item["name"][:180],
                phone=phone,
                location=area,
                rating=None,
                specialty="General Construction",
                last_updated=datetime.now(timezone.utc).isoformat(),
            )
        )
        time.sleep(0.2)
    return out


def scrape_from_serpapi(area: str, max_results: int, api_key: str) -> list[ScrapedContractor]:
    params = {
        "engine": "google_local",
        "q": f"top rated construction contractors in {area}, Hyderabad",
        "location": f"{area}, Hyderabad, Telangana, India",
        "hl": "en",
        "gl": "in",
        "api_key": api_key,
    }
    resp = requests.get("https://serpapi.com/search.json", params=params, timeout=25)
    resp.raise_for_status()
    payload = resp.json()
    local_results = payload.get("local_results", [])[:max_results]

    out: list[ScrapedContractor] = []
    for item in local_results:
        raw_phone = item.get("phone") or ""
        phone = normalize_phone(raw_phone) if raw_phone else ""
        if not phone:
            continue

        rating_value = item.get("rating")
        rating = None
        try:
            if rating_value is not None:
                rating = float(rating_value)
        except (TypeError, ValueError):
            rating = None

        specialty = item.get("type") or item.get("category") or "General Construction"
        out.append(
            ScrapedContractor(
                name=(item.get("title") or "Unknown Contractor")[:180],
                phone=phone,
                location=(item.get("address") or area)[:180],
                rating=rating,
                specialty=specialty[:180],
                last_updated=datetime.now(timezone.utc).isoformat(),
            )
        )
    return out


def prioritize_phone(records: list[ScrapedContractor], priority_phone: str = PRIORITY_PHONE) -> list[ScrapedContractor]:
    priority_phone = normalize_phone(priority_phone)
    return sorted(records, key=lambda r: 0 if normalize_phone(r.phone) == priority_phone else 1)


def dedupe_records(records: list[ScrapedContractor]) -> list[ScrapedContractor]:
    seen: set[tuple[str, str]] = set()
    deduped: list[ScrapedContractor] = []
    for r in records:
        key = (r.name.strip().lower(), normalize_phone(r.phone))
        if key in seen:
            continue
        seen.add(key)
        deduped.append(r)
    return deduped


def get_supabase_client() -> tuple[Client, str]:
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    table = os.getenv("SUPABASE_TABLE", "contractors")
    if not url or not key:
        raise RuntimeError("Missing SUPABASE_URL or SUPABASE_KEY.")
    return create_client(url, key), table


def save_to_supabase(records: list[ScrapedContractor]) -> int:
    if not records:
        return 0
    client, table = get_supabase_client()
    payload = [r.model_dump() for r in records]
    client.table(table).upsert(payload).execute()
    return len(payload)


def scrape_contractors(areas: list[str], max_results_per_area: int, source: str) -> list[ScrapedContractor]:
    all_rows: list[ScrapedContractor] = []
    serpapi_key = os.getenv("SERPAPI_API_KEY")

    for area in areas:
        area = area.strip()
        if not area:
            continue

        try:
            if source == "serpapi" or (source == "auto" and serpapi_key):
                if not serpapi_key:
                    raise RuntimeError("SERPAPI_API_KEY is required when source='serpapi'.")
                area_rows = scrape_from_serpapi(area, max_results_per_area, serpapi_key)
            elif source in {"duckduckgo", "auto"}:
                area_rows = scrape_from_duckduckgo(area, max_results_per_area)
            else:
                raise ValueError("Invalid source. Use one of: auto, serpapi, duckduckgo.")
        except Exception as exc:  # noqa: BLE001
            logger.exception("Scrape failed for area %s", area)
            raise RuntimeError(f"Scraping failed for '{area}': {exc}") from exc

        all_rows.extend(area_rows)
        time.sleep(0.5)

    all_rows = dedupe_records(all_rows)
    return prioritize_phone(all_rows)


limiter = Limiter(key_func=get_remote_address)
app = FastAPI(title="Contractor Scraper API", version="1.0.0")
app.state.limiter = limiter
if SLOWAPI_AVAILABLE:
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
else:
    logger.warning("slowapi is not installed; rate limiting is disabled for scraper API.")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


@app.post("/scrape-contractors")
@limiter.limit("5/minute")
def scrape_contractors_endpoint(request: Request, body: ScrapeRequest) -> dict[str, Any]:
    try:
        rows = scrape_contractors(
            areas=body.areas,
            max_results_per_area=max(1, min(body.max_results_per_area, 20)),
            source=body.source.lower().strip(),
        )
        saved = save_to_supabase(rows)
        return {
            "success": True,
            "scraped": len(rows),
            "saved": saved,
            "priority_phone": PRIORITY_PHONE,
            "records": [r.model_dump() for r in rows],
        }
    except ValueError as exc:
        raise HTTPException(status_code=400, detail=str(exc)) from exc
    except RuntimeError as exc:
        raise HTTPException(status_code=500, detail=str(exc)) from exc
    except Exception as exc:  # noqa: BLE001
        logger.exception("Unexpected error during scrape")
        raise HTTPException(status_code=500, detail=f"Unexpected error: {exc}") from exc


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("tools.contractor_scraper_api:app", host="0.0.0.0", port=8000, reload=True)
