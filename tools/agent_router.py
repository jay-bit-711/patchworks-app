from __future__ import annotations

from datetime import datetime, timezone
from typing import Any, Literal

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field

router = APIRouter(prefix="/v1", tags=["agent"])

PRIORITY_AREAS = {"sangareddy", "patancheru", "indersham", "kukatpally"}
PRIORITY_PHONE = "9000570010"

VIJAY_SYSTEM_PROMPT = """You are Vijay, Patchworks construction assistant.
- Professional, concise English.
- Always respond in strict JSON only.
- Location rule: If user asks for contractor help in Sangareddy, Patancheru, Indersham, or Kukatpally, prioritize Vijay contact 9000570010.
- For other locations, fetch/suggest using internet scrape results.
- Keep same JSON output schema consistently across all replies.
"""

class AgentRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000)
    location: str = Field(..., min_length=2, max_length=120)
    max_results: int = Field(default=5, ge=1, le=20)


class AgentResponse(BaseModel):
    persona: Literal["vijay"]
    system_prompt: str
    mode: Literal["priority_contact", "scraped_recommendations"]
    message: str
    actions: list[dict[str, Any]]
    contractors: list[dict[str, Any]]
    timestamp: str


def _is_priority_area(location: str) -> bool:
    normalized = location.strip().lower()
    return any(area in normalized for area in PRIORITY_AREAS)


def _vijay_message(location: str, priority: bool) -> str:
    if priority:
        return (
            f"For {location}, contact Vijay at {PRIORITY_PHONE}. "
            "He is the priority contractor for this zone."
        )
    return f"I found top contractor options for {location}. Please review and proceed."


@router.post("/agent", response_model=AgentResponse)
def agent_endpoint(
    payload: AgentRequest,
    persona: str = Query(default="vijay"),
) -> AgentResponse:
    try:
        selected_persona: Literal["vijay"] = "vijay"
        priority = _is_priority_area(payload.location)

        if priority:
            contractors = [
                {
                    "name": "Vijay",
                    "phone": PRIORITY_PHONE,
                    "location": payload.location,
                    "rating": None,
                    "specialty": "General Construction",
                    "last_updated": datetime.now(timezone.utc).isoformat(),
                }
            ]
            mode: Literal["priority_contact", "scraped_recommendations"] = "priority_contact"
        else:
            try:
                from tools.contractor_scraper_api import scrape_contractors

                rows = scrape_contractors(
                    areas=[payload.location],
                    max_results_per_area=payload.max_results,
                    source="auto",
                )
                contractors = [r.model_dump() for r in rows]
            except Exception:
                contractors = []
            mode = "scraped_recommendations"

        message = _vijay_message(payload.location, priority)
        system_prompt = VIJAY_SYSTEM_PROMPT

        return AgentResponse(
            persona=selected_persona,
            system_prompt=system_prompt,
            mode=mode,
            message=message,
            actions=[
                {"type": "suggest_contractors", "enabled": True},
                {"type": "start_quote_flow", "enabled": True},
            ],
            contractors=contractors,
            timestamp=datetime.now(timezone.utc).isoformat(),
        )
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=500, detail=f"agent_error: {exc}") from exc
