"""HTTP routes for the SecurePortal fixture."""

from __future__ import annotations

from pathlib import Path

from fastapi import APIRouter, Request
from fastapi.responses import HTMLResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel, Field

from .data import ADMIN_RECORDS, USERS

BASE_DIR = Path(__file__).parent
templates = Jinja2Templates(directory=BASE_DIR / "templates")

router = APIRouter()
USER_KEY = "user"
ROLE_KEY = "role"


class LoginBody(BaseModel):
    username: str = Field(min_length=1)
    password: str = Field(min_length=1)


@router.get("/", response_class=HTMLResponse, include_in_schema=False)
async def index(request: Request) -> HTMLResponse:
    return templates.TemplateResponse(request=request, name="index.html")


@router.get("/dashboard", response_class=HTMLResponse, include_in_schema=False)
async def dashboard(request: Request) -> HTMLResponse:
    return templates.TemplateResponse(request=request, name="dashboard.html")


@router.get("/api/session")
async def session(request: Request) -> JSONResponse:
    user = request.session.get(USER_KEY)
    role = request.session.get(ROLE_KEY)
    return JSONResponse({"authenticated": bool(user), "username": user, "role": role})


@router.post("/api/login")
async def login(request: Request, body: LoginBody) -> JSONResponse:
    record = USERS.get(body.username)
    if record is None or record["password"] != body.password:
        return JSONResponse({"error": "invalid_credentials"}, status_code=401)
    request.session[USER_KEY] = body.username
    request.session[ROLE_KEY] = record["role"]
    return JSONResponse({"ok": True, "role": record["role"], "name": record["name"]})


@router.post("/api/logout")
async def logout(request: Request) -> JSONResponse:
    request.session.clear()
    return JSONResponse({"ok": True})


@router.get("/api/admin/records")
async def admin_records(request: Request) -> JSONResponse:
    if request.session.get(ROLE_KEY) != "admin":
        return JSONResponse({"error": "forbidden"}, status_code=403)
    return JSONResponse({"items": ADMIN_RECORDS, "count": len(ADMIN_RECORDS)})
