import requests
import uvicorn

from typing import Any, Dict
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse

app = FastAPI()

BANDWIDTH_LIMIT = "10KB"
BANDWIDTH_LIMIT_MODE = "server"

def ok_unchanged() -> JSONResponse:
    return JSONResponse({"reject": False, "unchange": True})

def reject(reason: str) -> JSONResponse:
    return JSONResponse({"reject": True, "reject_reason": reason})

def ok_with_content(content: Dict[str, Any]) -> JSONResponse:
    return JSONResponse({"reject": False, "unchange": False, "content": content})

@app.post("/handler")
async def handler(request: Request) -> JSONResponse:
    op = request.query_params.get("op") or ""
    if op != "NewProxy":
        return ok_unchanged()

    try:
        payload = await request.json()
    except Exception:
        return reject("invalid json")

    content = payload.get("content") or {}

    if (content.get("proxy_type") or "") != "udp":
        return reject("only udp proxy is allowed")

    content["remote_port"] = 0
    content["bandwidth_limit"] = BANDWIDTH_LIMIT
    content["bandwidth_limit_mode"] = BANDWIDTH_LIMIT_MODE

    return ok_with_content(content)

@app.get("/port/{name}")
async def get_port(name: str):
    try:
        response = requests.get(
            f"http://127.0.0.1:7500/api/proxy/udp/{name}",
            auth=("USER", "PASSWORD")
        )
        data = response.json()
        return data["conf"]["remotePort"]
    except:
        return 0

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9002)
