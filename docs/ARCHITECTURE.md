# Architecture

This document explains how the repository is put together and why. It is
written for an engineer reading the code for the first time.

---

## The shape of the system

```
src/qa_portfolio/
├── config.py            Settings for all fixtures, overridable by environment variables
├── logging_config.py    Structured logging shared by the fixtures
├── security.py          Security headers middleware and login throttle
├── fixtures/
│   ├── storefront/      :8001  Azam Trading Store (HTML pages + JSON API)
│   ├── secureportal/    :8002  Authentication and role-based access fixture
│   └── api/             :8003  Typed product API with an OpenAPI schema
└── libraries/           Custom Robot Framework libraries (Python)

tests/
├── ui/                  31 browser tests against the storefront
├── security/            20 security-control tests against SecurePortal and the storefront
└── api/                 7 contract tests against the product API

scripts/
├── serve_fixtures.py    Start or stop the three fixtures
└── run_all.py           One command: fixtures up, all suites, fixtures down
```

The test suites never import the fixture code. They talk to the fixtures
only over HTTP, through a browser or an HTTP client, exactly as they would
talk to a deployed system. Replacing a fixture with a real service would
need only a change of base URL.

---

## Why three fixtures instead of one

Each fixture is built for one kind of testing, so each suite has a target
whose behaviour is designed for what that suite checks.

| Fixture | Built for | What makes it a good target |
| --- | --- | --- |
| **Storefront** | UI automation | Server-rendered pages, a login dialog, cart, checkout, order pages, an admin-only contact inbox. Realistic enough that page objects, waits and session isolation matter. |
| **SecurePortal** | Security controls | Three roles (admin, auditor, viewer), an admin-only endpoint, an auth log readable by admin and auditor, login throttling and security headers. Small enough that every control can be tested directly. |
| **Product API** | Contract testing | Pydantic models generate an OpenAPI schema, so the tests can check responses against a published contract, including structured 404 errors. |

Keeping them separate also means a change to the storefront's pages cannot
break the security or API suites.

---

## Where state lives

- **Identity and cart** are kept in a signed session cookie
  (Starlette `SessionMiddleware`). The browser holds the cookie but cannot
  change it without the server's secret.
- **Orders, contact messages and the auth log** are kept in memory on the
  server. They reset when the fixture restarts, which gives every CI run a
  clean starting point.
- **Every rule is enforced on the server.** Who may read an order, who may
  read the inbox, which role may call which endpoint: the server decides,
  never the page's JavaScript. This is what lets the security suite test
  access control over the API without a browser, and what makes a test
  like SEC-019 (another user's order returns 404) meaningful.

---

## Why page objects

The UI suite uses page objects in `tests/ui/resources/pages/`: one resource
file per page (login, products, cart, account, order, contact, journal),
holding that page's selectors and the keywords that act on it.

- A selector is written once. If the login button's ID changes, one line
  changes, not every test that signs in.
- Test cases read as user actions ("Open Login Dialog", "Add Product To
  Cart") rather than as lists of locators.
- Test data (user accounts) lives in `tests/ui/data/users.yaml` and is
  loaded by the `DataLoader` library, so credentials are not repeated across
  tests.

---

## Test isolation

Selenium keeps one browser open for the whole UI suite, and browsers keep
cookies between pages. Without care, a test that signs in would leave the
next test signed in.

Every UI test therefore starts with `Reset Storefront Session`, which
clears cookies and web storage and reloads the store. Each test begins
signed out with an empty cart, whatever ran before it. When a test fails,
`EvidenceHelper` saves a screenshot to `evidence/screenshots/`.

Clicks go through a `Click Safely` keyword that dispatches the click with
JavaScript. This avoids a known headless-Chrome problem where a WebDriver
click lands on the wrong element.

---

## Security controls

`src/qa_portfolio/security.py` holds two controls shared by the fixtures:

- `SecurityHeadersMiddleware` adds a content security policy and the
  standard defensive headers to every response, and marks `/api/*`
  responses `Cache-Control: no-store`.
- `LoginThrottle` refuses sign-in attempts for an account after five
  failures in five minutes (HTTP 429 with `Retry-After`).

Both are small on purpose, so that each behaviour can be checked by a test.
The review that led to them is in [`SECURITY_REVIEW.md`](SECURITY_REVIEW.md).

---

## The `src/` layout

All importable code lives under `src/qa_portfolio/` and is installed with
`pip install -e .`. Tests and scripts import the installed package, not
files that happen to sit next to them, so a missing file or a broken import
shows up locally the same way it would in CI.

---

## Continuous integration

`.github/workflows/ci.yml` runs on every push and pull request:

1. **quality**: `ruff` (including the Bandit security rules), `mypy --strict`
   and a `pip-audit` scan of the dependencies.
2. **robot**: the three suites in parallel, each starting its own fixtures;
   reports are uploaded as artefacts.
3. **zap-baseline**: a passive OWASP ZAP scan of SecurePortal and the
   storefront; the reports are uploaded as artefacts. It reports findings
   but does not fail the build.

---

## Configuration

`config.py` reads host, ports, log level and the session secret from
environment variables (`QA_FIXTURE_HOST`, `QA_STOREFRONT_PORT`,
`QA_FIXTURE_SECRET` and so on), with local defaults. The same code runs on a
laptop and in CI without changes. The default secret is for local use only.
