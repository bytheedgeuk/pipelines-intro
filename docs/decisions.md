# Decisions

One line per decision: date, what, why. Newest at the bottom.

- 2026-10-31: Build is a plain copy of `src/` to `dist/` because a page this small needs no bundler, and `dist/` still gives a deployable artefact.
- 2026-10-31: Tests use Node's built-in `node:test` because it adds no dependency to maintain.
- 2026-10-31: `make` calls npm scripts because `make` is the stable interface and `package.json` holds the real commands.
- 2026-10-31: Linter is ESLint with recommended rules; Prettier runs through the format hook only, because lint was scoped to one linter. Revisit when CI lands.
- 2026-10-31: Claude's npm permission allows four exact commands, not `npm *`, because `npm exec` can run anything and could get around other permission rules.
- 2026-10-31: Host is Cloudflare Pages, not Vercel, because Vercel's free plan is non-commercial only and Vercel's guidance is that you usually don't need GitHub Actions on top of it. To be rechecked before slice 2, because Cloudflare's docs now say to start new projects with Workers.
- 2026-10-31: Deploys will use GitHub Actions with Direct Upload, not Cloudflare's Git integration, because that keeps every stage in one pipeline and makes deploys wait for CI. A Direct Upload project can't switch to Git integration later.
- 2026-10-31: The repo is public because branch protection isn't available on a private repo on GitHub Free, and nothing in it is private.
- 2026-10-31: The public repo is hardened with secret scanning and push protection, Dependabot alerts (no automatic PRs), GitHub-owned actions only, and approval for workflow runs from all outside contributors, because a leaked secret or untrusted workflow code is the main risk.
- 2026-10-31: CI runs on both push and pull request, as asked, even though a push to a branch with an open PR runs it twice, because the runs test different things: the branch itself, and the branch merged with `main`.
- 2026-10-31: CI runs `make`, not npm directly, so it runs exactly what a person runs locally.
- 2026-10-31: CI uses Node 24 because it's a supported long-term release within the `engines` range. Node 20 still works locally but reached end of life in April 2026.
- 2026-10-31: CI is one job, so a failure stops the run early and the workflow stays easy to read.
- 2026-10-31: CI doesn't cache dependencies because the install is small, and it's one less thing to explain or debug.
- 2026-10-31: GitHub's own actions are pinned to major version tags, for readability. Third-party actions that handle secrets get pinned to an exact commit, because a moved tag there could expose a secret.
- 2026-10-31: CI has no Prettier check because the requirement names three commands and each PR covers one concept. This answers the "revisit when CI lands" note above; it could be its own later PR.
