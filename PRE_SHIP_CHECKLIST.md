# Pre-ship checklist

> Before saying "done." Any unchecked box = not shipped.

## Auth & authz
- [ ] Every route has auth (or `// PUBLIC:` comment).
- [ ] Admin routes have extra role check.
- [ ] Server-management actions are audit-logged.
- [ ] No secrets in responses, logs, or client bundles.

## Input validation
- [ ] Every route has schema.
- [ ] User input never passed directly to a shell.
- [ ] Strings min/max; numbers bounded; enums fixed.
- [ ] Invalid → 400 structured error.

## Unhappy paths
- [ ] Empty body → 400.
- [ ] Extra fields → handled.
- [ ] Wrong types → 400.
- [ ] No token → 401.
- [ ] Wrong role → 403.
- [ ] Missing resource → 404.
- [ ] Long-running op → status endpoint or websocket, not blocking request.
- [ ] Dependency down → clean 5xx.

## Output
- [ ] No private fields leaked.
- [ ] No stack traces in prod.

## Tests
- [ ] Integration test: happy + auth fail + validation fail.
- [ ] Suite passes.

## Docs
- [ ] New env vars in `.env.example`.
- [ ] New scripts/compose commands in README.
- [ ] New concepts documented.

## Git & review
- [ ] On feature branch.
- [ ] Small commits, imperative messages.
- [ ] PR description: what/why/how-to-test/follow-ups.
- [ ] Re-read my own diff.

## Secrets & config
- [ ] No `.env` committed.
- [ ] No hard-coded credentials.
- [ ] App boots with only `.env.example` vars.

## Observability
- [ ] Request id on every log line.
- [ ] Server-management actions audit-logged with actor.
- [ ] No credentials in logs.

## Final gut check
- [ ] On-call can debug at 3am from logs?
- [ ] Attacker can't trigger server-control actions?
- [ ] Comfortable with another feedback review?

All three yes → ships.
