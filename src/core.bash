__blog.get_default_log_level() {
  echo "2"
}

__blog.set_format_function() {
  export __BLOG_FORMAT_FUNCTION="$1"
}

__blog.get_default_format_function() {
  echo "__blog.format_fn.raw"
}

__blog.set_level() {
  export __BLOG_LEVEL="$1"
}

__blog.get_default_destination_fd() {
  echo "2"
}

__blog.set_destination_fd() {
  __BLOG_DESTINATION_FD="$1"
  export __BLOG_DESTINATION_FD
}

__blog.write() {
  local default_destination_fd
  default_destination_fd="$(__blog.get_default_destination_fd)"
  local destination_fd
  destination_fd="${__BLOG_DESTINATION_FD:-$default_destination_fd}"
  while IFS= read -r log_line; do
    echo "$log_line" >&"$destination_fd"
  done
}

__blog.filter() {
  local default_log_level
  default_log_level="$(__blog.get_default_log_level)"
  local set_log_level
  set_log_level="${__BLOG_LEVEL:-$default_log_level}"
  
  local message_log_level
  message_log_level="$1"

  while IFS= read -r log_line; do
    if (( message_log_level >= set_log_level )); then
      echo "$log_line"
    fi
  done
}

__blog.format() {
  local default_format_function
  default_format_function="$(__blog.get_default_format_function)"
  local format_function
  format_function="${__BLOG_FORMAT_FUNCTION:-$default_format_function}"

  local message_log_level
  message_log_level="$1"
  
  while read -r log_line; do
    "$format_function" "$message_log_level" <<<"$log_line"
  done
}

__blog.log() {
  local log_level
  log_level="$1"

  while IFS= read -r log_line; do
    echo "$log_line" \
      | __blog.filter "$log_level" \
      | __blog.format "$log_level" \
      | __blog.write
  done
}
