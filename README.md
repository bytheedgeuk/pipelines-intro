# pipelines-intro

A tiny static website with one JS function, a unit test and a linter, built with npm. It's a practice project for learning DevOps.

## Setup
Requires Node 20.19+ and npm.
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
python3 -m http.server -d dist
```
Open http://localhost:8000. Opening `dist/index.html` directly won't work, because browsers block ES modules on `file://`.

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
- [ ] Enable branch protection on `main`
      (Settings → Branches: require a pull request before merging)
- [ ] Write your first intent: the walking skeleton
