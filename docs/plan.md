# Plan: slice 3, PR preview deploys

<!-- Current slice only. Old plans live in git history and their PRs. -->

## Context
Today a change can only be seen a change on the real site after merging it. This slice gives each PR its own public preview URL, showing that PR's version of the site, so it can be checked first. It covers R6 in `docs/spec.md`.

It starts with a small PR adding a pipeline diagram, so the preview PR can show its workflow change on the diagram. The blank-page test comes straight after, as slice 4.

Status: plan approved. Milestone 1 (the diagram) is next.

## Preview or staging?
They look alike here because this site is a few static files on one host. They answer different questions:

| | Preview | Staging / SIT |
|---|---|---|
| **Question it answers** | Does this one change look right? | Does everything merged so far work together? |
| **When** | Before merge | After merge, before production |
| **How many** | One per PR, temporary | One, long-lived and shared |
| **Contains** | One PR, plus `main` when CI ran | Everything merged, waiting to go live |
| **Usually connected to** | Little or nothing real, often fake data | Production-like data, services and integrations |
| **Typical users** | The PR's author, reviewers, a PM | QA, UAT testers, other teams |

SIT (system integration testing) is a staging-style environment used to test how separate systems work together.

Organisations often run both, plus UAT for business sign-off. A typical path is `PR -> preview -> merge -> staging/SIT -> approval -> production`.

**For this project:** previews do nearly everything staging would. There's no backend, data or integration to test, and the "up to date" rule means each PR has already been tested against the latest `main`. So there's no staging in this plan. Practising that path would make a good later slice: its real value is learning promotion and approval, not protecting this site.

## The trade-off to check
**Previews need a Cloudflare token on PRs, and that token could also change production.**

Slice 2 limited the deploy token to `main`, which PRs can't use, so previews need their own. As far as could be found, Cloudflare's Pages permission covers a whole account, not one project. So the preview token has the same power as the production one, and it has to be readable from any branch.

| Who | Can they reach the preview token? |
|---|---|
| Someone opening a PR from a fork | No, GitHub gives forks no secrets |
| A dependency running in the `ci` job | No, that job doesn't have it |
| Anyone who can push a branch to this repo (only the owner) | Yes, by editing the workflow on that branch |

**Decision: a separate preview token in the same Cloudflare account.** The repo owner is the only person with write access, and it can be revoked without touching production. It does mean "only `main` can reach a token that can change production" stops being true, so the docs will say so.

Two stronger options, not chosen here:
- **A separate Cloudflare account for previews:** a leaked preview token couldn't touch production. This is the closest to how larger organisations separate non-production from production, but it means a second account and project.
- **A `workflow_run` workflow:** a deploy workflow that always runs from `main`'s copy, so a branch can't edit it. It's safer, but noticeably harder to follow, and it can't be tested until it's already merged.

## New terms, in plain English
| Term | Meaning | In this slice | Azure DevOps equivalent |
|---|---|---|---|
| **Preview deploy** | A temporary public copy of a PR's version of the site | One per PR | A PR-triggered deploy, often called a review app |
| **Branch alias** | A stable address that always shows a branch's latest upload | `pr-12.pipelines-intro.pages.dev` | No direct equivalent |
| **Fork** | Someone's personal copy of a repo, from which they can open PRs | Gets CI but no preview | Fork |

## The pipeline, after this slice
```
PR from this repo
  -> ci job: lint, test, build, save dist/
  -> preview job (only if ci passed): download dist/, upload as pr-<number>

merge to main
  -> ci job, then deploy job: unchanged
```
`docs/pipeline.md` will show this as a diagram.

## What changes in the workflow
**`ci` job:** "Save the built site" runs on every run, not just on `main`. It's simpler, the files contain nothing secret, and the `deploy` and `preview` jobs each decide for themselves whether to use them.

