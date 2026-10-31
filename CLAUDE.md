# <Project name>

One or two lines: what this project is and who it's for.
Rule: when Claude makes the same mistake twice, the fix goes in here. Keep this under a page.

## Commands
- Build: `make build` (healthy output ends with "<expected text>")
- Test: `make test` (all green; ends with "All tests passed")
- Lint: `make lint` (zero warnings)
- Flash: `make flash` (hardware only; ask before running)

## Verifying your work
Run `make build`, `make test` and `make lint` before reporting any task complete, and paste the output.
If a test fails, fix the code, not the test. Never skip or delete a failing test.
If something can't be verified here (e.g. on-device behaviour), say so explicitly
and list exactly what I should check by hand.

## Workflow
- Ideas live in `intent/`; requirements and architecture in `docs/spec.md`.
- `docs/plan.md` holds the plan for the current slice only.
- If implementation departs from `plan.md`, update the plan in the same commit.
- Record any architectural choice in `docs/decisions.md` (one line + why).
- Work on a branch; never commit to main directly.

## Architecture
- `src/` holds app code. Keep hardware drivers thin; put logic (state, parsing,
  protocol handling) in modules that compile and test on the host.
- `test/` holds host-side tests for that logic.

## Conventions
- Language/framework versions: <fill in>
- Naming, error handling, logging rules that matter: <fill in>

## Things Claude gets wrong
- (Add entries as they happen.)
