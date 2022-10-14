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


# Unset CDPATH so that path interpolation can work correctly
unset CDPATH

# Until all GOPATH references are removed from all build scripts as well,
# explicitly disable module mode to avoid picking up user-set GO111MODULE preferences.
# As individual scripts (like hack/update-vendor.sh) make use of go modules,
# they can explicitly set GO111MODULE=on
export GO111MODULE=off

# The root of the build/dist directory
GRS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)"

GRS_OUTPUT_SUBPATH="${GRS_OUTPUT_SUBPATH:-_output/local}"
GRS_OUTPUT="${GRS_ROOT}/${GRS_OUTPUT_SUBPATH}"
GRS_OUTPUT_BINPATH="${GRS_OUTPUT}/bin"

# Set no_proxy for localhost if behind a proxy, otherwise,
# the connections to localhost in scripts will time out
export no_proxy="127.0.0.1,localhost${no_proxy:+,${no_proxy}}"

# This is a symlink to binaries for "this platform", e.g. build tools.
export THIS_PLATFORM_BIN="${GRS_ROOT}/_output/bin"

source "${GRS_ROOT}/hack/lib/util.sh"
source "${GRS_ROOT}/hack/lib/logging.sh"

grs::log::install_errexit
grs::util::ensure-bash-version

source "${GRS_ROOT}/hack/lib/redis.sh"

