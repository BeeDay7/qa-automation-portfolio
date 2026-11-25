# Security Review — SecurePortal and Azam Trading Store fixtures

| | |
| --- | --- |
| **Scope** | SecurePortal (`:8002`) and Azam Trading Store (`:8001`) FastAPI fixtures, their templates and client-side JavaScript |
| **Method** | Manual code review against OWASP ASVS 4.0.3 (Level 1), followed by automated verification in `tests/security` |
| **Reviewer** | Abidemi Kuburat Adedeji |
| **Date** | November 2026 |
| **Status** | All findings fixed; every fix is covered by an automated test |

This is a review of practice fixtures in a self-directed portfolio, not a
penetration test of a production system. See [`LIMITATIONS.md`](LIMITATIONS.md).

---

## Summary

| ID | Finding | Severity | Status | Test |
| --- | --- | --- | --- | --- |
| F-01 | Stored cross-site scripting in the SecurePortal auth log | High | Fixed | SEC-010 |
| F-02 | No protection against password guessing | Medium | Fixed | SEC-012, SEC-013 |
| F-03 | Missing content security policy and security headers | Medium | Fixed | SEC-016 |
| F-04 | Authentication API responses could be cached | Low | Fixed | SEC-017 |
| F-05 | Session not reset at sign-in | Low | Fixed | SEC-014 |
| F-06 | Two auth-log tests never ran | Low (test defect) | Fixed | SEC-006, SEC-007 |

Controls that were already correct and are now verified by tests: account
enumeration resistance (SEC-011), HttpOnly and SameSite cookie flags
(SEC-015), security logging (SEC-018), object-level access control on order
receipts (SEC-019) and the admin contact inbox (SEC-020).

---

## F-01 — Stored cross-site scripting in the SecurePortal auth log

**Severity:** High · **CWE-79** · **ASVS V5.3.3**

**Description.** Every sign-in attempt, including failed ones from anonymous
users, is written to the auth log with the submitted username. The admin
dashboard rendered the log with `innerHTML` and inserted the username without
encoding it.

**Steps to reproduce (before the fix).**
1. As an anonymous user, call `POST /api/login` with the username
   `<img src=x data-probe=1 alt=xss-probe>` and any password.
2. Sign in as `qa_admin` and open the dashboard.
3. Click **Refresh** on the auth log. The payload is parsed as HTML and an
   `<img>` element is created inside the log. A payload with an event handler
   would run script in the administrator's session.

**Impact.** Any anonymous visitor could run script in an administrator's
browser, read admin-only data shown on the page and act as the administrator.

**Fix.** `static/js/app.js` now HTML-encodes every server-provided value before
it is inserted into the page (`esc()`), for both the auth log and the admin
records table. As a second layer, the new content security policy allows
scripts only from the application's own origin (`script-src 'self'`), which
blocks inline event handlers even if encoding were missed.

**Verification.** SEC-010 sends the payload, signs in as admin in a real
browser and asserts that the payload is shown as text and that no element is
created. The test fails on the original code and passes on the fix.

---

## F-02 — No protection against password guessing

**Severity:** Medium · **ASVS V2.2.1**

**Description.** `POST /api/login` accepted unlimited attempts, so a password
could be guessed by automation.

**Fix.** A `LoginThrottle` (`src/qa_portfolio/security.py`) counts failures per
account. After five failures within five minutes, further attempts receive
HTTP 429 with a `Retry-After` header; a successful sign-in clears the count.
Throttled attempts are written to the auth log.

**Verification.** SEC-012 makes five failed attempts and expects the sixth to
return 429 with a valid `Retry-After`. SEC-013 confirms that a different,
legitimate account can still sign in.

**Residual risk.** Per-account throttling can be used to lock a known user out
for five minutes, and it does not stop guessing spread across many accounts.
A production system would add per-client limits and step-up challenges.

---

## F-03 — Missing content security policy and security headers

**Severity:** Medium · **ASVS V14.4.3, V14.4.4, V14.4.6, V14.4.7**

**Description.** Neither application sent a content security policy or the
standard defensive headers.

**Fix.** `SecurityHeadersMiddleware` adds to every response:
`Content-Security-Policy` (scripts from self only, no plugins, no framing,
fonts from Google Fonts), `X-Content-Type-Options: nosniff`,
`X-Frame-Options: DENY`, `Referrer-Policy: no-referrer` and a restrictive
`Permissions-Policy`.

**Verification.** SEC-016 checks the headers on both applications. The full UI
suite (31 tests) still passes with the policy in place.

**Residual risk.** `style-src` allows `'unsafe-inline'` because the templates use
inline style blocks. Moving those styles into stylesheet files would allow a
stricter policy.

---

## F-04 — Authentication API responses could be cached

**Severity:** Low · **ASVS V8.2.1**

**Fix.** Every `/api/*` response now carries `Cache-Control: no-store`.
**Verification.** SEC-017.

---

## F-05 — Session not reset at sign-in

**Severity:** Low · **ASVS V3.2.1**

**Fix.** The SecurePortal login now clears any existing session data before
storing the new identity, so nothing from a previous session carries over.
**Verification.** SEC-014 checks that logout removes access to the admin API.

**Residual risk.** Sessions are stored in signed cookies. Logout clears the
browser's copy, but a copy of the old cookie captured before logout would stay
valid until the secret changes. Server-side session storage would allow true
revocation.

---

## F-06 — Two auth-log tests never ran

**Severity:** Low (test-suite defect)

**Description.** SEC-006 and SEC-007 were placed under `*** Keywords ***`
instead of `*** Test Cases ***`, so Robot Framework treated them as unused
keywords and never executed them. The suite reported 5 tests instead of 7.

**Fix.** Both moved into `*** Test Cases ***`; the suite now runs and reports
them.

---

## Continuous checks

| Check | Tool | Where |
| --- | --- | --- |
| Static analysis (Bandit rule set) | `ruff` with the `S` rules | CI `quality` job |
| Known-vulnerable dependencies | `pip-audit` | CI `quality` job |
| Security control tests | Robot Framework (`tests/security`) | CI `robot` job |
| Dynamic baseline scan | OWASP ZAP baseline | CI `zap-baseline` job (report uploaded as an artefact) |
