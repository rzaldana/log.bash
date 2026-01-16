# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

test_log_sends_message_through_filter_format_write_pipeline() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  # mock filter function
  __blog.filter.filter() {
    while IFS= read -r line; do
      echo "[filtered] $line"
    done
  }
  
  # mock format function
  __blog.format.format() {
    while IFS= read -r line; do
      echo "[formatted] $line"
    done
  }

  # mock write function
  __blog.write.write() {
    while IFS= read -r line; do
      echo "[written] $line"
    done
  }
  

  __blog.format.set_format_function "mock_format"
  # shellcheck disable=SC2119
  __blog.log "3" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "[written] [formatted] [filtered] $message")
}
