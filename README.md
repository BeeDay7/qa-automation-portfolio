# QA Automation Portfolio — Azam Trading Store

[![CI](https://github.com/BeeDay7/qa-automation-portfolio/actions/workflows/ci.yml/badge.svg)](https://github.com/BeeDay7/qa-automation-portfolio/actions/workflows/ci.yml)
[![Python](https://img.shields.io/badge/python-3.11%2B-blue.svg)](https://www.python.org/)
[![Robot Framework](https://img.shields.io/badge/robotframework-7.x-000.svg)](https://robotframework.org/)
[![Selenium](https://img.shields.io/badge/selenium-4.x-43B02A.svg)](https://www.selenium.dev/)
[![FastAPI](https://img.shields.io/badge/fastapi-0.115%2B-009688.svg)](https://fastapi.tiangolo.com/)
[![Ruff](https://img.shields.io/badge/code%20style-ruff-000000.svg)](https://github.com/astral-sh/ruff)
[![mypy: strict](https://img.shields.io/badge/mypy-strict-blue.svg)](https://mypy.readthedocs.io/)
[![Tests](https://img.shields.io/badge/tests-32%20passing-brightgreen.svg)](#test-inventory)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

A reproducible, self-directed portfolio demonstrating professional
test-automation practice across **UI**, **security-controls**, and **API**
layers. Three FastAPI fixtures. Three Robot Framework suites. A single CI
pipeline that runs everything on every push.

**Author:** Abidemi Kuburat Adedeji
**Co-founder:** Sulaiman Oluwasegun Yusuff
**Status:** Self-directed portfolio — *not* client work, *not* a
substitute for professional experience or formal certification.

---

## Why this repository exists

Reviewers who evaluate test automation for quality engineering
engagements look for four things. This repository delivers each of them.

**A working test suite against a realistic target.** Not a `console.log`
demo, not a single Selenium script. Three suites totalling thirty-two
tests, running against three purpose-built FastAPI fixtures with
server-side state, signed session cookies, typed Pydantic models, and
OpenAPI documentation.

**Layered design.** Page-object model for the UI suites. Custom Robot
Framework Python libraries for data loading, API access, and evidence
capture. YAML-driven test data. Tagged suites for selective runs.

**Reproducible evidence.** Every Robot run writes `report.html`,
`log.html`, and `output.xml` into `evidence/<suite>/`. The CI pipeline
uploads them as downloadable artefacts. A reviewer can inspect the same
reports the author inspected.

**Engineering hygiene.** Typed Python, `mypy --strict`, `ruff` for
linting and formatting, `pre-commit` for the hook chain, and GitHub
Actions for continuous integration. The repository is not a script — it
is a project.

What this repository is *not* is documented honestly in
[`docs/LIMITATIONS.md`](docs/LIMITATIONS.md).

---

## The storefront

The UI fixtures are styled as a working merchant house — **Azam Trading
Store**, a fictional electronics and accessories retailer based in
Abuja, Nigeria. Every page carries the aesthetic described in
[`docs/DESIGN.md`](docs/DESIGN.md): warm parchment paper, deep forest
ink, brass accents, and editorial typography.

This is not decoration. A test fixture that looks like a generic
enterprise dashboard teaches test writers the wrong things. A fixture
that looks like a real shop teaches them that visual polish, copy, and
structure are also part of the surface a test can verify.

The storefront has:

- A homepage with a hero, a filterable catalogue, an editorial teaser,
  and an About section
- A product detail page for each of eight items
- A cart drawer with server-side session state
- A login dialog with server-side authentication
- An account page for signed-in users and guests
- A Journal with three full-length editorial articles
- A `/docs` Swagger UI documenting the storefront's own API

---

## Architecture

Three FastAPI applications run side by side, each serving a different
test target.

```
┌─────────────────────────┬─────────────────────────┬─────────────────────────┐
│  Storefront :8001       │  SecurePortal :8002     │  Product API :8003      │
├─────────────────────────┼─────────────────────────┼─────────────────────────┤
│  Server-rendered HTML   │  Server-side session    │  Typed REST surface     │
│  Signed session cookies │  Role-based access      │  OpenAPI schema         │
│  Cart, login, account,  │  Admin / viewer roles   │  Health, catalogue,     │
│  journal, checkout      │  Admin endpoint (403)   │  detail, 404s           │
└─────────────────────────┴─────────────────────────┴─────────────────────────┘
              │                        │                        │
              ▼                        ▼                        ▼
       ┌──────────────┐         ┌──────────────┐         ┌──────────────┐
       │  tests/ui    │         │ tests/       │         │  tests/api   │
       │  20 tests    │         │ security     │         │  7 tests     │
       │  Selenium    │         │ 5 tests      │         │  Requests    │
       │  Page objects│         │ Selenium +   │         │  Contract    │
       │  YAML data   │         │ Requests     │         │  testing     │
       └──────────────┘         └──────────────┘         └──────────────┘
```

The repository follows the `src/` layout: every importable package lives
under `src/qa_portfolio/`, and the tests import from there. This is the
pattern used by FastAPI, Pydantic, Starlette, and every modern Python
project on PyPI.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full rationale.

---

## What this repository demonstrates

| Layer | Evidence |
| --- | --- |
| **UI automation** | Page-object model, YAML-driven test data, session isolation, tagged suites, 20 functional tests |
| **Security controls** | Server-side role enforcement, admin/viewer boundary tests, HTTP 403 verification |
| **API contract** | Typed OpenAPI endpoints, health check, filters, detail, structured 404s |
| **Custom libraries** | `DataLoader`, `ApiClient`, `EvidenceHelper` — typed, documented, reusable |
| **CI** | GitHub Actions matrix across three suites with artefact upload |
| **Engineering** | `ruff`, `mypy --strict`, pre-commit, `.editorconfig`, VS Code workspace config |
| **Documentation** | `SETUP`, `ARCHITECTURE`, `LIMITATIONS`, `DESIGN` — four documents covering four audiences |
| **Design** | Merchant-house visual language, custom SVG illustrations, editorial voice |

---

## Quick start

```powershell
# 1. Clone and enter
git clone https://github.com/BeeDay7/qa-automation-portfolio.git
cd qa-automation-portfolio

# 2. Create the virtual environment
python -m venv .venv
.venv\Scripts\Activate.ps1

# 3. Install dependencies
python -m pip install --upgrade pip
pip install -r requirements-dev.txt -e ".[dev]"

# 4. Install the pre-commit hooks
pre-commit install

# 5. Start the fixtures
python scripts/serve_fixtures.py --background
Start-Sleep -Seconds 3

# 6. Run the suites
robot --outputdir evidence/ui       tests/ui
robot --outputdir evidence/security tests/security
robot --outputdir evidence/api      tests/api

# 7. Inspect the reports
start evidence\ui\report.html
start evidence\security\report.html
start evidence\api\report.html

# 8. Stop the fixtures
python scripts/serve_fixtures.py --stop
```

End-to-end setup with troubleshooting: [`docs/SETUP.md`](docs/SETUP.md).

---

## Fixtures

Once running, three services are available:

| URL | Service | What to see |
| --- | --- | --- |
| <http://127.0.0.1:8001> | Azam Trading Store | The storefront, product pages, cart, account, journal |
| <http://127.0.0.1:8001/docs> | Storefront API | Swagger UI of the storefront's own JSON endpoints |
| <http://127.0.0.1:8002> | SecurePortal | A dark-mode auth fixture with admin/viewer roles |
| <http://127.0.0.1:8002/docs> | SecurePortal API | Session and admin-records endpoints |
| <http://127.0.0.1:8003> | Product API | A typed REST surface |
| <http://127.0.0.1:8003/docs> | Product API schema | OpenAPI documentation of the mock catalogue |

### Demo credentials

| Fixture | Email / Username | Password | Role |
| --- | --- | --- | --- |
| Storefront | `admin@azamtradingstore.com` | `AzamAdmin!2026` | admin |
| Storefront | `customer@example.com` | `Customer!2026` | customer |
| SecurePortal | `qa_admin` | `LocalOnly!234` | admin |
| SecurePortal | `qa_viewer` | `ViewerOnly!234` | viewer |

These are documented in the fixtures' source code. They are not secrets.

---

## Test inventory

Thirty-two tests across three suites, all passing on every push.

### `tests/ui` — Functional UI (20 tests)

Browser-driven tests against the Azam Trading Store storefront using
SeleniumLibrary with a page-object model.

| ID | Scenario | Tags |
| --- | --- | --- |
| DM-001 | Valid login shows signed-in state | smoke, auth |
| DM-002 | Invalid login is rejected | smoke, negative, auth |
| DM-003 | Login dialog can be dismissed | auth |
| DM-004 | Checkout requires authentication | negative, cart |
| DM-005 | Adding a product updates cart total | smoke, cart |
| DM-006 | Cart accumulates multiple distinct products | cart |
| DM-007 | Search filters the catalogue | search |
| DM-008 | Empty search shows empty state | negative, search |
| DM-009 | Out-of-stock product is not addable | negative |
| DM-010 | Logout clears session and cart | auth, cart |
| DM-011 | Cart persists across page reload | cart |
| DM-012 | Signed-in user reaches account page | account |
| DM-013 | Anonymous visitor sees guest state | negative, account |
| DM-014 | Account page reflects basket count | account, cart |
| DM-015 | Journal index lists all articles | journal |
| DM-016 | Article opens with full body and metadata | journal |
| DM-017 | Article shows related products and other notes | journal |
| DM-018 | Journal link present in header on every page | navigation |
| DM-019 | Header journal link navigates from home | navigation |
| DM-020 | Footer links reach all primary pages | navigation |

### `tests/security` — Authentication controls (5 tests)

UI feedback and one server-side role boundary for the SecurePortal
fixture. This is a UI-level check, not a penetration test — see
[`docs/LIMITATIONS.md`](docs/LIMITATIONS.md).

| ID | Scenario |
| --- | --- |
| SEC-001 | Invalid credentials are rejected in the UI |
| SEC-002 | Admin login succeeds and reaches /dashboard |
| SEC-003 | Viewer role is refused by the admin API (403) |
| SEC-004 | Anonymous access to admin API is forbidden (403) |
| SEC-005 | Admin session is granted access to admin API (200) |

### `tests/api` — Contract and regression (7 tests)

| ID | Scenario |
| --- | --- |
| API-001 | /health reports ok and version |
| API-002 | Product list returns the full catalogue |
| API-003 | in_stock=true filter returns a subset |
| API-004 | category filter returns only matching products |
| API-005 | Product detail matches contract |
| API-006 | Unknown product returns structured 404 |
| API-007 | Unknown path returns 404, not 500 |

---

## Evidence

Every Robot run writes three artefacts into `evidence/<suite>/`:

- **`report.html`** — a summary view. Open this first. Shows pass/fail
  counts, timing, and per-test status at a glance.
- **`log.html`** — a detailed transcript. Every keyword invocation, every
  selector, every assertion, with timestamps.
- **`output.xml`** — machine-readable results. Used by CI to compute
  pass rates, feed dashboards, or trigger downstream jobs.

These files — not screenshots — are the primary evidence. They are
produced by Robot Framework itself and cannot be fabricated. The CI
pipeline uploads them as downloadable artefacts on every run.

Failed tests trigger an automatic screenshot into
`evidence/screenshots/` through the custom `EvidenceHelper` library.

---

## Continuous integration

Every push runs four jobs on GitHub Actions:

| Job | What it does |
| --- | --- |
| **quality** | Installs `[dev,test]` extras, runs `ruff check`, runs `mypy --strict` |
| **Robot suites (ui)** | Installs runtime deps, installs Chrome, starts fixtures, runs `tests/ui` |
| **Robot suites (security)** | Same, runs `tests/security` |
| **Robot suites (api)** | Same, runs `tests/api` |

Total wall-clock time: about 2 minutes. Each Robot job uploads its
`evidence/` directory as a build artefact with 30-day retention.

The workflow file is at
[`.github/workflows/ci.yml`](.github/workflows/ci.yml). The three
suites run in parallel because a UI regression cannot mask an API
contract failure if both fail independently.

---

## Repository layout

```
qa-automation-portfolio/
├── .github/workflows/ci.yml          GitHub Actions: quality + three Robot jobs
├── .vscode/                          Editor, tasks, launch configurations
├── docs/
│   ├── ARCHITECTURE.md               Design rationale
│   ├── DESIGN.md                     Visual and editorial decisions
│   ├── LIMITATIONS.md                Honest scope statement
│   └── SETUP.md                      End-to-end setup walkthrough
├── scripts/serve_fixtures.py         One-command launcher for the three fixtures
├── src/qa_portfolio/
│   ├── config.py                     Typed runtime configuration
│   ├── logging_config.py             Structured logging
│   ├── fixtures/
│   │   ├── storefront/               Azam Trading Store (HTML + JSON)
│   │   ├── secureportal/             SecurePortal auth fixture
│   │   └── api/                      Mock product API (typed, OpenAPI)
│   └── libraries/                    Custom Robot Framework libraries
├── tests/
│   ├── ui/                           UI suite (page objects, YAML data)
│   ├── security/                     Authentication-control suite
│   └── api/                          API contract suite
├── Makefile                          make install / test / evidence / clean
├── pyproject.toml                    Ruff + mypy strict configuration
├── requirements.txt                  Runtime dependencies
└── requirements-dev.txt              Runtime + dev dependencies
```

---

## Documentation

Four documents, each written for a different reader.

- [`docs/SETUP.md`](docs/SETUP.md) — end-to-end setup walkthrough with
  troubleshooting. For the first-time runner.

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — why the fixtures are
  split, why state is server-side, why page objects exist. For the
  engineer reading the code.

- [`docs/DESIGN.md`](docs/DESIGN.md) — the palette, the typography, the
  editorial voice, the accessibility decisions. For the reviewer who
  wants to know how the author thinks.

- [`docs/LIMITATIONS.md`](docs/LIMITATIONS.md) — what this portfolio is
  not. What it does not cover. What would need to be true for it to
  become a production-grade test platform. For the honest reader.

---

## Engineering conventions

**Typing.** Every module under `src/` passes `mypy --strict`. Every
public function has a return type. Every parameter is annotated. This is
not optional.

**Linting.** `ruff` enforces import order, modern syntax, and code
hygiene. Line length is 100 characters. `ruff format` is the single
source of truth for formatting.

**Commits.** Conventional Commits — `feat:`, `fix:`, `docs:`, `design:`,
`ci:`. The pre-commit hooks reject a commit that fails any check.

**Fixtures.** Every fixture enforces its rules server-side. No client-
side-only auth, no fake HTTP responses, no mocked Selenium drivers.
If the test passes, it is because the server said so.

---

## What this repository is not

- Not evidence of paid client engagements.
- Not a penetration test or a formal security assessment.
- Not a substitute for ISTQB, CEH, or any other certification.
- Not a production system. The fixtures are deliberately simplified and
  must never be exposed on an untrusted network.

See [`docs/LIMITATIONS.md`](docs/LIMITATIONS.md) for the full list.

---

## Licence

MIT — see [`LICENSE`](LICENSE).

---

## Contact

Sulaiman Oluwasegun Yusuff & Abidemi Kuburat Adedeji
Co-founder and Lead Engineer, ConnectHub (BN 9536850)
[connecthub.love](https://connecthub.love)
[admin@connecthub.love](mailto:admin@connecthub.love)
