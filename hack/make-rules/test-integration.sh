#!/usr/bin/env bash
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

set -o errexit
set -o nounset
set -o pipefail

GRS_ROOT=$(dirname "${BASH_SOURCE[0]}")/../..
source "${GRS_ROOT}/hack/lib/init.sh"

GRS_GO_PACKAGE="${GRS_GO_PACKAGE:-"global-resource-service/resource-management"}"
export GRS_GO_PACKAGE

# start the cache mutation detector by default so that cache mutators will be found
GRS_CACHE_MUTATION_DETECTOR="${GRS_CACHE_MUTATION_DETECTOR:-true}"
export GRS_CACHE_MUTATION_DETECTOR

# panic the server on watch decode errors since they are considered coder mistakes
GRS_PANIC_WATCH_DECODE_ERROR="${GRS_PANIC_WATCH_DECODE_ERROR:-true}"
export GRS_PANIC_WATCH_DECODE_ERROR

GRS_INTEGRATION_TEST_MAX_CONCURRENCY=${GRS_INTEGRATION_TEST_MAX_CONCURRENCY:-"-1"}
GRS_INTEGRAYION_TEST_PATH=${GRS_INTEGRAYION_TEST_PATH:-"resource-management"}
if [[ ${GRS_INTEGRATION_TEST_MAX_CONCURRENCY} -gt 0 ]]; then
  GOMAXPROCS=${GRS_INTEGRATION_TEST_MAX_CONCURRENCY}
  export GOMAXPROCS
  grs::log::status "Setting parallelism to ${GOMAXPROCS}"
fi

# Give integration tests longer to run by default.
GRS_TIMEOUT=${GRS_TIMEOUT:--timeout=600s}
LOG_LEVEL=${LOG_LEVEL:-3}
GRS_TEST_ARGS=${GRS_TEST_ARGS:-}
# Default glog module settings.
GRS_TEST_VMODULE=${GRS_TEST_VMODULE:-"garbagecollector*=6,graph_builder*=6"}

grs::test::find_integration_test_dirs() {
  (
    GRS_GO_INTEGRATION_PACKAGE="${GRS_GO_PACKAGE}/${GRS_INTEGRAYION_TEST_PATH}"
    cd "${GRS_ROOT}/${GRS_INTEGRAYION_TEST_PATH}"
    find test/integration/ -name '*_test.go' -print0 \
      | xargs -0n1 dirname | sed "s|^|${GRS_GO_INTEGRATION_PACKAGE}/|" \
      | LC_ALL=C sort -u
  )
}

CLEANUP_REQUIRED=
cleanup() {
  if [[ -z "${CLEANUP_REQUIRED}" ]]; then
    return
  fi
  grs::log::status "flushall redis"
  grs::redis::flushall
  CLEANUP_REQUIRED=
  grs::log::status "Integration test cleanup complete"
}

runTests() {
  grs::log::status "Starting redis server"
  CLEANUP_REQUIRED=1
  grs::redis::start
  grs::log::status "Running integration test cases"

  ###Debugging code
  echo "Debugging: WHAT1=$(grs::test::find_integration_test_dirs | paste -sd' ' -)"
  echo "Debugging: GRS_ROOT: ${GRS_ROOT}"
  make -C "${GRS_ROOT}" test \
      WHAT="${WHAT:-$(grs::test::find_integration_test_dirs | paste -sd' ' -)}" \
      GOFLAGS="${GOFLAGS:-}" \
      GRS_TEST_ARGS="${SHORT:--short=true} --vmodule=${GRS_TEST_VMODULE} ${GRS_TEST_ARGS:-}" \
      GRS_TIMEOUT="${GRS_TIMEOUT}" \
      KUBE_RACE=""

  cleanup
}

checkRedisOnPath() {
  grs::log::status "Checking redis is on PATH"
  which redis-cli && return
  grs::log::status "Cannot find redis-cli, cannot run integration tests."
  grs::log::usage "You can use 'hack/redis-install.sh' to install redis."
  return 1
}

checkRedisOnPath

# Run cleanup to stop redis on interrupt or other kill signal.
trap cleanup EXIT

runTests
