# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

test_write_sends_message_to_configured_fd() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.set_destination_fd "3"
  __blog.write <<<"$message" 3>"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "$message")
}
