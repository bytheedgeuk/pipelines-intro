# Intent: CI/CD pipeline
Author: G. Status: accepted. Date: 2026-10-31

## Problem
Lint, tests and the build only run when someone remembers to run them on their own machine, so a broken change can reach `main` unnoticed. The site isn't deployed anywhere, so there's no live page and no way to see a change before merging it. I'm learning DevOps and want to learn this on a real pipeline.

## Proposed outcome
Every push and pull request (PR) is checked automatically. A PR shows whether its checks passed and links to a preview of the site with that change in it. Merging to `main` publishes the site with no manual steps.

## Success looks like
- Pushing to any branch runs `make lint`, `make test` and `make build`, and the result shows on GitHub.
- Opening or updating a PR runs the same three commands, and the result shows on the PR.
- A change that breaks lint, a test or the build shows as failed on the PR.
- A PR gets its own preview URL, showing that PR's version of the site.
- After a merge to `main`, the live URL shows the merged change, with no manual deploy step.
- If the checks fail on `main`, the live site doesn't change.

## Affected systems
GitHub (Actions, repository settings), Cloudflare Pages, or Vercel if it fits better.

## Constraints
- Claude never handles deploy tokens or secrets; I add them to GitHub myself.
- Built in slices, CI first, with one concept per PR.
- Each concept is explained in plain English before any YAML is written.
- It should cost nothing beyond free plans, because this is a practice project. (Assumption; see Open questions.)

## Out of scope
- A custom domain.
- Monitoring, alerts or automatic rollback.
- Any other test types, such as browser or end-to-end tests.
- Dependency update automation.

## Open questions
- Assumption to confirm: free plans only.
- Cloudflare's Pages docs now say "Start new projects with Workers". Stay on Pages as requested, or move to Workers? Must be settled before the deploy slice.
