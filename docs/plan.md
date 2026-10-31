# Plan: adapt ESP32 SDLC template to tiny npm static site

<!-- Current slice only. Written in Claude Code plan mode, approved by you.
     Old plans live in git history and their PRs. -->

## Files that change

Milestone 1 (npm project + Makefile):
- `.gitignore`: add `node_modules/`, `dist/`, `.vercel/`, `.wrangler/`
- `package.json`, `package-lock.json`: private ES module package; `build`, `test`, `lint` scripts; devDeps `eslint`, `@eslint/js`, `prettier`
- `eslint.config.js`: recommended rules; ignore `dist/`, `.vercel/`, `.wrangler/`
- `src/greet.js`, `src/index.html`, `src/style.css`: the site
- `test/greet.test.js`: unit test using `node:test`; delete `test/smoke.sh`
- `Makefile`: `build`, `test`, `lint` call npm; remove `flash`
- `docs/plan.md`, `docs/decisions.md`

Milestone 2 (Claude config + docs):
- `CLAUDE.md`: real name and description; remove hardware references; real healthy output in Commands; add Learning section
- `.claude/settings.json`: allow `Bash(npm *)`, `Bash(gh run view *)`, `Bash(gh pr view *)`; remove `make flash`
- `.claude/hooks/format.sh`: Prettier for JS, HTML, CSS and JSON, using `node_modules/.bin/prettier`
- `REVIEW.md`: skip `node_modules/`, `dist/`, `.vercel/`, `.wrangler/`
- `README.md`: name, setup, commands, local preview; drop flash

No CI workflow in this slice.

## Order of work
1. Milestone 1: create the npm project and retarget the Makefile.
   Verify with `make build`, `make test` and `make lint`, and confirm a broken assertion and a lint error each fail.

   Checkpoint: stop, paste output, wait for go-ahead before Milestone 2.
2. Milestone 2: update Claude config and docs.
   Verify with `make build test lint`, the hook on a misformatted temp file, the hook's executable bit, a hardware-term `grep` of `CLAUDE.md` and `Makefile`, and the verifier agent.

   Checkpoint: stop, paste output, list what couldn't be verified, wait for go-ahead to push and open a PR.

## Risks
- `Bash(npm *)` is broad: `npm install` runs package install scripts without a prompt.
- Prettier runs through the hook only, so `make lint` doesn't catch hand-edit formatting.
- The hook reformats `.claude/settings.json` on its next edit.

## Proof
How we'll know it works: `make build`, `make test` and `make lint` pass; the test and lint targets fail when deliberately broken; the page renders in a browser from `dist/` (manual check).

## Left alone
Not requested; ESP leftovers stay unless swept later:
- `.claude/agents/verifier.md`: "on the device"
- `docs/spec.md`, `intent/_TEMPLATE.md`: "hardware" wording
- `.gitignore`: `.pio/`, `managed_components/`, `sdkconfig.old`, `secrets.h`
- `.claude/settings.json`: `Read(**/secrets.h)` deny
- `.claude/hooks/format.sh`: clang-format and ruff branches
