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

CLEAN_PATTERNS=(
  "_tmp"
  "doc_tmp"
)

for pattern in "${CLEAN_PATTERNS[@]}"; do
  while IFS=$'\n' read -r match; do
    echo "Removing ${match#${GRS_ROOT}\/} .."
    rm -rf "${match#${GRS_ROOT}\/}"
  done <   <(find "${GRS_ROOT}" -iregex "^${GRS_ROOT}/${pattern}$")
done
