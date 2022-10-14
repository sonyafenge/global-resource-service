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

# A set of helpers for starting/running redis for tests

REDIS_VERSION=${REDIS_VERSION:-7.0.0}
REDIS_HOST=${REDIS_HOST:-127.0.0.1}
REDIS_PORT=${REDIS_PORT:-7379}


grs::redis::validate() {
  # validate if in path
  command -v redis-cli >/dev/null || {
    grs::log::usage "redis must be in your PATH"
    grs::log::info "You can use 'hack/redis-install.sh' to install redis."
    exit 1
  }

:<<'EOF'
  # validate redis port is free
  local port_check_command
  if command -v ss &> /dev/null && ss -Version | grep 'iproute2' &> /dev/null; then
    port_check_command="ss"
  elif command -v netstat &>/dev/null; then
    port_check_command="netstat"
  else
    grs::log::usage "unable to identify if redis is bound to port ${REIDS_PORT}. unable to find ss or netstat utilities."
    exit 1
  fi
  if ${port_check_command} -nat | grep "LISTEN" | grep "[\.:]${REDIS_PORT:?}" >/dev/null 2>&1; then
    grs::log::usage "unable to start redis as port ${REDIS_PORT} is in use. please stop the process listening on this port and retry."
    grs::log::usage "$(netstat -nat | grep "[\.:]${REDIS_PORT:?} .*LISTEN")"
    exit 1
  fi
EOF
}

grs::redis::version() {
  printf '%s\n' "${@}" | awk -F . '{ printf("%d%03d%03d\n", $1, $2, $3) }'
}

grs::redis::start() {
  # validate before running
  grs::redis::validate

  # Start redis
  sudo systemctl start redis-server
}

grs::redis::flushall() {
  #flushall date in Redis
  redis-cli -p $REDIS_PORT flushall
}


grs::redis::stop() {
  # Stop redis
    sudo systemctl stop redis-server
}
