
__blog.write.get_default_destination_fd() {
  echo "2"
}

__blog.write.is_destination_fd_set() {
  if [[ -n "${__BLOG_WRITE_DESTINATION_FD:-}" ]]; then
    return 0
  else
    return 1
  fi
}

__blog.write.set_destination_fd() {
  __BLOG_WRITE_DESTINATION_FD="$1"
  export __BLOG_WRITE_DESTINATION_FD
}

__blog.write.write() {
  local destination_fd
  destination_fd="${__BLOG_WRITE_DESTINATION_FD}"
  while IFS= read -r log_line; do
    echo "$log_line" >&"$destination_fd"
  done
}
