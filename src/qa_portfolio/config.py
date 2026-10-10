"""Centralised runtime configuration for the fixtures.

All values can be overridden with environment variables so the same code
runs on a laptop, inside CI, and against containerised services.
"""

from __future__ import annotations

import os
from dataclasses import dataclass

_DEFAULT_HOST: str = os.getenv("QA_FIXTURE_HOST", "127.0.0.1")
_DEFAULT_SECRET: str = os.getenv("QA_FIXTURE_SECRET", "qa-portfolio-dev-secret-change-me")
_DEFAULT_LOG_LEVEL: str = os.getenv("QA_LOG_LEVEL", "INFO")
_DEFAULT_STOREFRONT_PORT: int = int(os.getenv("QA_STOREFRONT_PORT", "8001"))
_DEFAULT_SECUREPORTAL_PORT: int = int(os.getenv("QA_SECUREPORTAL_PORT", "8002"))
_DEFAULT_API_PORT: int = int(os.getenv("QA_API_PORT", "8003"))


@dataclass(frozen=True)
class FixtureSettings:
    """Settings shared by every FastAPI fixture."""

    host: str = _DEFAULT_HOST
    secret_key: str = _DEFAULT_SECRET
    session_cookie: str = "qa_session"
    log_level: str = _DEFAULT_LOG_LEVEL


@dataclass(frozen=True)
class StorefrontSettings(FixtureSettings):
    port: int = _DEFAULT_STOREFRONT_PORT


@dataclass(frozen=True)
class SecurePortalSettings(FixtureSettings):
    port: int = _DEFAULT_SECUREPORTAL_PORT


@dataclass(frozen=True)
class ApiSettings(FixtureSettings):
    port: int = _DEFAULT_API_PORT


STOREFRONT = StorefrontSettings()
SECUREPORTAL = SecurePortalSettings()
API = ApiSettings()
