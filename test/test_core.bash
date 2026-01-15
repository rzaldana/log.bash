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

  blog.set_destination_fd "3"
  __blog.write <<<"$message" 3>"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "$message")
}

test_write_sends_message_to_stderr_if_fd_is_not_configured() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.write <<<"$message" 2>"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "$message")
}

test_filter_forwards_message_if_message_log_level_is_higher_than_set_log_level() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.set_log_level "4"
  __blog.filter "5" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "$message")
}

test_filter_forwards_message_if_message_log_level_is_equal_to_set_log_level() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.set_log_level "4"
  __blog.filter "4" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "$message")
}


test_filter_discards_message_if_message_log_level_is_lower_than_set_log_level() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.set_log_level "4"
  __blog.filter "3" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo -n "")
}

test_filter_sets_log_level_to_2_if_log_level_is_unset() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.filter "1" <<<"$message" >"$tmpfile"
  assert_no_diff "$tmpfile" <(echo -n "")
  : > "$tmpfile"

  __blog.filter "2" <<<"$message" >"$tmpfile"
  assert_no_diff "$tmpfile" <(echo "$message")
  : > "$tmpfile"

  __blog.filter "3" <<<"$message" >"$tmpfile"
  assert_no_diff "$tmpfile" <(echo "$message")
}

test_format_runs_raw_format_function_if_format_fn_is_unset() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  __blog.format "3" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "$message")
}

test_format_runs_configured_format_function() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  # shellcheck disable=SC2317
  mock_format() {
    log_level="$1"
    while IFS= read -r "line"; do
      echo "[$log_level][formatted] $line"
    done
  }

  __blog.set_format_function "mock_format"
  # shellcheck disable=SC2119
  __blog.format "3" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "[3][formatted] $message")
}

test_log_sends_message_through_filter_format_write_pipeline() {
  set -euo pipefail
  source "$SCRIPT_DIR/../blog.bash"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  # mock filter function
  __blog.filter() {
    while IFS= read -r line; do
      echo "[filtered] $line"
    done
  }
  
  # mock format function
  __blog.format() {
    while IFS= read -r line; do
      echo "[formatted] $line"
    done
  }

  # mock write function
  __blog.write() {
    while IFS= read -r line; do
      echo "[written] $line"
    done
  }
  

  __blog.set_format_function "mock_format"
  # shellcheck disable=SC2119
  __blog.log "3" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "[written] [formatted] [filtered] $message")
}
