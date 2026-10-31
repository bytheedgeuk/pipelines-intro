# Review instructions

<!-- Used by /code-review and any AI reviewer on PRs. Keep it short.
     When you leave the same review comment twice, add it here. -->

## Passes
Run three passes and tag each finding with its pass:
- **Bugs:** logic errors, broken edge cases, regressions, race conditions.
- **Security:** secrets in code or logs, unvalidated input, unsafe network calls.
- **Compliance:** the change matches `docs/spec.md` and `docs/plan.md`; flag any drift.

## Severity
- **Important:** would break behaviour, leak data or credentials, or contradict the spec.
- **Nit:** style, naming, minor tidy-ups.
- **Pre-existing:** a real issue the PR didn't introduce. Don't block on it.

## Rules
- Give a file and line as evidence for every finding.
- Report at most five nits; summarise the rest as a count.
- Flag the *class* of bug so every instance gets fixed, not just one line.
- Don't repeat findings already raised in an earlier round.
- After three rounds, stop and suggest reconsidering the approach instead.
- Start the summary with a count of findings, and say plainly when there's nothing to fix.
- Flag when the change makes a line in `CLAUDE.md` out of date.

## Do not report
- Generated or vendored files: `<paths, e.g. .pio/ build/ managed_components/>`
- Anything the linter/formatter already enforces.
