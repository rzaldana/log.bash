
source filter/filter.bash
source format/format.bash
source write/write.bash
source utils/utils.bash 

__log.core.log() {
  local log_level_name
  log_level_name="$1"

  # use default format fn if not set
  if ! __log.core.is_format_fn_set; then
    __log.core.set_format_fn "$(__log.core.default_format_fn)"
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
  if ! __log.core.utils.date.is_date_installed; then
    echo "log.bash: WARNING: 'date' command is not available. Omitting timestamp from logs" >&2
    echo "__log.core.bracketed_format_fn_no_date"
  else
    echo "__log.core.bracketed_format_fn"
  fi
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

__log.core.is_format_fn_set() {
  if [[ -n "${__LOG_CORE_FORMAT_FUNCTION:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__log.core.set_format_fn() {
  export __LOG_CORE_FORMAT_FUNCTION="$1"
}

__log.core.format_fn_wrapper() {
  format_function="${__LOG_CORE_FORMAT_FUNCTION}"

  local message_log_level
  message_log_level="$1"
  local log_level_name
  log_level_name="$(__log.core.get_log_level_name "$message_log_level")"
 
  local fmt_fn_return_code 
  while read -r log_line; do
    "$format_function" "$log_level_name" <<<"$log_line"
    fmt_fn_return_code="$?"
    if [[ "$fmt_fn_return_code" != 0 ]]; then  
      echo "log.bash: WARNING: format function '${__LOG_CORE_FORMAT_FUNCTION}' returned non-zero exit code"
    fi
  done
}

__log.core.raw_format_fn() {
  while IFS= read -r line; do
    echo "$line"
  done
}

__log.core.bracketed_format_fn() {
  local log_level_name
  log_level_name="$1"

  # get parent script's name
  local parent_script_name
  parent_script_name="$(__log.core.utils.get_parent_script_name)"

  while IFS= read -r line; do
    printf \
      "%s %s %5s: %s\n" \
      "$(__log.core.utils.date.timestamp)" \
      "$parent_script_name" \
      "$log_level_name" \
      "$line"
  done
}

__log.core.bracketed_format_fn_no_date() {
  local log_level_name
  log_level_name="$1"

  # get parent script's name
  local parent_script_name
  parent_script_name="$(__log.core.utils.get_parent_script_name)"

  while IFS= read -r line; do
    printf "%s %5s: %s\n" "$parent_script_name" "$log_level_name" "$line"
  done
}


__log.core.json_format_fn() {
  local log_level_name
  log_level_name="$1"

  # get parent script's name
  local parent_script_name
  parent_script_name="$(__log.core.utils.get_parent_script_name)"

  while IFS= read -r line; do
    __log.core.utils.json.object.new \
      | __log.core.utils.json.object.add_key_value "timestamp" "$(__log.core.utils.date.timestamp)" \
      | __log.core.utils.json.object.add_key_value "parent" "$parent_script_name" \
      | __log.core.utils.json.object.add_key_value "level" "$log_level_name" \
      | __log.core.utils.json.object.add_key_value "message" "$line"
  done
}

__log.core.json_format_fn_no_date() {
  local log_level_name
  log_level_name="$1"

  # get parent script's name
  local parent_script_name
  parent_script_name="$(__log.core.utils.get_parent_script_name)"

  while IFS= read -r line; do
    __log.core.utils.json.object.new \
      | __log.core.utils.json.object.add_key_value "parent" "$parent_script_name" \
      | __log.core.utils.json.object.add_key_value "level" "$log_level_name" \
      | __log.core.utils.json.object.add_key_value "message" "$line"
  done
}

__log.core.set_format_bracketed() {
  if ! __log.core.utils.date.is_date_installed; then
    echo "log.bash: WARNING: 'date' command is not available. Omitting timestamp from logs" >&2
    __log.core.set_format_fn "__log.core.bracketed_format_fn_no_date"
  else
    __log.core.set_format_fn "__log.core.bracketed_format_fn"
  fi
}

__log.core.set_format_raw() {
  __log.core.set_format_fn "__log.core.raw_format_fn"
}

__log.core.set_format_json() {
  if ! __log.core.utils.date.is_date_installed; then
    echo "log.bash: WARNING: 'date' command is not available. Omitting timestamp from logs" >&2
    __log.core.set_format_fn "__log.core.json_format_fn_no_date"
  else
    __log.core.set_format_fn "__log.core.json_format_fn"
  fi

  if ! __log.core.utils.json.is_jq_installed; then
    echo "log.bash: WARNING: format was set to json but 'jq' command is not available. Using default format" >&2
    __log.core.set_format_fn "$(__log.core.default_format_fn)"
    return 0
  fi
}

# Set format.format_function to core.format_fn_wrapper
__log.core.format.set_format_function "__log.core.format_fn_wrapper"