**New `preview` job:**
- **Runs only when:** the event is a PR from this repo, not a fork, and `ci` passed. It shows as skipped otherwise.
- **Environment:** `preview`, with the PR's preview URL, so GitHub shows a link on the PR without needing write access.
- **Concurrency:** one per PR, and a newer push cancels an older upload.
- **Steps:** the same as `deploy`, with the same pinned versions, including stopping if `dist/_worker.js` exists. The guard matters more here because this runs PR code before anyone has merged it.
- **Upload command:** `pages deploy dist --project-name=pipelines-intro --branch=pr-<number> --commit-hash=<commit>`

**`deploy` job:** unchanged.

The branch name is `pr-<number>` rather than the real branch name for two reasons: a PR number is always a plain number, so nothing unexpected can get into the command, and it can never be `main`.

## Files that change
**Diagram PR (Milestone 1):**
- `docs/pipeline.md`: new; a Mermaid diagram of the pipeline as it is today, showing triggers, jobs, conditions and where the secrets are
- `CLAUDE.md`: under Workflow, add "When `.github/workflows/` changes, update `docs/pipeline.md` in the same PR"
- `README.md`: link to the diagram from Docs
- `docs/decisions.md`: why the diagram lives in the repo
- `docs/plan.md`: this plan

**Preview PR (Milestones 3 to 5):**
- `.github/workflows/ci.yml`: as above
- `docs/pipeline.md`: add the `preview` job, so the PR shows the change
- `README.md`: Previews section
- `docs/spec.md`: Architecture, Interfaces, Concerns and Manual setup; add slice 4 to Slices
- `docs/decisions.md`: the decisions below
- `docs/plan.md`: status

## Decisions to record in `docs/decisions.md`
- The diagram is Mermaid text in the repo, because GitHub draws it, and it gets reviewed and versioned with the workflow.
- Previews use their own token in a `preview` environment, so they can be revoked separately. That token could still change production, because Cloudflare's permission covers the whole account.
- Previews are named `pr-<number>`, not after the branch, so the command can't take in unexpected text and can't target `main`.
- `preview` isn't a required check, so a Cloudflare problem can't block merging.
- The `preview` job repeats `deploy`'s steps rather than sharing them, because sharing needs a checkout or a reusable workflow. Pinned versions must be updated in both.
- Old previews stay up after a PR closes, because they're harmless for this site and Cloudflare keeps a branch's latest deployment.
- There's no staging environment for now, because this site has no backend, data or integrations for it to test.

## Order of work
1. **Milestone 1: add the diagram.** On `docs/pipeline-diagram`, write the files listed above, verify with `make build`, `make test` and `make lint`, then push and open a PR. CI runs, and the diagram can be seen drawn on GitHub.

   Checkpoint: stop, share the PR, wait for the diagram to be checked and the PR squash-merged.

2. **Milestone 2: set up previews by hand.** The steps under "What needs doing by hand" get done first. Then Claude confirms the environment and secret *names* exist through GitHub's API.

   Checkpoint: stop, report what's confirmed, wait for go-ahead.

3. **Milestone 3: write the preview job locally.** On `ci/preview-deploys`, write the workflow and docs, then commit only the files listed above.
   Verify with `make build`, `make test`, `make lint`, a YAML syntax check and the verifier agent.

   Checkpoint: stop, paste output, wait for go-ahead to push and open a PR.

4. **Milestone 4: prove it on the PR.** Unlike `deploy`, this can be tested before merging, because `preview` runs on the PR itself.
   - Push and open the PR. Confirm `preview` succeeds, and only on the PR run; `deploy` stays skipped.
   - Push a temporary CSS change. Confirm the preview shows it and production doesn't, then revert it.
   - Run `/code-review` and `/security-review`, and report what they find before fixing anything.

   Checkpoint: stop, share run links and review results, wait for the PR to be reviewed and squash-merged.

5. **Milestone 5: confirm production still works.** After the merge, confirm `ci` and `deploy` go green on `main`, `preview` is skipped, and the live site matches `dist/`. Then give the recap and a "break it on purpose" exercise.

   Checkpoint: stop, report results and what to check in a browser, wait for go-ahead before planning slice 4.

