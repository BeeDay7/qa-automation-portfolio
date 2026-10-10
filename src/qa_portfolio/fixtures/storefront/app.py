"""FastAPI application for the DemoMart storefront fixture.

The route handlers live in `routes.py`; this module wires middleware,
templates, and static assets.
"""

from __future__ import annotations

from pathlib import Path

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from starlette.middleware.sessions import SessionMiddleware

from qa_portfolio.config import STOREFRONT
from qa_portfolio.logging_config import configure_logging

from .routes import router

configure_logging(STOREFRONT.log_level, service="storefront")

BASE_DIR = Path(__file__).parent

app = FastAPI(
    title="Azam Trading Store — Registry API",
    version="1.0.0",
    description="Read-only registry API for the Azam Trading Store fixture.",
)

app.add_middleware(
    SessionMiddleware,
    secret_key=STOREFRONT.secret_key,
    session_cookie=STOREFRONT.session_cookie,
    same_site="lax",
    https_only=False,  # local fixture only
)

app.mount("/static", StaticFiles(directory=BASE_DIR / "static"), name="static")
app.include_router(router)
