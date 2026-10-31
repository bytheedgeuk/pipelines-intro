---
name: write-intent
description: Turn a rough idea or brainstorm into a committed intent.md (problem, outcome, success checks, constraints, scope, open questions). Use when starting a new feature or project.
---

# Write intent

Capture an idea, in the user's own words, as `intent/YYYY-MM-DD-<slug>.md`. Describe *what* and *why*, never *how*.

1. Read what the user gave, plus README, CLAUDE.md and existing files in `intent/`.
2. Ask only about gaps, at most 3 questions per round: the problem and who notices, what better looks like, how success is verified (push for checkable statements), hard constraints, and what's out of scope. If told "just draft it", draft and list assumptions under Open questions.
3. Draft using `intent/_TEMPLATE.md`. No architecture, file names or libraries unless the user stated them as constraints.
4. Show the draft, apply corrections, repeat until accepted.
5. Save with Status `accepted` and offer to commit as `intent: <short name>`.
6. End with one line: next stage is `docs/spec.md`, then plan mode for `docs/plan.md`.

Quality bar: every Success line is checkable; Out of scope has at least one entry; Open questions are real.
