# <Project name>

One or two lines: what this is and who it's for.

## Build, test, flash
```
make build   # compile
make test    # host-side tests
make lint    # format/lint check
make flash   # hardware projects only
```

## How work flows (AI-native SDLC, solo edition)
1. **Intent:** brainstorm, then `/write-intent` → `intent/YYYY-MM-DD-<slug>.md`
2. **Spec:** Claude turns accepted intent into `docs/spec.md` (first time: whole-app architecture; later: update the relevant section)
3. **Plan:** Claude Code in plan mode → `docs/plan.md` for the current slice only
4. **Build:** implement on a branch; Claude runs `make build test lint` before saying it's done
5. **Review:** open a PR, run `/code-review` and `/security-review`, resolve every finding
6. **Merge:** squash-merge; note any new decision in `docs/decisions.md`
7. **Learn:** repeated mistake → `CLAUDE.md`; repeated review comment → `REVIEW.md`

## First-time setup checklist
- [ ] Rename `<Project name>` here and in `CLAUDE.md`
- [ ] Fill in the real commands in `Makefile` until `make build` and `make test` pass
- [ ] Paste the healthy output of each command into `CLAUDE.md`
- [ ] `git init`, push to GitHub, then enable branch protection on `main`
      (Settings → Branches: require a pull request before merging)
- [ ] Fill in skip paths in `REVIEW.md` (e.g. `.pio/`, `managed_components/`, `build/`)
- [ ] Make the hook executable: `chmod +x .claude/hooks/format.sh`
- [ ] Write your first intent: the walking skeleton
