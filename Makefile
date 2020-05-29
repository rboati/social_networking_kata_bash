
VERSION := 0.1.0

# GNU Makefile Conventions
# See https://www.gnu.org/prep/standards/html_node/Makefile-Conventions.html

SHELL := /bin/bash
.SUFFIXES:
prefix ?= "$(HOME)/.local"
DESTDIR ?= ""

.PHONY: all
all: build

.PHONY: mostlyclean
mostlyclean:
	rm -rf build dist

.PHONY: clean
clean: mostlyclean
	rm -rf src/lib test/lib

.PHONY: distclean
distclean: clean

.PHONY: maintainer-clean
maintainer-clean::
	@echo 'This command is intended for maintainers to use; it'
	@echo 'deletes files that may need special tools to rebuild.'
	rm -rf lib/bashlibs
	rm -r lib
maintainer-clean:: distclean

.PHONY: install
install: build
	mkdir -p "$(DESTDIR)$(prefix)"
	cp -r -t "$(DESTDIR)$(prefix)" build/bin build/share

.PHONY: uninstall
uninstall:
	rm -rf "$(DESTDIR)$(prefix)/share/social_networking_kata"
	rm -f "$(DESTDIR)$(prefix)/bin/social_networking_kata"

.PHONY: dist
dist: clean build | dist/.
	tar czf "dist/social_networking_kata-$(VERSION).tar.gz" --owner=0 --group=0 -C build bin share

.PHONY: check
check: test

# end GNU Makefile Conventions


BASHLIBS_FILES := libimport.bash libassert.bash libloglevel.bash
SRC_FILES := $(shell find src -type f) $(patsubst %, src/lib/%, $(BASHLIBS_FILES))
BUILD_FILES := $(patsubst src/%.bash, build/share/social_networking_kata/%.bash, $(SRC_FILES))
SRC_DIRS := $(dir $(SRC_FILES))
BUILD_DIRS := $(patsubst src/%, build/share/social_networking_kata/%, $(SRC_DIRS))

.PHONY: build
build: update-src-lib
build: $(BUILD_FILES)
build: build/bin/social_networking_kata


build/share/social_networking_kata/%.bash: src/%.bash  | $(BUILD_DIRS:=/.)
	cp "$<" "$@"

build/bin/social_networking_kata: build/share/social_networking_kata/main.bash | build/bin/.
	 ln -s -f -T ../share/social_networking_kata/main.bash "$@"


.PRECIOUS: %/.
%/.:
	mkdir -p "$(@D)"

.PRECIOUS: lib/bashlibs/%

lib/bashlibs:
	git clone git@github.com:rboati/bashlibs.git lib/bashlibs

lib/bashlibs/%: lib/bashlibs;

src/lib/lib%.bash: lib/bashlibs/lib%.bash | src/lib/.
	cp "$<" "$@"

test/lib/lib%.bash: lib/bashlibs/lib%.bash | test/lib/.
	cp "$<" "$@"


.PHONY: update-src-lib
update-src-lib: $(patsubst %, src/lib/%, $(BASHLIBS_FILES))

.PHONY: update-test-lib
update-test-lib: update-src-lib
update-test-lib: test/lib/libtest.bash

.PHONY: run
run: update-src-lib
	@bash src/main.bash

.PHONY: test
test: update-test-lib
	@bash ./test/run_tests.bash

