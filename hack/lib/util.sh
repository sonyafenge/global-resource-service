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


function ssh-config {
        local cmd="$1"
        local machine_name="$2"
        local zone="$3"
        gcloud compute ssh \
        "${machine_name}" \
        --ssh-flag="-o LogLevel=quiet" \
        --ssh-flag="-o ConnectTimeout=30" \
        --project "${PROJECT}" \
        --zone "${zone}" \
        --command "${cmd}" \
        --quiet &
}

# grs::util::ensure-bash-version
# Check if we are using a supported bash version
#
function grs::util::ensure-bash-version {
  # shellcheck disable=SC2004
  if ((${BASH_VERSINFO[0]}<4)) || ( ((${BASH_VERSINFO[0]}==4)) && ((${BASH_VERSINFO[1]}<2)) ); then
    echo "ERROR: This script requires a minimum bash version of 4.2, but got version of ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}"
    if [ "$(uname)" = 'Darwin' ]; then
      echo "On macOS with homebrew 'brew install bash' is sufficient."
    fi
    exit 1
  fi
}