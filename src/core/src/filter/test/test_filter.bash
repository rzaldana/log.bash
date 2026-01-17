# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIBRARY_PATH="$SCRIPT_DIR/../filter.bash"

test_filter_forwards_message_if_message_log_level_is_higher_than_set_level() {
  set -euo pipefail
  source "$LIBRARY_PATH"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.filter.set_level "4"
  __blog.filter.filter "5" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "$message")
}

test_filter_forwards_message_if_message_log_level_is_equal_to_set_level() {
  set -euo pipefail
  source "$LIBRARY_PATH"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.filter.set_level "4"
  __blog.filter.filter "4" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "$message")
}


test_filter_discards_message_if_message_log_level_is_lower_than_set_level() {
  set -euo pipefail
  source "$LIBRARY_PATH"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.filter.set_level "4"
  __blog.filter.filter "3" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo -n "")
}
