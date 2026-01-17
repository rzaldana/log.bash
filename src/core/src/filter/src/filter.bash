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
