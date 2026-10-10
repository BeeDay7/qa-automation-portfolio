"""In-memory user directory for the SecurePortal fixture."""

from __future__ import annotations

from typing import Final

USERS: Final[dict[str, dict[str, str]]] = {
    "qa_admin": {"password": "LocalOnly!234", "role": "admin", "name": "QA Admin"},
    "qa_viewer": {"password": "ViewerOnly!234", "role": "viewer", "name": "QA Viewer"},
    "qa_locked": {"password": "Locked123!", "role": "viewer", "name": "Locked Account"},
}

ADMIN_RECORDS: Final[list[dict[str, object]]] = [
    {"id": 1, "title": "Q3 audit log", "classification": "internal"},
    {"id": 2, "title": "Access review cycle", "classification": "internal"},
]
