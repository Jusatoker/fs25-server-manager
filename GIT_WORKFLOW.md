# Git workflow (solo or team)

Make code review a habit, even alone.

## The flow

1. `git checkout main && git pull`
2. `git checkout -b feat/short-description`
3. Small, focused commits. Imperative messages.
4. `git push -u origin <branch> && gh pr create --fill`
5. Review your own diff as a stranger.
6. Merge via UI (squash by default). Delete branch.

## Branch naming

`<type>/<short-description>`: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/`, `test/`, `security/`.

## PR template

```
## What
## Why
## How to test
## Follow-ups
```

## Rules of the road

- Never push to `main`. Never force-push to `main`. Never `--no-verify`. Never commit `.env`. Never commit secrets (leak → rotate first).
- One PR = one logical change.
- Big change → Draft PR early.

## When things go wrong

- On main by accident? `git branch feat/recover && git reset --hard origin/main && git checkout feat/recover && git push -u origin feat/recover`.
- Secret committed? Rotate it. Then `git filter-repo`/BFG. Treat as compromised forever.
- Bad merge? Don't force-push. Open a fix PR.
