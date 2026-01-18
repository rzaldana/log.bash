__log.core.utils.date.is_date_installed() {
  if ! command -v date >/dev/null 2>&1; then
    return 1 
  fi
}

__log.core.utils.date.timestamp() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}
