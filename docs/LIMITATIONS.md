# Limitations

This repository is a **self-directed practice portfolio**. It is not
client work. It is not a substitute for formal certification. It is not a
penetration test. It is not a production system.

This document exists because a professional portfolio should be honest
about its scope. A reviewer who reads it should come away knowing
exactly what the code can and cannot do.

---

## Fixtures

The three fixtures are FastAPI applications running on `127.0.0.1`.
They are deliberately simplified.

- **In-memory state.** Users, carts, sessions, and the auth log reset
  when the process restarts. There is no database.
- **No TLS.** Traffic is HTTP, not HTTPS. The session cookie is signed
  by `itsdangerous`, but transmitted in the clear.
- **No rate limiting.** A client can send unlimited login attempts.
- **No CSRF tokens.** The session cookie uses `SameSite=lax`, which
  protects against most cross-site attacks but is not a complete CSRF
  defence.
- **`SESSION_SECRET` is a development default.** Any non-local run must
  override `QA_FIXTURE_SECRET`.
- **No password hashing.** Storefront and SecurePortal user records
  store plaintext passwords in `data.py`. This is a deliberate choice
  for a fixture. A production system would use `bcrypt` or `argon2`.
- **No content security policy.** The storefront loads Google Fonts
  from a CDN and uses inline styles. A production deployment would set
  CSP headers and host the fonts locally.
- **No GDPR or privacy controls.** There is no consent flow, no data
  export, no deletion mechanism. User records are static.

**Do not expose these fixtures outside `127.0.0.1`.** They are not
hardened for network exposure.

---

## UI suite

The storefront UI suite covers the happy path and the most important
negative paths. It does not cover the following.

- **Cross-browser behaviour.** The suite runs headless Chrome via
  `SeleniumLibrary` with the `--headless=new` flag. Firefox, Safari,
  Edge, and mobile browsers are not covered. Chrome DevTools Protocol
  behaviour differs from Gecko and WebKit, so a passing suite on Chrome
  is not evidence that the same flows pass elsewhere.
- **Visual regression.** There is no screenshot diffing. A layout change
  that pushes the price below the fold would not be caught.
- **Accessibility.** No `axe-core` or Lighthouse integration. The design
  was built against WCAG 2.1 AA contrast requirements by hand, but this
  is not verified by an automated tool. See `docs/DESIGN.md` for the
  manual accessibility decisions.
- **Performance.** No load testing, no Core Web Vitals, no response
  time assertions. The suite would pass equally well against a slow
  server as a fast one.
- **Localisation.** All copy is in English. No i18n framework is present.
- **Text-to-speech and screen readers.** The HTML is semantic, but no
  assistive-technology testing was performed.

---

## Security-controls suite

The `tests/security` suite covers authentication feedback and one
server-side role boundary. It is **not a penetration test**.

- **UI-level assertions.** `SEC-001` and `SEC-002` verify what the user
  sees after login attempts. They do not test the authentication logic
  itself.
- **One role boundary.** `SEC-003` through `SEC-005` verify that the
  `/api/admin/records` endpoint enforces `role=admin`. They do not test
  other endpoints, other roles, or privilege escalation paths.
- **No transport-layer testing.** No HTTPS, no HSTS, no certificate
  pinning.
- **No session-fixation testing.** The session ID is not rotated on
  login. Whether this is exploitable is not tested.
- **No CSRF testing.** Whether the login form is vulnerable to a
  cross-site request forgery attack is not tested.
- **No rate-limit testing.** Whether brute-force login attempts are
  throttled is not tested.
- **No password-storage testing.** Passwords are stored plaintext in
  the fixture source; the suite does not verify this, and a production
  system would not do it.
- **No fuzzing.** No malformed inputs, no boundary values, no injection
  attempts.

A real security assessment requires an authorised scope, a documented
methodology, evidence chains, severity ratings, remediation guidance,
and retest confirmation. This suite has none of those.

---

## API suite

