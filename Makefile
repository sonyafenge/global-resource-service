#
# Copyright 2022 Authors of Global Resource Service.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

DBG_MAKEFILE ?=
ifeq ($(DBG_MAKEFILE),1)
    $(warning ***** starting Makefile for goal(s) "$(MAKECMDGOALS)")
    $(warning ***** $(shell date))
else
    # If we're not debugging the Makefile, don't echo recipes.
    MAKEFLAGS += -s
endif


#
# Commonly used targets (see each target for more information):
#   all: Build code.
#   test: Run tests.
#   clean: Clean up.

# It's necessary to set this because some environments don't link sh -> bash.
SHELL := /usr/bin/env bash -o errexit -o pipefail -o nounset
BASH_ENV := ./hack/lib/logging.sh

# Define variables so `make --warn-undefined-variables` works.
PRINT_HELP ?=

# We don't need make's built-in rules.
MAKEFLAGS += --no-builtin-rules
# Be pedantic about undefined variables.
MAKEFLAGS += --warn-undefined-variables
.SUFFIXES:

# Constants used throughout.
.EXPORT_ALL_VARIABLES:
OUT_DIR ?= _output
BIN_DIR := $(OUT_DIR)/bin
PRJ_SRC_PATH := global-resource-service

define ALL_HELP_INFO
# Build code.
#
# Args:
#   WHAT: Directory names to build.  If any of these directories has a 'main'
#     package, the build will produce executable files under $(OUT_DIR)/bin.
#     If not specified, "everything" will be built.
#     "vendor/<module>/<path>" is accepted as alias for "<module>/<path>".
#     "ginkgo" is an alias for the ginkgo CLI.
#   GOFLAGS: Extra flags to pass to 'go' when building.
#   GOLDFLAGS: Extra linking flags passed to 'go' when building.
#   GOGCFLAGS: Additional go compile flags passed to 'go' when building.
#   DBG: If set to "1", build with optimizations disabled for easier
#     debugging.  Any other value is ignored.
#
# Example:
#   make
#   make all
#   make all WHAT=cmd/kubelet GOFLAGS=-v
#   make all DBG=1
#     Note: Specify DBG=1 for building unstripped binaries, which allows you to use code debugging
#           tools like delve. When DBG is unspecified, it defaults to "-s -w" which strips debug
#           information.
endef
.PHONY: all
ifeq ($(PRINT_HELP),y)
all:
	echo "$$ALL_HELP_INFO"
else
all:
	hack/make-rules/build.sh $(WHAT)
endif

define TEST_HELP_INFO
# Build and run tests.
#
# Args:
#   WHAT: Directory names to test.  All *_test.go files under these
#     directories will be run.  If not specified, "everything" will be tested.
#   TESTS: Same as WHAT.
#   GOFLAGS: Extra flags to pass to 'go' when building.
#   GOLDFLAGS: Extra linking flags to pass to 'go' when building.
#   GOGCFLAGS: Additional go compile flags passed to 'go' when building.
#
# Example:
#   make test
#   make test WHAT=./resource-management/pkg/distributor GOFLAGS=-v
endef
.PHONY: test
ifeq ($(PRINT_HELP),y)
test:
	echo "$$TEST_HELP_INFO"
else
check test:
	hack/make-rules/test.sh $(WHAT) $(TESTS)
endif

define TEST_IT_HELP_INFO
# Build and run integration tests.
#
# Args:
#   WHAT: Directory names to test.  All *_test.go files under these
#     directories will be run.  If not specified, "everything" will be tested.
#
# Example:
#   make test-integration
endef
.PHONY: test-integration
ifeq ($(PRINT_HELP),y)
test-integration:
	echo "$$TEST_IT_HELP_INFO"
else
test-integration:
	hack/make-rules/test-integration.sh $(WHAT)
endif


define CLEAN_HELP_INFO
# Remove all build artifacts.
#
# Example:
#   make clean
endef
.PHONY: clean
ifeq ($(PRINT_HELP),y)
clean:
	echo "$$CLEAN_HELP_INFO"
else
clean:
	build/make-clean.sh
	hack/make-rules/clean.sh
endif

define HELP_INFO
# Print make targets and help info
#
# Example:
# make help
endef
.PHONY: help
ifeq ($(PRINT_HELP),y)
help:
	echo "$$HELP_INFO"
else
help:
	hack/make-rules/help.sh
endif

