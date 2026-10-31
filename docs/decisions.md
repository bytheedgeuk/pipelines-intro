# Decisions

One line per decision: date, what, why. Newest at the bottom.

- 2026-10-31: Build is a plain copy of `src/` to `dist/` because a page this small needs no bundler, and `dist/` still gives a deployable artefact.
- 2026-10-31: Tests use Node's built-in `node:test` because it adds no dependency to maintain.
- 2026-10-31: `make` calls npm scripts because `make` is the stable interface and `package.json` holds the real commands.
- 2026-10-31: Linter is ESLint with recommended rules; Prettier runs through the format hook only, because lint was scoped to one linter. Revisit when CI lands.