The `tests/api` suite covers the mock product API's contract.

- **Contract checks only.** Every assertion is against a known-good
  response. No fuzzing, no property-based testing.
- **No load testing.** No concurrent request testing. No Locust, no k6,
  no JMeter.
- **No authentication.** The API has no auth in the fixture.
- **No versioning tests.** The endpoint is `/api/v1/products`, but no
  compatibility testing exists between versions.
- **No schema validation beyond Pydantic.** The response is validated
  by Pydantic models at serialisation time, but there is no OpenAPI
  schema diffing against a baseline.

---

## What this portfolio is not

- **Not evidence of paid client work.** All content is self-authored.
  No client engagement, no paid assignment, no reference letter.
- **Not a substitute for professional experience.** Ten years of
  engineering practice is documented in the author's CV, not in this
  repository. The portfolio demonstrates skill; it does not certify it.
- **Not a substitute for ISTQB, CEH, or any other certification.** The
  author has completed preparation courses for both. Exam-issued
  certificates with verifiable numbers are not held at the time of
  writing.
- **Not a production system.** The fixtures are demonstrations. They
  would need hardening, monitoring, logging, backups, and access
  controls before any real use.

---

## What would strengthen this portfolio

The following changes would move this repository closer to a
production-grade test platform. They are listed here as honest gaps,
not as promises.

**Cross-browser coverage.** A GitHub Actions matrix running the UI
suite against Chromium, Firefox, and WebKit. Playwright would make
this trivial; Selenium makes it harder but not impossible.

**Accessibility testing.** `axe-core` integrated into every UI test as
a post-render check. Fails the suite on any WCAG 2.1 AA violation. This
is a standard tool and would add meaningful coverage.

**Visual regression.** Percy, BackstopJS, or Playwright's built-in
`toHaveScreenshot()`. Catches layout changes that functional tests
miss.

**Load testing.** A Locust or k6 scenario running against the API
fixture. Verifies that the endpoints scale beyond single-request
latency.

**Database.** Replace in-memory state with SQLite or Postgres, migrate
with Alembic, seed with fixtures, roll back between tests. This would
make the persistence layer testable.

**CSRF protection.** Add CSRF tokens to every state-changing form,
verify them server-side, and add a test that rejects a request with a
missing or invalid token.

**Rate limiting.** Add SlowAPI or an equivalent. Add tests that verify
the throttle fires after N attempts and releases after the window.

**Session rotation.** Rotate the session ID on login to prevent
fixation. Add a test that verifies the pre-login session ID is invalid
after authentication.

**Real password hashing.** Replace plaintext passwords with `bcrypt`
or `argon2` hashes. Add tests that verify the hash changes on
password update.

**Contract testing with `schemathesis` or `hypothesis-jsonschema`.**
Property-based testing against the OpenAPI schema catches edge cases
that hand-written tests miss.

**Documentation of every test's business rationale.** Every test case
in this repository has a one-line description. A production repository
would have a traceability matrix linking each test to a business
requirement, a risk, or a defect ID.

---

## Design limitations

See `docs/DESIGN.md` for the full design rationale. The known
trade-offs are:

- **No dark mode.** The merchant-house aesthetic is fundamentally about
  paper and ink. A dark variant would require a second full palette.
- **No automated focus-outline test.** Custom focus rings replace
  browser defaults. If a future browser changes `:focus-visible`
  semantics, the rings could disappear silently.
- **No reduced-motion test.** The `prefers-reduced-motion` media query
  is present in CSS, but no test verifies it takes effect.
- **No RTL support.** The site is LTR only.
- **No high-contrast mode.** No `prefers-contrast` media query.

---

## Acknowledgement

The author is aware that every gap listed above is a real gap. This
document is not a defence — it is a statement of scope. A reviewer
who reads it and finds a limitation that is *not* listed has found a
documentation defect, which is itself useful information.

The repository does what it claims to do, and it says clearly what it
does not do. That is the standard this document is trying to hold.
