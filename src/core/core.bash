

########## START library filter.bash ###########
__log.core.filter.is_level_set() {
  if [[ -n "${__BLOG_FILTER_LEVEL:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__log.core.filter.set_level() {
  local level
  level="$1"
  export __BLOG_FILTER_LEVEL="$level"
}

__log.core.filter.filter() {
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
__log.core.format.is_format_fn_set() {
  if [[ -n "${__BLOG_FORMAT_FORMAT_FUNCTION:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__log.core.format.set_format_function() {
  export __BLOG_FORMAT_FORMAT_FUNCTION="$1"
}

__log.core.format.format() {
  format_function="${__BLOG_FORMAT_FORMAT_FUNCTION}"

  local message_log_level
  message_log_level="$1"
  
  while read -r log_line; do
    "$format_function" "$message_log_level" <<<"$log_line"
  done
}
########## END library format.bash ###########


########## START library write.bash ###########

__log.core.write.get_default_destination_fd() {
  echo "2"
}

__log.core.write.is_destination_fd_set() {
  if [[ -n "${__BLOG_WRITE_DESTINATION_FD:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__log.core.write.set_destination_fd() {
  __BLOG_WRITE_DESTINATION_FD="$1"
  export __BLOG_WRITE_DESTINATION_FD
}

__log.core.write.write() {
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
__log.core.format_fn.utils.get_parent_script_name() {
  # Get the length of FUNCNAME
  local -i funcname_length
  funcname_length="${#FUNCNAME[@]}" 

  local -i top_level_index
  top_level_index=$(( funcname_length - 1 ))
  printf "%s" "$( basename "${BASH_SOURCE[$top_level_index]}" )"
}
########## END library utils.bash ###########


__log.format_fn.raw_format_fn() {
  while IFS= read -r line; do
    echo "$line"
  done
}

__log.format_fn.bracketed_format_fn() {
  local log_level_name
  log_level_name="$1"

  # get parent script's name
  local parent_script_name
  parent_script_name="$(__log.core.format_fn.utils.get_parent_script_name)"

  while IFS= read -r line; do
    printf "[%s][%5s]: %s\n" "$parent_script_name" "$log_level_name" "$line"
  done
}
########## END library format_fn.bash ###########


__log.core.log() {
  local log_level_name
  log_level_name="$1"

  # use defualt format fn if not set
  if ! __log.core.format.is_format_fn_set; then
    __log.core.format.set_format_function "$(__log.core.default_format_fn)"
  fi

  # use default destination fd if not set
  if ! __log.core.write.is_destination_fd_set; then
    __log.core.write.set_destination_fd "$(__log.core.default_destination_fd)"
  fi

  # use default log level if level is not set
  if ! __log.core.filter.is_level_set; then
    __log.core.filter.set_level "$(__log.core.default_level)"
  fi

  local log_level_int
  log_level_int="$(__log.core.get_log_level_int "$log_level_name")"

  while IFS= read -r log_line; do
    echo "$log_line" \
      | __log.core.filter.filter "$log_level_int" \
      | __log.core.format.format "$log_level_int" \
      | __log.core.write.write
  done
}


__log.core.default_format_fn() {
  echo "__log.core.bracketed_format_fn"
}

__log.core.default_level() {
  echo "2" # warn
}

__log.core.default_destination_fd() {
  echo "2" # stderr
}


__log.core.get_log_level_name() {
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

__log.core.get_log_level_int() {
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



__log.core.set_level() {
  local log_level_name
  log_level_name="$1"
  local log_level_int
  log_level_int="$(__log.core.get_log_level_int "$log_level_name")"
  __log.core.filter.set_level "$log_level_int"
}

__log.core.set_destination_fd() {
  local destination_fd
  destination_fd="$1"
  __log.core.write.set_destination_fd "$destination_fd"
}

__log.core.raw_format_fn() {
  # normalize log level to name
  local log_level
  log_level="$1"
  local log_level_name
  log_level_name="$(__log.core.get_log_level_name "$log_level")"

  # pass log level name to format function
  __log.format_fn.raw_format_fn  "$log_level_name"
}

__log.core.bracketed_format_fn() {
  # normalize log level to name
  local log_level
  log_level="$1"
  local log_level_name
  log_level_name="$(__log.core.get_log_level_name "$log_level")"

  # pass log level name to format function
  __log.format_fn.bracketed_format_fn "$log_level_name"
}

__log.core.set_format_bracketed() {
  __log.core.format.set_format_function "__log.core.bracketed_format_fn"
}

__log.core.set_format_raw() {
  __log.core.format.set_format_function "__log.core.raw_format_fn"
}
