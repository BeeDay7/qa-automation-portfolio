"""Security controls shared by the fixtures.

Two controls live here:

* ``SecurityHeadersMiddleware`` adds defensive HTTP response headers
  (content security policy, MIME sniffing, framing, referrer policy) and
  marks JSON API responses as non-cacheable.
* ``LoginThrottle`` limits repeated failed sign-in attempts per account.

Both are deliberately small so that each behaviour can be verified by the
``tests/security`` suites. They are fixture-grade controls, not a
replacement for a production web application firewall or identity provider.
"""

from __future__ import annotations

import time
from collections import defaultdict, deque
from collections.abc import Awaitable, Callable
from typing import Final

from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response
from starlette.types import ASGIApp

#: Policy for pages that load their own scripts and styles, plus Google Fonts.
#: Inline styles are allowed because the templates use a small inline
#: <style> block; inline and third-party scripts are not.
DEFAULT_CSP: Final[str] = "; ".join(
    [
        "default-src 'self'",
        "script-src 'self'",
        "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
        "font-src 'self' https://fonts.gstatic.com",
        "img-src 'self' data:",
        "connect-src 'self'",
        "object-src 'none'",
        "base-uri 'self'",
        "form-action 'self'",
        "frame-ancestors 'none'",
    ]
)


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    """Attach defensive headers to every response."""

    def __init__(self, app: ASGIApp, csp: str = DEFAULT_CSP) -> None:
        super().__init__(app)
        self.csp = csp

    async def dispatch(
        self,
        request: Request,
        call_next: Callable[[Request], Awaitable[Response]],
    ) -> Response:
        response = await call_next(request)
        headers = response.headers
        headers.setdefault("Content-Security-Policy", self.csp)
        headers.setdefault("X-Content-Type-Options", "nosniff")
        headers.setdefault("X-Frame-Options", "DENY")
        headers.setdefault("Referrer-Policy", "no-referrer")
        headers.setdefault("Permissions-Policy", "camera=(), microphone=(), geolocation=()")
        if request.url.path.startswith("/api/"):
            headers["Cache-Control"] = "no-store"
        return response


class LoginThrottle:
    """Count failed sign-ins per account inside a sliding time window.

    After ``max_failures`` failures within ``window_seconds`` the account is
    throttled: further attempts are refused until the oldest failure leaves
    the window. A successful sign-in clears the account's history.
    """

    def __init__(
        self,
        max_failures: int = 5,
        window_seconds: float = 300.0,
        clock: Callable[[], float] = time.monotonic,
    ) -> None:
        self.max_failures = max_failures
        self.window_seconds = window_seconds
        self._clock = clock
        self._failures: defaultdict[str, deque[float]] = defaultdict(deque)

    @staticmethod
    def _key(username: str) -> str:
        return username.strip().casefold()

    def _prune(self, key: str) -> deque[float]:
        history = self._failures[key]
        cutoff = self._clock() - self.window_seconds
        while history and history[0] <= cutoff:
            history.popleft()
        return history

    def is_throttled(self, username: str) -> bool:
        return len(self._prune(self._key(username))) >= self.max_failures

    def retry_after(self, username: str) -> int:
        history = self._prune(self._key(username))
        if not history:
            return 0
        remaining = history[0] + self.window_seconds - self._clock()
        return max(1, int(remaining + 0.999))

    def record_failure(self, username: str) -> None:
        self._prune(self._key(username)).append(self._clock())

    def record_success(self, username: str) -> None:
        self._failures.pop(self._key(username), None)
