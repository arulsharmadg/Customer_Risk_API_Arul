# Claude.md — v1.0 — FROZEN

**Customer Risk API — Execution Contract for Claude Code — Phase 5 Output**

This document is frozen at creation. Claude Code works against this contract exactly as written. If a task conflicts with an invariant, the invariant wins — flag the conflict, do not resolve it silently. If something is not in this document, Claude Code must flag the gap rather than fill it with judgment.

## 1. SYSTEM INTENT

This system provides a single read-only HTTP endpoint that accepts a `customer_id` (UUID), looks up the customer in a pre-populated Postgres database, and returns the customer's risk tier (`LOW` / `MEDIUM` / `HIGH`) and the structured list of risk factors that drove the assessment. All access requires a valid API key. A browser-based single-page UI allows operations staff to query by customer ID without writing code or holding database credentials.

**Does not:** compute or recalculate risk, support write or update operations, manage users or roles, perform audit logging, or provide production hardening (TLS, rate limiting, secrets management).

**Success looks like:** an operations staff member enters a customer ID in the browser and receives the correct tier and factors — authenticated, read-only, with no direct database access required.

## 2. HARD INVARIANTS

- **INV-01:** INVARIANT: No API request may result in any INSERT, UPDATE, or DELETE operation against the database. The database state after any request must be identical to the database state before it. This is never negotiable.
- **INV-02:** INVARIANT: The `risk_tier` and `factors` values returned in any API response must exactly equal the values stored in the database for that `customer_id`. No transformation, inference, defaulting, or rounding is permitted at any layer. This is never negotiable.
- **INV-03:** INVARIANT: A request for a `customer_id` that does not exist in the database must always return HTTP 404. It must never return a 200, must never return data belonging to any other customer, and must never reveal whether adjacent customer IDs exist. This is never negotiable.
- **INV-04:** INVARIANT: A response with HTTP 200 must always contain a `factors` array with at least one element. Every element must contain both `factor_code` (non-null string) and `factor_description` (non-null string). A 200 response with an empty factors array, a null factors field, or a partially structured factor object is not a valid response. This is never negotiable.
- **INV-05:** INVARIANT: Any request that does not present a valid API key in the `X-API-Key` header must receive HTTP 401. It must never receive customer data, partial data, error details, or any response body that reveals system internals. This applies to every endpoint without exception. This is never negotiable.
- **INV-06:** INVARIANT: The value of any API key — valid, invalid, or malformed — must never appear in an HTTP response body, an HTTP response header, or any application log entry. A request presenting a malformed or invalid key must be rejected with 401 without echoing the submitted value. This is never negotiable.
- **INV-07:** INVARIANT: No error response — for any status code — may contain stack traces, SQL query text, database error messages, internal file paths, environment variable names, or any information about the system's internal implementation. Error responses must contain only a human-readable message appropriate to the error type. This is never negotiable.
- **INV-08:** INVARIANT: At runtime, the application must communicate only with the Postgres database container within the Docker Compose network. It must never initiate any outbound network connection to an external host — including DNS lookups, HTTP requests, or any other network activity outside the defined container network. This is never negotiable.

## 3. SCOPE BOUNDARY

Claude Code is permitted to create or modify exactly these files:

- `docker-compose.yml`
- `.env.example`
- `db/init.sql`
- `db/seed.sql`
- `app/main.py`
- `app/db.py`
- `app/requirements.txt`
- `app/Dockerfile`
- `ui/index.html`
- `README.md`

Claude Code must not:

- Create any file not listed above without flagging it first.
- Add any endpoint beyond `GET /health`, `GET /customer/{customer_id}`, and the StaticFiles mount at `/`.
- Add any middleware beyond the auth middleware specified in S2.T2.
- Use string formatting to construct SQL — parameterised queries only (`%s` placeholders via psycopg2).
- Add any ORM, SQLAlchemy, or database abstraction layer.
- Add any frontend framework, npm package, or external CSS/JS import to the UI.
- Add any auth mechanism other than `X-API-Key` header validation against `VALID_API_KEYS`.
- Modify `Claude.md` under any circumstances.

If a task prompt conflicts with an invariant: the invariant wins. Flag the conflict — do not resolve it silently.

## 4. EXECUTION CONTRACT

- **One task at a time.** Complete the task exactly as specified in the CC prompt. Do not begin the next task.
- **No scope expansion.** If the task prompt is ambiguous or incomplete, flag the ambiguity — do not fill it with judgment.
- **Flag deviations immediately.** If implementation requires a decision not covered by this document, stop and report it. Do not resolve it silently.
- **Auth middleware order is fixed:** auth middleware must be registered before any route handler. StaticFiles must be mounted last, after all API routes.
- **No silent defaults.** If a value is null in the database, return null. Do not substitute empty arrays, empty strings, or default values.
- **Error handler must not catch HTTPException.** The global exception handler covers unhandled exceptions only — 404 and 422 must pass through as-is.

## 5. FIXED STACK

**Orchestration:** Docker Compose — exactly two services: `db` (Postgres) and `api` (FastAPI). No third container.

**Database:** `postgres:15` image. Database name: `riskdb`. Schema: single `customers` table with `customer_id` UUID PK, `risk_tier` VARCHAR(10) CHECK (`LOW`/`MEDIUM`/`HIGH`), `factors` JSONB nullable.

**API runtime:** Python 3.11 (`python:3.11-slim`). FastAPI. Uvicorn on port 8000.

**DB access:** `psycopg2-binary` only. No ORM. One parameterised SELECT query. Connections opened per request and closed after use.

**UI:** Single file: `ui/index.html`. Plain HTML + vanilla JavaScript. No framework. No external imports. Served via FastAPI StaticFiles at path `/`.

**Auth:** Starlette middleware. Header: `X-API-Key`. Rejection body: `{"detail": "Unauthorized"}`. No per-route dependencies.

**Error response — 500:** Body: `{"detail": "Internal server error"}`. No exception detail. Log full exception internally.

**Error response — 404:** Plain text body: `Customer not found`. No JSON wrapper.

**Error response — 401:** Body: `{"detail": "Unauthorized"}`. Key value must not be echoed.

**Environment variables — all required, no defaults:**

```
POSTGRES_DB=riskdb
POSTGRES_USER=postgres
POSTGRES_PASSWORD=<operator-provided>
POSTGRES_HOST=db
POSTGRES_PORT=5432
VALID_API_KEYS=<comma-separated, operator-provided>
```
