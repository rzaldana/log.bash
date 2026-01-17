# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIBRARY_PATH="$SCRIPT_DIR/../write.bash"

test_write_sends_message_to_configured_fd() {
  set -euo pipefail
  source "$LIBRARY_PATH"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.write.set_destination_fd "3"
  __blog.write.write <<<"$message" 3>"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "$message")
}
