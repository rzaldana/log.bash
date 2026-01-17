
source filter/dist/filter.bash
source format/dist/format.bash
source write/dist/write.bash

__blog.log.log() {
  local log_level_name
  log_level_name="$1"

  # use defualt format fn if not set
  if ! __blog.format.is_format_fn_set; then
    __blog.format.set_format_function "$(__blog.log.default_format_fn)"
  fi

  # use default destination fd if not set
  if ! __blog.write.is_destination_fd_set; then
    __blog.write.set_destination_fd "$(__blog.log.default_destination_fd)"
  fi

  # use default log level if level is not set
  if ! __blog.filter.is_level_set; then
    __blog.filter.set_level "$(__blog.log.default_level)"
  fi

  local log_level_int
  log_level_int="$(__blog.log.get_log_level_int "$log_level_name")"

  while IFS= read -r log_line; do
    echo "$log_line" \
      | __blog.filter.filter "$log_level_int" \
      | __blog.format.format "$log_level_int" \
      | __blog.write.write
  done
}


__blog.log.default_format_fn() {
  echo "__blog.log.bracketed_format_fn"
}

__blog.log.default_level() {
  echo "2" # warn
}

__blog.log.default_destination_fd() {
  echo "2" # stderr
}


__blog.log.get_log_level_name() {
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

__blog.log.get_log_level_int() {
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


__blog.log.raw_format_fn() {
  while IFS= read -r line; do
    echo "$line"
  done
}

__blog.log.bracketed_format_fn() {
  local log_level
  log_level="$1"
  local log_level_name
  # shellcheck disable=SC2119
  log_level_name="$(__blog.log.get_log_level_name "$log_level")"
  while IFS= read -r line; do
    printf "[%7s]: %s\n" "$log_level_name" "$line"
  done
}

__blog.log.set_level() {
  local log_level_name
  log_level_name="$1"
  local log_level_int
  log_level_int="$(__blog.log.get_log_level_int "$log_level_name")"
  __blog.filter.set_level "$log_level_int"
}

__blog.log.set_destination_fd() {
  local destination_fd
  destination_fd="$1"
  __blog.write.set_destination_fd "$destination_fd"
}

__blog.log.set_format_fn() {
  local format_fn
  format_fn="$1"
  __blog.format.set_format_function "$format_fn"
}
