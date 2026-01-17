#!/usr/bin/env bash

source format.bash
source filter.bash
source write.bash
source log.bash
source defaults.bash


__blog.interface.log() {
  if ! __blog.format.is_format_fn_set; then
    __blog.format.set_format_function "$(__blog.defaults.format_fn)"
  fi

  if ! __blog.filter.is_level_set; then
    __blog.filter.set_level "$(__blog.defaults.level)"
  fi

  if ! __blog.write.is_destination_fd_set; then
    __blog.write.set_destination_fd "$(__blog.defaults.destination_fd)"
  fi

  local log_level_name
  log_level_name="$1"
  local log_level_int
  log_level_int="$(__blog.helper.get_log_level_int "$log_level_name")"
  __blog.log "$log_level_int"
}

__blog.interface.set_level() {
  local log_level_name
  log_level_name="$1"
  local log_level_int
  log_level_int="$(__blog.helper.get_log_level_int "$log_level_name")"
  __blog.filter.set_level "$log_level_int"
}

blog.set_level_debug() {
  __blog.interface.set_level "DEBUG"
}

blog.debug() {
  __blog.interface.log "DEBUG"
}

blog.set_level_info() {
  __blog.interface.set_level "INFO"
}

blog.info() {
  __blog.interface.log "INFO"
}

blog.set_level_warn() {
  __blog.interface.set_level "WARN"
}

blog.warn() {
  __blog.interface.log "WARN"
}

blog.set_level_error() {
  __blog.interface.set_level "ERROR"
}

blog.error() {
  __blog.interface.log "ERROR"
}

blog.set_level_fatal() {
  __blog.interface.set_level "FATAL"
}

blog.fatal() {
  __blog.interface.log "FATAL"
}

blog.set_level_off() {
  # find the largest integer
  # representable in this bash session
  local -i maxint=1 
  while :; do 
    next=$((maxint * 2)) 
    (( next > maxint )) || break 
    maxint=$next 
  done 

  # set the log level to maxint
  __blog.filter.set_level "$maxint"
}

blog.set_format_raw() {
  __blog.format.set_format_function "__blog.log.raw_format_fn"
}

blog.set_format_bracketed() {
  __blog.format.set_format_function "__blog.log.bracketed_format_fn"
}
