"""Centralised runtime configuration for the fixtures.

All values can be overridden with environment variables so the same code
runs on a laptop, inside CI, and against containerised services.
"""
from __future__ import annotations

import os
from dataclasses import dataclass


@dataclass(frozen=True)
class FixtureSettings:
    """Settings shared by every FastAPI fixture."""

    host: str = os.getenv("QA_FIXTURE_HOST", "127.0.0.1")
    secret_key: str = os.getenv("QA_FIXTURE_SECRET", "qa-portfolio-dev-secret-change-me")
    session_cookie: str = "qa_session"
    log_level: str = os.getenv("QA_LOG_LEVEL", "INFO")


@dataclass(frozen=True)
class StorefrontSettings(FixtureSettings):
    port: int = int(os.getenv("QA_STOREFRONT_PORT", "8001"))


@dataclass(frozen=True)
class SecurePortalSettings(FixtureSettings):
    port: int = int(os.getenv("QA_SECUREPORTAL_PORT", "8002"))


@dataclass(frozen=True)
class ApiSettings(FixtureSettings):
    port: int = int(os.getenv("QA_API_PORT", "8003"))


STOREFRONT = StorefrontSettings()
SECUREPORTAL = SecurePortalSettings()
API = ApiSettings()
