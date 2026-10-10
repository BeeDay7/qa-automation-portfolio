"""In-memory user directory and auth log for the SecurePortal fixture."""

from __future__ import annotations

from collections import deque
from datetime import UTC, datetime
from typing import Any, Final

USERS: Final[dict[str, dict[str, str]]] = {
    "qa_admin": {
        "password": "LocalOnly!234",
        "role": "admin",
        "name": "QA Administrator",
    },
    "qa_viewer": {
        "password": "ViewerOnly!234",
        "role": "viewer",
        "name": "QA Viewer",
    },
    "qa_auditor": {
        "password": "AuditOnly!234",
        "role": "auditor",
        "name": "QA Auditor",
    },
}

ADMIN_RECORDS: Final[list[dict[str, object]]] = [
    {
        "id": 1,
        "title": "Q3 audit log",
        "classification": "internal",
        "updated": "2026-09-30T14:12:00Z",
    },
    {
        "id": 2,
        "title": "Access review cycle",
        "classification": "internal",
        "updated": "2026-10-04T09:45:00Z",
    },
    {
        "id": 3,
        "title": "Incident response runbook",
        "classification": "restricted",
        "updated": "2026-09-18T11:20:00Z",
    },
]

# Bounded in-memory auth log. Resets on fixture restart. Demonstrates the
# pattern of recording every authentication attempt, which real SOC
# platforms depend on. Not persistent. Not exposed as a public API.
AUTH_LOG: deque[dict[str, Any]] = deque(maxlen=50)


def record_auth_event(
    *,
    username: str,
    outcome: str,
    role: str | None = None,
    reason: str | None = None,
) -> dict[str, Any]:
    """Append an authentication event to the log and return it."""
    event: dict[str, Any] = {
        "timestamp": datetime.now(UTC).isoformat(timespec="seconds"),
        "username": username or "(empty)",
        "outcome": outcome,  # "granted" | "denied"
        "role": role,
        "reason": reason,
    }
    AUTH_LOG.appendleft(event)
    return event
