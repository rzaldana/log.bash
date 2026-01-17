# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIBRARY_PATH="$SCRIPT_DIR/../format.bash"

test_format_runs_configured_format_function() {
  set -euo pipefail
  source "$LIBRARY_PATH"
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

  __log.core.format.set_format_function "mock_format"
  # shellcheck disable=SC2119
  __log.core.format.format "3" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "[3][formatted] $message")
}
