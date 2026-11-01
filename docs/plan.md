# Plan: slice 2, production deploy

<!-- Current slice only. Old plans live in git history and their PRs. -->

## Context
CI checks every change, but the site isn't published anywhere. This slice makes a merge to `main` publish the site to Cloudflare Pages, but only if CI passes. It covers R5, R7 and R8 in `docs/spec.md`. PR previews (R6) come in slice 3.

Status: plan approved. Milestones 1 and 2 are done; Milestone 3's reviews are done and their fixes applied. Nothing is deployed yet.

## New terms, in plain English
| Term | Meaning | In this slice | Azure DevOps equivalent |
|---|---|---|---|
| **Artifact** | Files saved from one job so a later job can use them | The built `dist/` folder | Pipeline artifact |
| **`needs`** | Makes one job wait for another, and normally skips it if that job fails | `deploy` needs `ci` | `dependsOn` |
| **Environment** | A named deploy target with its own secrets and rules | `production`, whose secrets only `main` can use | Environment |
| **API token** | A password for a program, limited to certain actions | Can only edit Cloudflare Pages | Service connection |
| **Rollback** | Putting a previous version back live | A button in Cloudflare's dashboard | Redeploying an earlier run |

## How the pipeline will work
```
merge to main
  -> ci job: lint, test, build, then save dist/ as an artifact
  -> deploy job (only if ci passed): download dist/, upload it to Cloudflare
```

The two jobs are deliberately separate:
- **The job holding the token doesn't install the repo's dev dependencies.** It doesn't download the repo or run `npm ci`; it only takes the finished `dist/` and uploads it, so a compromised dev dependency in `ci` can't read the token directly. Wrangler does read `dist/` while it holds the token, which is why the deploy refuses a `_worker.js`.
- **What gets published is what CI built.** It's the same files, built after the checks passed, not a second build. The tests run against `src/`, and `dist/` is a plain copy of it.

## What changes in the workflow
**`ci` job:** one new step, "Save the built site", which runs only on pushes to `main` (`actions/upload-artifact@v7`, kept for 7 days).

