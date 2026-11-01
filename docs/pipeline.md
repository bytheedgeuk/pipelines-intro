# Pipeline

How a change gets onto the live website. Any PR that changes the workflow updates this page too, so the PR shows what changed.

## In plain English

```mermaid
flowchart TD
    change["1. Someone changes the website and asks for it to be added"]:::person
    checks["2. Automatic checks: is the code tidy, do the tests pass, does the site build?"]:::auto
    merge["3. A person looks at the result and adds the change"]:::person
    recheck["4. The same checks run again automatically"]:::auto
    safety["5. Final automatic safety check, then the website is published"]:::auto
    live["The live website is updated"]:::good
    stop1["Stopped: the change can't be added until it's fixed"]:::bad
    stop2["Stopped: the live website stays as it was"]:::bad

    change --> checks
    checks -- "All pass" --> merge
    checks -- "Something fails" --> stop1
    stop1 -- "Fix it and try again" --> change
    merge --> recheck
    recheck -- "All pass" --> safety
    recheck -- "Something fails" --> stop2
    safety -- "All clear" --> live
    safety -- "Something's wrong" --> stop2

    classDef person fill:#cfe2ff,stroke:#1f5fbf,color:#10233f
    classDef auto fill:#e6e9ee,stroke:#566274,color:#18212f
    classDef good fill:#cdeccf,stroke:#2b7a34,color:#10301a
    classDef bad fill:#f9d3cf,stroke:#b3362b,color:#3f1410
```

**Blue:** done by a person. **Grey:** happens automatically. **Green:** the result. **Red:** stopped, and nothing reaches the live website.

The main idea is that nothing goes live unless the automatic checks pass, and nobody can skip them, including the repo owner.

## Plain words and technical terms

| In plain English | The technical term |
|---|---|
| Asking for a change to be added | Opening a pull request (PR) |
| The automatic checks | The `ci` job: `make lint`, `make test`, `make build` |
| Adding the change | Squash-merging the PR into `main` |
| Is the code tidy? | Lint |
| Do the tests pass? | Unit tests |
| Does the site build? | The build, which creates `dist/` |
| Final safety check | Refusing `dist/_worker.js` |
| Publishing the website | The `deploy` job uploading to Cloudflare Pages |

## In technical terms

```mermaid
flowchart TD
    push["Push to any branch"] --> ci
    pr["Pull request"] --> ci

    subgraph ciJob["ci job: no secrets, read-only access"]
        ci["Download code, install Node 24, npm ci"] --> lint["make lint"]
        lint --> test["make test"]
        test --> build["make build"]
        build --> isMain{"Push to main?"}
        isMain -- "Yes" --> save["Save dist/ as an artifact"]
    end

    isMain -- "No" --> stop["Finished: deploy is skipped"]
    save --> download

    subgraph deployJob["deploy job: production environment, main only"]
        download["Download dist/"] --> guard{"dist/_worker.js exists?"}
        guard -- "Yes" --> refuse["Stop: deploy fails"]
        guard -- "No" --> wrangler["Install Node 24 and Wrangler"]
        wrangler --> publish["Publish with the Cloudflare token"]
    end

    publish --> live["Live site: pipelines-intro.pages.dev"]
```

A failure at any step stops the run, and later steps and jobs don't run. "Save dist/" is the last step of the `ci` job, so `deploy` only starts if all of `ci` passed.

### What runs when

| Event | `ci` | Save `dist/` | `deploy` |
|---|---|---|---|
| Push to a branch | Runs as `ci (push)` | Skipped | Skipped |
| Pull request | Runs as `ci (pull_request)`, on the branch merged with `main` | Skipped | Skipped |
| Merge to `main` | Runs as `ci (push)` | Runs | Runs if `ci` passed |

### Rules around the pipeline

These are repo settings, not part of the workflow file:

- **`main`:** needs a PR and a passing `ci (pull_request)` check, with the branch up to date and no bypassing. Only squash-merging is allowed.
- **`production` environment:** holds `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID`, and only `main` can use it, with no admin bypass.
- **Allowed actions:** GitHub-owned ones, plus `cloudflare/wrangler-action`.
- **Fork PRs:** workflow runs need approval, and they get no secrets.
