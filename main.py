import argparse
import fcntl
import logging
import os
import socket
import struct
from contextlib import asynccontextmanager
from datetime import datetime, timezone

from dotenv import load_dotenv
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from tools.agent_router import router

logger = logging.getLogger("patchworks.main")
logging.basicConfig(level=logging.INFO)


def _ip_from_interface(interface_name: str) -> str | None:
    """Return IPv4 for a network interface name, if available."""
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        packed = struct.pack("256s", interface_name.encode("utf-8")[:15])
        result = fcntl.ioctl(sock.fileno(), 0x8915, packed)  # SIOCGIFADDR
        return socket.inet_ntoa(result[20:24])
    except OSError:
        return None
    finally:
        sock.close()


def detect_local_ip() -> str:
    # 1) Preferred interfaces for phone-visible local network.
    for iface in ["en0", "bridge100"]:
        iface_ip = _ip_from_interface(iface)
        if iface_ip and not iface_ip.startswith("127."):
            return iface_ip

    # 2) Any available interface.
    try:
        for _, iface_name in socket.if_nameindex():
            iface_ip = _ip_from_interface(iface_name)
            if iface_ip and not iface_ip.startswith("127."):
                return iface_ip
    except OSError:
        pass

    # 3) UDP route fallback (usually resolves Wi-Fi/LAN address).
    try:
        probe = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        probe.connect(("8.8.8.8", 80))
        routed_ip = probe.getsockname()[0]
        probe.close()
        if routed_ip:
            return routed_ip
    except OSError:
        pass

    return "127.0.0.1"


@asynccontextmanager
async def lifespan(app: FastAPI):
    load_dotenv()
    app.state.local_ip = detect_local_ip()

    logger.info("Patchworks Agent Server ready")
    logger.info("Phone / Mobile App URL: http://%s:8000/", app.state.local_ip)
    logger.info("In your Patchworks mobile app set base URL to this IP:port")
    logger.info(
        "Test message: POST /v1/agent?persona=vijay with "
        "{message: 'Need masons in Patancheru', location: 'Patancheru', max_results: 5}"
    )
    logger.info("No browser needed - open your Patchworks app on phone now")
    yield


app = FastAPI(title="Patchworks Agent API", version="1.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router)


@app.middleware("http")
async def api_key_middleware(request: Request, call_next):
    api_key = request.headers.get("X-API-Key")
    expected = os.getenv("PATCHWORKS_API_KEY", "test123")
    enforce = os.getenv("ENFORCE_API_KEY", "false").lower() == "true"

    if api_key != expected:
        logger.warning(
            "API key missing/invalid path=%s ip=%s",
            request.url.path,
            request.client.host if request.client else "unknown",
        )
        if enforce:
            return JSONResponse(status_code=401, content={"detail": "Invalid API key"})

    return await call_next(request)


@app.middleware("http")
async def access_log_middleware(request: Request, call_next):
    response = await call_next(request)
    logger.info(
        "request ip=%s path=%s status=%s",
        request.client.host if request.client else "unknown",
        request.url.path,
        response.status_code,
    )
    return response


@app.get("/")
def root() -> dict[str, str]:
    return {"status": "Patchworks Agent ready — Vijay online"}


@app.get("/test")
def test(request: Request) -> dict[str, str]:
    client_host = request.client.host if request.client else "unknown"
    return {"test": "alive", "ip": client_host}


@app.get("/health")
def health(request: Request) -> dict[str, str]:
    client_host = request.client.host if request.client else "unknown"
    return {
        "status": "healthy",
        "server_time": datetime.now(timezone.utc).isoformat(),
        "ip": client_host,
    }


if __name__ == "__main__":
    import uvicorn

    parser = argparse.ArgumentParser(description="Patchworks Agent API")
    parser.add_argument("--host", default="0.0.0.0")
    parser.add_argument("--port", type=int, default=8000)
    parser.add_argument("--reload", action="store_true")
    args = parser.parse_args()

    uvicorn.run("main:app", host=args.host, port=args.port, reload=args.reload)