**New `deploy` job:**
- **Runs only when:** the event is a push to `main`, and `ci` passed (`needs: ci`). On PRs and other branches it shows as skipped.
- **Environment:** `production`, with its live URL shown on GitHub.
- **Concurrency:** one deploy at a time, so quick merges can't finish out of order.
- **Steps:**
  1. Download `dist/` (`actions/download-artifact`, pinned to v8.0.2's commit)
  2. Stop if `dist/_worker.js` exists
  3. Install Node 24 (`actions/setup-node`, pinned to v7.1.0's commit), because Wrangler needs Node 22 or newer
  4. Install Wrangler `4.156.0`, before the token is available
  5. Upload to Cloudflare with `cloudflare/wrangler-action`, pinned to commit `953926a2e2182532811c01a25e53647d93bf07c0` (v4.1.3), running `pages deploy dist --project-name=<name> --branch=main --commit-hash=<commit>`

`--branch=main` has to be stated because there's no repo checkout for Wrangler to read it from.

## Files that change
- `.github/workflows/ci.yml`: as above
- `README.md`: Deploy section with the live URL, how to roll back, and the Node version needed for Wrangler; tidy the setup checklist
- `docs/spec.md`: update Architecture, Interfaces and the manual steps; record the live URL
- `docs/decisions.md`: the decisions below
- `docs/plan.md`: this plan

No code in `src/` changes, and Wrangler isn't added to `package.json`.

## Decisions to record in `docs/decisions.md`
- Deploy uses a separate job with no checkout, so the token doesn't share a job with the repo's dev dependencies.
- Deploy publishes CI's artifact rather than rebuilding, so what's published is what CI built after its checks passed.
- Secrets live in a `production` environment limited to `main`, not at repo level, so a workflow on any other branch can't read them.
- Pin every action in the deploy job to an exact commit and Wrangler to an exact version, because this job can reach a secret.
- Wrangler stays out of `package.json`, because it needs Node 22+ while `engines` allows Node 20, and CI and local use don't need it installed.
- Don't pass `gitHubToken` to `wrangler-action`, because the environment already shows the deployment on GitHub and this avoids granting `deployments: write`.
- No automatic rollback, as the intent says. Rollback is by hand in Cloudflare or by reverting the PR.
- From the reviews: refuse `dist/_worker.js`; install Wrangler before the token is available; keep the artifact for 7 days; queue deploys; no admin bypass on `production`; no separate build job for now.

## Order of work
1. **Milestone 1: set up the accounts.** The steps under "What needs doing by hand" get done first. Then Claude allows `cloudflare/wrangler-action` on the repo, and confirms the environment and secret *names* exist through GitHub's API. GitHub never reveals secret values, and Claude doesn't need them.

   Checkpoint: stop, report what's confirmed, wait for go-ahead.

2. **Milestone 2: write it locally.** On `ci/production-deploy`, write the workflow and docs, then commit only the files listed above.
   Verify with `make build`, `make test`, `make lint`, a YAML syntax check and the verifier agent.

   Checkpoint: stop, paste output, wait for go-ahead to push and open a PR.

3. **Milestone 3: prove it's safe on the PR.** Push and open the PR. Confirm CI goes green and `deploy` is skipped on both runs. Run `/code-review` and `/security-review`, and report what they find before fixing anything.

   Checkpoint: stop, share run links and review results, wait for the PR to be reviewed and squash-merged.

4. **Milestone 4: confirm it's live.** After the merge, confirm `ci` and `deploy` go green on `main`, and that the live URL serves the same files as `dist/`. Then give the recap and a "break it on purpose" exercise.

   Checkpoint: stop, report results and what to check in a browser, wait for go-ahead before planning slice 3.

## What needs doing by hand
**Never paste a token or account ID into this chat.**

1. **Install Node 24 locally**, because Wrangler won't run on Node 20. With nvm, run `nvm install 24`, then `node -v` to confirm. This also matches what CI uses. To make it the default, run `nvm alias default 24`.
2. **Create a free Cloudflare account** at dash.cloudflare.com, if you don't have one.
3. **Create the project.** In the repo folder:
   ```
   npx wrangler@4.156.0 login
   npx wrangler@4.156.0 pages project create
   ```
   Enter `pipelines-intro` as the name and `main` as the production branch. Then run `npx wrangler@4.156.0 logout`, so the laptop stops holding that login.
4. **Tell Claude the project name and its `.pages.dev` URL.** These are public. If the name is taken, Cloudflare may add a suffix to the URL.
5. **Create the API token:** in Cloudflare, go to My Profile → API Tokens → Create Token → Custom token. Give it one permission, Account → Cloudflare Pages → Edit, limited to one account. Copy it straight into step 7.
6. **Find the account ID** in the Cloudflare dashboard.
7. **Create the GitHub environment:** go to Settings → Environments → New environment and name it `production`.
   - Under Deployment branches and tags, choose "Selected branches and tags" and add `main`.
   - Under Environment secrets, add `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`.
8. **Review and squash-merge the PR**, in Milestone 3.

Cloudflare's screens may differ slightly from these names.

## Risks
- **Allowed actions:** if `wrangler-action` isn't allowed before the push, GitHub rejects the whole workflow, including CI. That's why it gets allowed in Milestone 1.
- **First deploy:** this exact setup (`wrangler-action` with no checkout) only gets tested when it runs on `main`, because deploy is skipped on PRs. Cloudflare's examples all include a checkout. If it fails, the site just isn't published yet. A wrong setting gets fixed in place and the job re-run; a workflow problem gets fixed through a normal PR. If it can't work without a checkout, that needs a fresh decision, because it changes a security choice.
- **Blank page with green CI:** the inline script in `src/index.html` isn't linted or tested, so a green run doesn't prove the page works. This matters more now the site is public, so it stays a browser check by hand. Moving that script into a tested module could be its own later PR.
- **Direct Upload:** this project can't switch to Cloudflare's Git integration later without creating a new project.
- **Compromised dev dependency:** one running in `ci` could still change the published site, though it couldn't take the token that way. It would need a malicious dependency update to be merged.
- **Wrangler's dependencies:** there's no lockfile in the deploy job, so those below the top level aren't locked, and Wrangler's code runs with the token.
- **Token scope:** if the token leaked, someone could change the account's Pages projects, but nothing else in the account. You can revoke it in Cloudflare.
- **Free plan limit:** Cloudflare lists 500 builds a month, and its docs don't say whether Direct Upload counts. It's far above what this repo will use.

## Proof
- On the PR: both CI runs are green, and `deploy` is skipped on both.
- On `main`: `ci` and `deploy` are green, and the job's log shows the Cloudflare URL.
- The live URL returns 200, and its `greet.js` matches `dist/greet.js`.

**Not proven:** that a red `ci` on `main` stops a deploy. Testing that means breaking `main`, which branch protection now blocks. It relies on GitHub's documented `needs` behaviour.

**Check by hand:** the live page shows "Hello, world!" in a browser, and `production` shows on the repo's main page with the right URL.

## Left alone
- PR preview deploys (slice 3).
- Prettier in CI, and moving the inline script into a module: possible later PRs.
- The 5 moderate `npm audit` issues in dev dependencies: `dist/` doesn't contain them.
- Old merged branches.
