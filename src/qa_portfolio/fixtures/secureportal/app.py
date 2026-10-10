"""FastAPI application for the SecurePortal fixture."""

from __future__ import annotations

from pathlib import Path

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from starlette.middleware.sessions import SessionMiddleware

from qa_portfolio.config import SECUREPORTAL
from qa_portfolio.logging_config import configure_logging

from .routes import router

configure_logging(SECUREPORTAL.log_level, service="secureportal")

BASE_DIR = Path(__file__).parent

app = FastAPI(
    title="SecurePortal Fixture",
    version="1.0.0",
    docs_url=None,
    redoc_url=None,
)
app.add_middleware(
    SessionMiddleware,
    secret_key=SECUREPORTAL.secret_key,
    session_cookie=SECUREPORTAL.session_cookie,
    same_site="strict",
    https_only=False,
)
app.mount("/static", StaticFiles(directory=BASE_DIR / "static"), name="static")
app.include_router(router)
