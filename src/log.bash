__blog.log() {
  local log_level
  log_level="$1"

  while IFS= read -r log_line; do
    echo "$log_line" \
      | __blog.filter.filter "$log_level" \
      | __blog.format.format "$log_level" \
      | __blog.write.write
  done
}
