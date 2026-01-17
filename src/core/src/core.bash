
source filter/filter.bash
source format/format.bash
source write/write.bash
source format_fn/format_fn.bash

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
