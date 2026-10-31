# pipelines-intro

A tiny static website with one JS function, a unit test and a linter, built with npm. It's a practice project for learning DevOps.
Rule: when Claude makes the same mistake twice, the fix goes in here. Keep this under a page.

## Commands
- Build: `make build` (healthy output ends with "Built to dist/")
- Test: `make test` (exit 0; summary shows at least 1 test and "fail 0")
- Lint: `make lint` (exit 0; no output when clean)

## Verifying your work
Run `make build`, `make test` and `make lint` before reporting any task complete, and paste the output.
If a test fails, fix the code, not the test. Never skip or delete a failing test.
If something can't be verified here (e.g. how the page renders in a browser), say so explicitly
and list exactly what I should check by hand.

## Learning
I'm a PM learning DevOps (I can read code, but I'm not deeply technical), so:
- Explain changes before making them, in plain English; define jargon the first time.
- Explain CI failures before fixing them: show the relevant log lines and the root cause.
- Use plan mode for workflow changes.
- One concept per PR. After each slice, give a 3–5 bullet recap and one
  "break it on purpose" exercise.
- Never handle deploy tokens or secrets; tell me what to add to GitHub Secrets.
- Where useful, note the Azure DevOps Pipelines equivalent.

## Workflow
- Ideas live in `intent/`; requirements and architecture in `docs/spec.md`.
- `docs/plan.md` holds the plan for the current slice only.
- If implementation departs from `plan.md`, update the plan in the same commit.
- Record any architectural choice in `docs/decisions.md` (one line + why).
- Work on a branch; never commit to main directly.

## Architecture
- `src/` holds the site, copied as-is to `dist/` by the build. Put logic in JS modules
  that Node can test without a browser.
- `test/` holds unit tests for that logic, run with `node:test`.

## Conventions
- Language/framework versions: Node `^20.19.0 || ^22.13.0 || >=24`, ES modules, ESLint 10, Prettier 3.
- Naming, error handling, logging rules that matter: none yet.

## Things Claude gets wrong
- (Add entries as they happen.)
