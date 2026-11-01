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

The deploy is a separate job that runs only on a push to `main`, and only if the `ci` job passed:

```
ci: lint, test, build, save dist/ ──pass──> deploy: download dist/, upload to Cloudflare
```

- The job holding the token has no checkout and runs none of the repo's code, so a compromised dev dependency in `ci` can't reach the token.
- It publishes the files `ci` tested, rather than building them again.
- The secrets live in a `production` environment that only `main` can use.

## Interfaces
- GitHub Actions: `.github/workflows/`.
- Cloudflare Pages: project `pipelines-intro`, live at https://pipelines-intro.pages.dev, deployed with `wrangler pages deploy`, using `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.

## Concerns flagged
- **Duplicate runs (accepted):** R1 and R2 together mean a push to a branch with an open PR runs CI twice, once for the push and once for the PR. Each run checks something slightly different: the branch as pushed, and the branch merged with `main`. This is kept because it's what was asked for. Narrowing the push trigger to `main` would remove it, but pushes to a branch with no PR would then go unchecked.
- **PRs with merge conflicts (accepted):** GitHub doesn't start the PR run while a PR has merge conflicts, so R2 only applies once the conflicts are fixed. The required check keeps such a PR unmergeable until then.
- **Branch protection (resolved):** GitHub doesn't offer branch protection on a private repo on GitHub Free, so the repo was made public. `main` requires a PR and a passing `ci (pull_request)` check, with no bypassing.
- **Secrets and untrusted code (slices 2 and 3):** `npm ci`, lint, test and build must not run in any job that has `CLOUDFLARE_API_TOKEN`, and `pull_request_target` stays out.
- **A red run on `main` (accepted, not tested):** stopping a deploy after a failed `ci` run relies on GitHub's documented `needs` behaviour. Testing it would mean breaking `main`, which branch protection blocks.
- **Pages or Workers (resolved):** Cloudflare's Pages docs now say "Start new projects with Workers". They don't say Pages is deprecated, so this project stays on Pages, as decided on 2026-11-01.
- **Public previews (accepted):** Cloudflare Pages preview URLs are public by default. That's fine for this site, which holds nothing private.
- **PRs from forks (accepted):** GitHub doesn't give workflows from forks access to secrets, so those PRs get CI but no preview. This is the safe behaviour.

## Slices
Ordered by risk. Each is one concept and one PR.
1. **CI only:** R1 to R4. No accounts or secrets needed.
2. **Production deploy:** R5, R7 and R8. Needs the Cloudflare account, project and secrets.
3. **Preview deploys:** R6.

## Manual setup
**Done for slice 2:**
- A Cloudflare account and the `pipelines-intro` Pages project, with `main` as its production branch.
- An API token with only the Cloudflare Pages Edit permission.
- A `production` environment on GitHub, limited to `main`, holding `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`. Claude never sees or handles these.
- `cloudflare/wrangler-action` added to the repo's allowed actions.

**Slice 3:** the `production` secrets can't be used by PRs, by design, so previews will probably need their own environment and secrets. The slice 3 plan will confirm this.