## What needs doing by hand
**Never paste a token or account ID into this chat.** Do these before the preview PR is pushed, or the `preview` job will fail with no secrets.

1. **Check the diagram** on GitHub, and squash-merge its PR.
2. **Create a second API token:** in Cloudflare, go to My Profile → API Tokens → Create Token → Custom token. Name it something like `pipelines-intro-preview`. Give it one permission, Account → Cloudflare Pages → Edit, limited to one account.
3. **Create the GitHub environment:** go to Settings → Environments → New environment and name it `preview`. Leave deployment branches unrestricted, because PR runs have to use it.
4. **Add its secrets** under Environment secrets, not variables: `CLOUDFLARE_API_TOKEN` with the new token, and `CLOUDFLARE_ACCOUNT_ID` with the same account ID as before.
5. **Tell Claude when it's done.**
6. **Review and squash-merge the preview PR**, in Milestone 4.

## Risks
- **Preview token reach:** covered in the trade-off above.
- **Malicious PR content:** this runs before a human has approved a merge. Fork PRs are excluded, and same-repo PRs need write access. The guard stops `_worker.js`, but a PR can still publish any static content to its own preview.
- **Public previews:** anyone with the URL can view them, and the addresses are easy to guess. Search engines are told not to index them. That's fine here, but it wouldn't be for an unreleased product, where Cloudflare's access policy would be needed.
- **Old previews stay online:** they keep working after a PR closes, and Cloudflare says a branch's latest deployment can't be deleted. The bad page from a failed experiment could remain reachable.
- **Dependabot PRs:** they don't get environment secrets, so `preview` would fail on one. It isn't a required check, and automatic Dependabot PRs are off.
- **Duplicated steps:** a version bump could update `deploy` and miss `preview`.
- **The diagram can go stale:** nothing checks it automatically. It relies on the `CLAUDE.md` rule and on review.
- **Previews need someone to look:** they don't stop a bad change on their own. Slice 4 adds the automatic check.

## Proof
- The diagram renders on GitHub (checked by eye).
- A PR from this repo gets a working preview at `pr-<number>.pipelines-intro.pages.dev`, with the `noindex` header.
- A temporary CSS change appears on the preview, and not on production.
- `deploy` stays skipped on the PR, and production's files don't change.
- After the merge, `deploy` still publishes and `preview` is skipped on `main`.

**Not proven:** that a fork's PR skips `preview`. Testing that needs a second GitHub account, so it relies on the job's condition and on GitHub withholding secrets from forks.

**Check by hand:** the preview link appears on the PR page, and the preview and live site look right in a browser.

## Next: slice 4, the blank-page test
This gets its own plan and PR once slice 3 is finished, following the bug process: failing test first. It's listed here to show what's coming, and it isn't part of this slice.

**Why the current test missed it:** the test only checks `greet()`. The typo was in the script inside `src/index.html`, which nothing tests and lint doesn't read.

**The likely fix, with no new dependencies:**
- Move the inline script into `src/main.js`, with a `showGreeting(doc)` function. `index.html` loads it with `<script type="module" src="main.js">`.
- Add a test that reads the real `src/index.html`, gives `showGreeting` a stand-in document containing only the IDs found in that file, and checks the greeting gets set. A typo in the ID on either side makes the test fail.
- Also check that the script path in `index.html` points to a real file.

**How to prove it:** repeat the blank-page exercise. The same typo should now turn CI red and block the merge.

**What it still won't catch:** anything that needs a real browser, such as a browser-specific problem or broken CSS. Catching those takes an end-to-end browser test, which the intent lists as out of scope, and that would be its own decision. The preview is the check for those in the meantime.

Slice 4's PR moves how the page loads its script, so its own preview is the right place to confirm the page still works.

## Left alone
- A separate build job and Prettier in CI: possible later PRs.
- A staging environment: a possible later slice, as above.
- Removing old previews automatically.
- The `minimatch` alert in dev dependencies.
- Old merged branches, including `exercise/*`.
