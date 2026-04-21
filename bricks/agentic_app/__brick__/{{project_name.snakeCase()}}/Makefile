FLAVOR ?= prod
TARGET ?= firebase

.PHONY: gen test build clean setup format lint release ci-check run verify release-preflight

gen:
	./tools/gen.sh

test:
	./tools/test.sh

build:
	./tools/build.sh

clean:
	./tools/clean.sh

setup:
	./tools/setup.sh

run:
	./tools/run.sh $(FLAVOR)

verify:
	./tools/verify.sh

format:
	./tools/format.sh

lint:
	./tools/lint.sh

release:
	./tools/release.sh

release-preflight:
	./tools/release-preflight.sh $(FLAVOR) $(TARGET)

ci-check:
	./tools/ci-check.sh
