# Plan: slice 1, CI only

<!-- Current slice only. Old plans live in git history and their PRs. -->

## Context
Lint, tests and the build only run when someone remembers to run them. This slice makes GitHub run all three on every push and pull request (PR), and show the result. It covers R1 to R4 in `docs/spec.md`. Deploys come in slices 2 and 3.

Status: plan approved; the repo is public. Milestone 1 is done; Milestone 2 is in progress.

## The terms, in plain English
| Term | Meaning | In this slice | Azure DevOps equivalent |
|---|---|---|---|
| **Workflow** | An automated process, written as a YAML file in the repo | `.github/workflows/ci.yml`, named "CI" | Pipeline |
| **Trigger** | The event that starts a workflow | A push or a PR | `trigger` and `pr` |
| **Job** | A group of steps that run together on one machine | One job, `ci` | Job |
| **Step** | One task in a job, run in order. If one fails, the rest are skipped by default | Six, listed below | Step |
| **Runner** | The temporary machine that runs a job, wiped afterwards | GitHub-hosted Ubuntu | Agent |
| **Action** | A ready-made, reusable step someone has published | `checkout`, `setup-node` | Task |
| **Secret** | An encrypted value, such as a password, that workflows can use and logs mask | None until slice 2 | Secret variable |
| **Environment** | A named deploy target, like "production", that can have its own secrets and approval rules | None until slice 2 | Environment |

## Files that change
- `.github/workflows/ci.yml`: new, described below
- `README.md`: add a CI section; add a checklist item for the required `ci` check
- `docs/decisions.md`: add the decisions below
- `docs/plan.md`: this plan
- `docs/spec.md`, `intent/2026-10-31-ci-cd-pipeline.md`: already written, committed with this slice

`CLAUDE.md` has uncommitted Learning edits. They stay uncommitted and out of this PR, because they're a separate concept.

## What the workflow does
- **Triggers:** every push to any branch, and every PR.
- **Permissions:** read-only access to the repo.
- **Job:** one job, `ci`, on `ubuntu-latest`, with a 10-minute time limit.
- **Steps, in order:**
  1. Download the code (`actions/checkout@v7`)
  2. Install Node 24 (`actions/setup-node@v7`)
  3. `npm ci`, which installs the exact versions in `package-lock.json`
  4. `make lint`
  5. `make test`
  6. `make build`

## Decisions to record in `docs/decisions.md`
- Keep both triggers, as asked, even though a push to a branch with an open PR runs CI twice. The two runs test different things: the branch itself, and the branch merged with `main`.
- CI runs `make`, not npm directly, so it runs exactly what a person runs locally.
- Use Node 24, a supported long-term release within the `engines` range. The local machine has Node 20, which reached end of life in April 2026; it still works here.
- Make the repo public, because branch protection isn't available on a private repo on GitHub Free, and nothing in it is private.
- Harden the public repo: secret scanning and push protection on, Dependabot alerts on (no automatic PRs), only GitHub-owned actions allowed, and approval required for workflow runs from all outside contributors. A leaked secret or untrusted workflow code is the main risk once a repo is public.
- Use one job, so a failure stops the run early and the workflow stays easy to read.
- Don't cache dependencies: the install is small, and it's one less thing to explain or debug.
- Pin GitHub's own actions to major version tags, for readability. Third-party actions that handle secrets, such as `wrangler-action` in slice 2, get pinned to an exact commit, because a moved tag there could expose a secret.
- No Prettier check in CI: the requirement names three commands, and each PR covers one concept. This answers the "revisit when CI lands" note. It could be its own later PR.

## Order of work
1. **Milestone 1: write it locally.** Write the workflow and docs on `ci/github-actions`, then commit only the files listed above.
   Verify with `make build`, `make test`, `make lint`, a YAML syntax check and the verifier agent.

   Checkpoint: stop, paste output, wait for go-ahead to push and open a PR.

2. **Milestone 2: prove it on GitHub.** Push and open the PR. Confirm both the push run and the PR run go green. Push a temporary lint error, confirm the run goes red and the test and build steps are skipped, then revert it. Squash-merging removes the temporary commits from `main`'s history.

   Checkpoint: stop, share the run links and any failing log lines, and wait for the PR to be reviewed and merged.

3. **Milestone 3: confirm on `main`.** After the merge, confirm a run on `main` goes green. Then give the recap and a "break it on purpose" exercise.

   Checkpoint: stop, report the results, wait for go-ahead before planning slice 2.

## What needs doing by hand
**Slice 1, no accounts or secrets needed:**
1. Review and merge the PR.
2. After CI has run at least once, go to Settings → Branches, edit the rule for `main`, turn on "Require status checks to pass", and select `ci`. This is what turns a red CI run from a warning into a block. The rule already requires a PR, with no approvals and no bypassing.

**Slice 2:**
- Before it starts, decide between Cloudflare Pages and Workers (see `docs/spec.md`).
- Create a Cloudflare account and the project.
- Create an API token with only the Cloudflare Pages Edit permission, and find the account ID.
- Add them to GitHub Secrets as `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`. Claude never sees or handles these.
- Add `cloudflare/wrangler-action` to the allowed actions, because the repo currently allows only GitHub-owned ones.

**Slice 3:** nothing new is expected. The slice 3 plan will confirm this.

## Risks
- The runner uses Node 24 and the local machine uses Node 20, so something could pass in one place and fail in the other. A fresh clone passes on Node 20; the first CI run is the first test on Node 24.
- The repo is public, so anyone can read its code, history and PRs, and fork it. A scan of all branches' history and the PR text found no secrets. Going back to private is possible, but anything already copied stays copied. Actions on standard runners is free for public repos.
- PRs from forks can't reach secrets, and workflow runs from all outside contributors need approval.
- `main` already blocks direct pushes, so every change, including this slice, has to go through a PR. Until `ci` is added to the rule, a red run still can't block a merge.
- GitHub can only show a workflow's real behaviour once it's pushed, so the local syntax check proves little.

## Proof
- A green run from a push, and one from a PR.
- A red run from a deliberate lint error, with later steps skipped.
- A green run on `main` after the merge.

**Not proven in CI:** a failing test or build. Test failure is left for the exercise. Each command runs as its own step, and a failing step fails the run the same way.

**Check by hand:** that the PR page shows the `ci` checks, and that branch protection blocks a merge when `ci` is red.

## Left alone
- `npm audit` reports 5 moderate issues, all through ESLint's dev dependencies. The suggested fix would install a very old ESLint (4.0.0), so it isn't one to apply. The site doesn't ship these packages, and CI doesn't run the audit.
- Deploys, previews and Prettier in CI.
- ESP leftovers noted in the previous plan, except the "hardware" wording in `docs/spec.md`, which went when the spec was written.
