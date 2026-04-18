# CLAUDE.md — Engineering Rules (Company-Grade)

> **Read this file in full before writing or modifying any code in this repo.**
> These rules are binding. If you believe a rule should be broken for a specific case, STOP and ask the user for an explicit override using the syntax at the bottom of this file.

---

## 0. Non-negotiables

1. **Every HTTP route is authenticated by default.** Public routes explicitly whitelisted with a comment.
2. **Every input is validated server-side.** Client checks don't count.
3. **Secrets never live in source.** Env vars only; `.env` gitignored.
4. **Admin/privileged routes get an extra role check.**
5. **Error paths implemented, not TODO'd.**
6. **No commits to `main` directly.** Feature branches + PRs.
7. **If uncertain about security, stop and ask.**

---

## 1. Project shape

- Frontend: no large single-file HTML with inline scripts. Component-based.
- Backend: thin routes → services → db.
- Root README, `.env.example`, sensible `.gitignore` required.

---

## 2. Auth & authz

- Every route private until proven public. Apply auth middleware globally.
- Admin routes get extra role check.
- Server management surfaces especially: anything that starts/stops a process or writes to disk needs auth + audit log.
- Stripe (if added later): signatures verified, keys env-only, admin role for config.
- Passwords: bcrypt (cost ≥ 12) or argon2id. Min length 12.

---

## 3. Input validation

- Every input route has a schema.
- Strings min/max; numbers bounded; IDs format-checked; enums fixed sets.
- For server-management commands: whitelist the operations the user can request. Never pass user input directly into a shell.

---

## 4. Error handling & unhappy paths

- 401/403/400/404/409/5xx all handled. Central error handler. No stack traces leaked in prod.
- Before declaring done: try to break it (no input, malformed input, no auth, wrong role, dependency down, burst load).
- Long-running operations: status polling or websocket updates, not blocking requests.

---

## 5. Documentation

- Root README: what, stack, quick start, env vars, scripts (including docker compose commands), architecture, testing, deployment.
- Inline doc comments on services.

---

## 6. Typed code

- TypeScript / strict typing where the language supports it. No untyped escape hatches without a comment.

---

## 7. Testing

- New features ship with at least one test. Integration tests for routes (one per failure mode), unit tests for services. CI on every PR.

---

## 8. Git workflow

- No direct commits to `main`. Feature branches + PRs. See `GIT_WORKFLOW.md`.

---

## 9. Secrets & env

- `.env.example` committed; `.env` gitignored.
- Validate env at boot. Refuse to start if required vars missing.
- Production secrets in a manager. Rotate anything that may have leaked.

---

## 10. Logging

- Structured logger. Request id on every line. Never log credentials.
- Server-management actions get an audit trail (who did what, when).

---

## 11. Dependencies

- Maintained, widely used, no high CVEs. Pin versions. Audit before each release.

---

## 12. AI-assisted coding (rules for Claude)

1. Don't claim done until unhappy paths walked.
2. Don't add a route without schema + auth in the same change.
3. Don't edit auth/config/server-management files without re-reading this file.
4. No commits to `main`.
5. Read existing code before inventing patterns.
6. Surface risk explicitly.
7. Prefer small PRs (split if >5 files / >300 lines).

---

## 13. Override syntax

To skip a rule: restate the rule and risk, ask explicit confirmation, leave a `RULE-OVERRIDE` comment with date and follow-up, add `TODO.md` entry. Overrides never silent.

---

## 14. When in doubt

Secrets/money/PII/server-control → assume worse, ask first. Feature feels wrong → re-walk §4.

End of rules.
