# One place for every command Claude and you run.
# Replace each TODO with the real command for your toolchain.
# Targets fail loudly until configured, so Claude never mistakes a stub for a pass.
#
# PlatformIO example:   build: pio run       flash: pio run -t upload
# ESP-IDF example:      build: idf.py build  flash: idf.py flash

.PHONY: build test lint flash

build:
	@echo "make build: not configured yet - edit the Makefile" && exit 1

test:
	@sh test/smoke.sh

lint:
	@echo "make lint: not configured yet - edit the Makefile (e.g. clang-format --dry-run --Werror src/*)" && exit 1

flash:
	@echo "make flash: not configured yet - edit the Makefile" && exit 1
