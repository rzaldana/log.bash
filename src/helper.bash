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

__blog.helper.is_format_fn_set() {
  if [[ -n "${__BLOG_FORMAT_FUNCTION:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__blog.helper.is_level_set() {
  if [[ -n "${__BLOG_LEVEL:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__blog.helper.is_destination_fd_set() {
  if [[ -n "${__BLOG_DESTINATION_FD:-}" ]]; then
    return 0
  else
    return 1
  fi
}
