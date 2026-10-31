# One place for every command Claude and you run.
# Each target calls an npm script; package.json holds the real commands.

.PHONY: build test lint

build:
	@npm run --silent build

test:
	@npm test --silent

lint:
	@npm run --silent lint
