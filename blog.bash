

########## START library core.bash ###########


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


########## START library format_fn.bash ###########


########## START library utils.bash ###########
# description: |
#   Returns the name of the script that's currently 
#   executing, even if the function is called from
#   a sourced library. Only the basename, not the
#   entire path, is returned
# inputs:
#   stdin: null 
#   args: null
# outputs:
#   stdout: null
#   stderr: null
#   return_code:
#     0: "always" 
# tags:
#   - "std"
__blog.core.format_fn.utils.get_parent_script_name() {
  # Get the length of FUNCNAME
  local -i funcname_length
  funcname_length="${#FUNCNAME[@]}" 

  local -i top_level_index
  top_level_index=$(( funcname_length - 1 ))
  printf "%s" "$( basename "${BASH_SOURCE[$top_level_index]}" )"
}
########## END library utils.bash ###########


__blog.format_fn.raw_format_fn() {
  while IFS= read -r line; do
    echo "$line"
  done
}

__blog.format_fn.bracketed_format_fn() {
  local log_level_name
  log_level_name="$1"

  # get parent script's name
  local parent_script_name
  parent_script_name="$(__blog.core.format_fn.utils.get_parent_script_name)"

  while IFS= read -r line; do
    printf "[%s][%5s]: %s\n" "$parent_script_name" "$log_level_name" "$line"
  done
}
########## END library format_fn.bash ###########


__blog.core.log() {
  local log_level_name
  log_level_name="$1"

  # use defualt format fn if not set
  if ! __blog.format.is_format_fn_set; then
    __blog.format.set_format_function "$(__blog.core.default_format_fn)"
  fi

  # use default destination fd if not set
  if ! __blog.write.is_destination_fd_set; then
    __blog.write.set_destination_fd "$(__blog.core.default_destination_fd)"
  fi

  # use default log level if level is not set
  if ! __blog.filter.is_level_set; then
    __blog.filter.set_level "$(__blog.core.default_level)"
  fi

  local log_level_int
  log_level_int="$(__blog.core.get_log_level_int "$log_level_name")"

  while IFS= read -r log_line; do
    echo "$log_line" \
      | __blog.filter.filter "$log_level_int" \
      | __blog.format.format "$log_level_int" \
      | __blog.write.write
  done
}


__blog.core.default_format_fn() {
  echo "__blog.core.bracketed_format_fn"
}

__blog.core.default_level() {
  echo "2" # warn
}

__blog.core.default_destination_fd() {
  echo "2" # stderr
}


__blog.core.get_log_level_name() {
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

__blog.core.get_log_level_int() {
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



__blog.core.set_level() {
  local log_level_name
  log_level_name="$1"
  local log_level_int
  log_level_int="$(__blog.core.get_log_level_int "$log_level_name")"
  __blog.filter.set_level "$log_level_int"
}

__blog.core.set_destination_fd() {
  local destination_fd
  destination_fd="$1"
  __blog.write.set_destination_fd "$destination_fd"
}

__blog.core.raw_format_fn() {
  # normalize log level to name
  local log_level
  log_level="$1"
  local log_level_name
  log_level_name="$(__blog.core.get_log_level_name "$log_level")"

  # pass log level name to format function
  __blog.format_fn.raw_format_fn  "$log_level_name"
}

__blog.core.bracketed_format_fn() {
  # normalize log level to name
  local log_level
  log_level="$1"
  local log_level_name
  log_level_name="$(__blog.core.get_log_level_name "$log_level")"

  # pass log level name to format function
  __blog.format_fn.bracketed_format_fn "$log_level_name"
}

__blog.core.set_format_bracketed() {
  __blog.format.set_format_function "__blog.core.bracketed_format_fn"
}

__blog.core.set_format_raw() {
  __blog.format.set_format_function "__blog.core.raw_format_fn"
}
########## END library core.bash ###########


blog.set_level_debug() {
  __blog.core.set_level "DEBUG"
}

blog.set_level_info() {
  __blog.core.set_level "INFO"
}

blog.set_level_warn() {
  __blog.core.set_level "WARN"
}

blog.set_level_error() {
  __blog.core.set_level "ERROR"
}

blog.set_level_fatal() {
  __blog.core.set_level "FATAL"
}

blog.debug() {
  __blog.core.log "DEBUG"
}

blog.info() {
  __blog.core.log "INFO"
}

blog.warn() {
  __blog.core.log "WARN"
}

blog.error() {
  __blog.core.log "ERROR"
}

blog.fatal() {
  __blog.core.fatal "FATAL"
}

blog.set_format_raw() {
  __blog.core.set_format_raw
}

blog.set_format_bracketed() {
  __blog.core.set_format_bracketed
}
