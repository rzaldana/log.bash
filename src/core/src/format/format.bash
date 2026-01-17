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
