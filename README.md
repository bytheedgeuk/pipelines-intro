# pipelines-intro

A tiny static website with one JS function, a unit test and a linter, built with npm. It's a practice project for learning DevOps.

## Setup
Requires Node `^20.19.0 || ^22.13.0 || >=24`, npm and `make`. The local preview also needs `python3`.
```
npm install
```

## Build, test, lint
```
make build   # copy src/ to dist/
make test    # unit tests (node:test)
make lint    # ESLint, zero warnings allowed
```

## Preview locally
```
make build
python3 -m http.server 8001 --bind 127.0.0.1 -d dist
```
Open http://localhost:8001. Opening `dist/index.html` directly won't work, because browsers block ES modules on `file://`.

## CI
GitHub Actions runs `make lint`, `make test` and `make build` on every push and pull request, on Node 24. The workflow is in `.github/workflows/ci.yml`, and results show in the repo's Actions tab and on each PR. A push to a branch with an open PR runs CI twice: `ci (push)` checks the branch, and `ci (pull_request)` checks the branch merged with `main`. The PR run doesn't start while a PR has merge conflicts.

## Docs
- `docs/spec.md`: requirements and architecture
- `docs/plan.md`: plan for the current slice
- `docs/decisions.md`: decisions and why they were made
- `intent/`: ideas
- `REVIEW.md`: review instructions

## How work flows (AI-native SDLC, solo edition)
1. **Intent:** brainstorm, then `/write-intent` → `intent/YYYY-MM-DD-<slug>.md`
2. **Spec:** Claude turns accepted intent into `docs/spec.md` (first time: whole-app architecture; later: update the relevant section)
3. **Plan:** Claude Code in plan mode → `docs/plan.md` for the current slice only
4. **Build:** implement on a branch; Claude runs `make build test lint` before saying it's done
5. **Review:** open a PR, run `/code-review` and `/security-review`, resolve every finding
6. **Merge:** squash-merge; note any new decision in `docs/decisions.md`
7. **Learn:** repeated mistake → `CLAUDE.md`; repeated review comment → `REVIEW.md`

## First-time setup checklist
- [x] Enable branch protection on `main`
      (Settings → Branches: require a pull request before merging, no bypassing)
- [ ] After CI has run once, make it required
      (Settings → Branches: require status checks to pass, select `ci (pull_request)`, and require branches to be up to date)
- [x] Write your first intent
