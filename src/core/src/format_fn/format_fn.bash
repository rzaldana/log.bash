
__blog.format_fn.raw_format_fn() {
  while IFS= read -r line; do
    echo "$line"
  done
}

__blog.format_fn.bracketed_format_fn() {
  local log_level
  log_level="$1"
  local log_level_name
  # shellcheck disable=SC2119
  log_level_name="$(__blog.core.get_log_level_name "$log_level")"
  while IFS= read -r line; do
    printf "[%7s]: %s\n" "$log_level_name" "$line"
  done
}
