#!/usr/bin/env bash


########## START library format.bash ###########
__blog.format.is_format_fn_set() {
  if [[ -n "${__BLOG_FORMAT_FORMAT_FUNCTION:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__blog.format.set_format_function() {
  export __BLOG_FORMAT_FORMAT_FUNCTION="$1"
}

__blog.format.format() {
  format_function="${__BLOG_FORMAT_FORMAT_FUNCTION}"

  local message_log_level
  message_log_level="$1"
  
  while read -r log_line; do
    "$format_function" "$message_log_level" <<<"$log_line"
  done
}
########## END library format.bash ###########


########## START library filter.bash ###########
__blog.filter.is_level_set() {
  if [[ -n "${__BLOG_FILTER_LEVEL:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__blog.filter.set_level() {
  local level
  level="$1"
  export __BLOG_FILTER_LEVEL="$level"
}

__blog.filter.filter() {
  local set_log_level
  set_log_level="${__BLOG_FILTER_LEVEL}"
  
  local message_log_level
  message_log_level="$1"

  while IFS= read -r log_line; do
    if (( message_log_level >= set_log_level )); then
      echo "$log_line"
    fi
  done
}
########## END library filter.bash ###########


########## START library write.bash ###########

__blog.write.get_default_destination_fd() {
  echo "2"
}

__blog.write.is_destination_fd_set() {
  if [[ -n "${__BLOG_WRITE_DESTINATION_FD:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__blog.write.set_destination_fd() {
  __BLOG_WRITE_DESTINATION_FD="$1"
  export __BLOG_WRITE_DESTINATION_FD
}

__blog.write.write() {
  local destination_fd
  destination_fd="${__BLOG_WRITE_DESTINATION_FD}"
  while IFS= read -r log_line; do
    echo "$log_line" >&"$destination_fd"
  done
}
########## END library write.bash ###########


########## START library log.bash ###########
__blog.log() {
  local log_level
  log_level="$1"

  while IFS= read -r log_line; do
    echo "$log_line" \
      | __blog.filter.filter "$log_level" \
      | __blog.format.format "$log_level" \
      | __blog.write.write
  done
}
########## END library log.bash ###########


########## START library format_fn.bash ###########
__blog.format_fn.helper.get_log_level_name() {
  local log_level
  log_level="$1"
  case "$log_level" in
    0)
      echo "DEBUG"
      ;;
    1)
      echo "INFO"
      ;;
    2)
      echo "WARN"
      ;;
    3)
      echo "ERROR"
      ;;
    4)
      echo "FATAL"
      ;;
    *)
      echo "UNKNOWN"
      ;;
  esac
}

__blog.format_fn.raw() {
  while IFS= read -r line; do
    echo "$line"
  done
}

__blog.format_fn.bracketed() {
  local log_level
  log_level="$1"
  local log_level_name
  # shellcheck disable=SC2119
  log_level_name="$(__blog.format_fn.helper.get_log_level_name "$log_level")"
  while IFS= read -r line; do
    printf "[%7s]: %s\n" "$log_level_name" "$line"
  done
}
########## END library format_fn.bash ###########


########## START library helper.bash ###########
__blog.helper.get_log_level_name() {
  local log_level
  log_level="$1"
  case "$log_level" in
    0)
      echo "DEBUG"
      ;;
    1)
      echo "INFO"
      ;;
    2)
      echo "WARN"
      ;;
    3)
      echo "ERROR"
      ;;
    4)
      echo "FATAL"
      ;;
    *)
      echo "UNKNOWN"
      ;;
  esac
}

__blog.helper.get_log_level_int() {
  local log_level_name
  log_level_name="$1"
  case "$log_level_name" in
    DEBUG)
      echo "0"
      ;;
    INFO)
      echo "1"
      ;;
    WARN)
      echo "2"
      ;;
    ERROR)
      echo "3"
      ;;
    FATAL)
      echo "4"
      ;;
    *)
      echo "10000000"
      ;;
  esac
}



########## END library helper.bash ###########


########## START library defaults.bash ###########
#!/usr/bin/env bash

__blog.defaults.format_fn() {
  echo "__blog.format_fn.bracketed"
}

__blog.defaults.level() {
  echo "2" # warn
}

__blog.defaults.destination_fd() {
  echo "2" # stderr
}
########## END library defaults.bash ###########



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
  __blog.format.set_format_function "__blog.format_fn.raw"
}

blog.set_format_bracketed() {
  __blog.format.set_format_function "__blog.format_fn.bracketed"
}
