# Spec: pipelines-intro
Source intent: `intent/2026-10-31-ci-cd-pipeline.md`. Status: accepted.

## Requirements

### Continuous integration (CI)
- R1: Every push to any branch runs `make lint`, `make test` and `make build`.
- R2: Every pull request (PR) runs the same three commands.
- R3: If any command fails, the run fails, and that shows on the commit and the PR.
- R4: CI needs no secrets and only has read access to the repo.

### Deployment
- R5: A merge to `main` deploys `dist/` to production on Cloudflare Pages.
- R6: Each PR gets a preview deploy with its own URL.
- R7: A deploy only runs after CI passes on the same commit.
- R8: Deploy credentials live in GitHub Secrets. They're never in the repo or logs, and Claude never handles them.

## Architecture
The site is static. `src/` is copied to `dist/` by the build, and `dist/` is what gets published. Logic lives in JS modules, tested by Node without a browser.

GitHub Actions runs the pipeline, and `make` stays the only interface to the commands, so CI runs exactly what a person runs locally:

```
push or PR ──> CI: lint, test, build ──pass──> PR: preview deploy
                                         └───> main: production deploy
```

### Hosting: Cloudflare Pages, not Vercel
Vercel doesn't fit better here, for three reasons:
- Vercel's free Hobby plan is for non-commercial personal use only. Cloudflare Pages has no such limit, which leaves the door open if this pattern is reused at work.
- Vercel's own guidance is that you don't need GitHub Actions on top of it unless you have a specific reason. This project's point is to learn the pipeline.
- GitHub Actions on Vercel needs three stored values (token, org ID, project ID). Cloudflare Pages needs two (API token, account ID).

### Deploy method: GitHub Actions with Direct Upload
The workflow uploads `dist/` to Cloudflare, rather than Cloudflare building from the repo through its Git integration. This keeps every stage visible in one pipeline, and it's the simplest way to meet R7. Cloudflare doesn't allow a Direct Upload project to switch to Git integration later; switching would mean creating a new project.

## Interfaces
- GitHub Actions: `.github/workflows/`.
- Cloudflare Pages, from slice 2: `wrangler pages deploy`, using `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.

## Concerns flagged
- **Duplicate runs (accepted):** R1 and R2 together mean a push to a branch with an open PR runs CI twice, once for the push and once for the PR. Each run checks something slightly different: the branch as pushed, and the branch merged with `main`. This is kept because it's what was asked for. Narrowing the push trigger to `main` would remove it, but pushes to a branch with no PR would then go unchecked.
- **Branch protection (`ci` check still to add):** GitHub doesn't offer branch protection on a private repo on GitHub Free, so the repo was made public. `main` now requires a PR, with no bypassing. Until `ci` is added as a required check after the first run, a red CI run warns but can't block a merge.
- **Pages or Workers (open, must be settled before slice 2):** Cloudflare's Pages docs now say "Start new projects with Workers". They don't say Pages is deprecated, and it was the host requested, so this spec stays on Pages until told otherwise. Slice 1 isn't affected.
- **Public previews (accepted):** Cloudflare Pages preview URLs are public by default. That's fine for this site, which holds nothing private.
- **PRs from forks (accepted):** GitHub doesn't give workflows from forks access to secrets, so those PRs get CI but no preview. This is the safe behaviour.

## Slices
Ordered by risk. Each is one concept and one PR.
1. **CI only:** R1 to R4. No accounts or secrets needed.
2. **Production deploy:** R5, R7 and R8. Needs the Cloudflare account, project and secrets.
3. **Preview deploys:** R6.
