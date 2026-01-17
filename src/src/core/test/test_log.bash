# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIBRARY_PATH="$SCRIPT_DIR/../log.bash"

test_log_maps_log_level_name_to_int_and_sends_message_through_filter_format_write_pipeline() {
  set -euo pipefail
  source "$LIBRARY_PATH"
  local message="my message"
  # Create tmpfile to store output
  tmpfile="$(mktemp)"
  filter_level_tmpfile="$(mktemp)"
  format_level_tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile $filter_level_tmpfile $format_level_tmpfile" EXIT
  
  # mock filter function
  __blog.filter.filter() {
    filter_got_level="$1"
    echo "$filter_got_level" >"$filter_level_tmpfile"
    while IFS= read -r line; do
      echo "[filtered] $line"
    done
  }
 
  declare format_got_level
  # mock format function
  __blog.format.format() {
    format_got_level="$1"
    echo "$format_got_level" >"$format_level_tmpfile"
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
  __blog.core.log "WARN" <<<"$message" >"$tmpfile"

  assert_no_diff "$tmpfile" <(echo "[written] [formatted] [filtered] $message")
  assert_no_diff <( echo "2") "$filter_level_tmpfile" "filter function should have received log level '2'"
  assert_no_diff <( echo "2") "$format_level_tmpfile" "format function should have received log level '2'"
}


test_log_uses_default_format_fn_if_no_format_fn_is_configured() {
  set -euo pipefail
  source "$LIBRARY_PATH" 

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT


  # mock bracketed format_fn
  mock_format_fn() {
  # shellcheck disable=SC2317
    while IFS= read -r line; do
     echo "[bracket]: $line" 
    done
  }

  # shellcheck disable=SC2317
  __blog.core.default_format_fn() {
    echo "mock_format_fn" 
  }

  __blog.core.set_level "DEBUG"
  __blog.core.set_destination_fd "3"
  __blog.core.log "DEBUG" <<<"hello!" 3>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "[bracket]: hello!" )
  : > "$tmpfile" # clear file contents
}


test_log_uses_default_destination_fd_if_no_destination_fd_is_configured() {
  set -euo pipefail
  source "$LIBRARY_PATH"

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT


  # mock bracketed format_fn
  mock_format_fn() {
  # shellcheck disable=SC2317
    while IFS= read -r line; do
     echo "[bracket]: $line" 
    done
  }

  # shellcheck disable=SC2317
  __blog.core.default_format_fn() {
    echo "mock_format_fn" 
  }

  __blog.core.default_destination_fd() {
    echo "6"
  }


  __blog.core.set_level "DEBUG"
  __blog.core.set_format_fn "__blog.core.raw_format_fn"
  __blog.core.log "DEBUG" <<<"hello!" 6>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!" )
  : > "$tmpfile" # clear file contents
}


test_log_function_uses_default_level_if_no_level_is_configured() {
  set -euo pipefail
  source "$LIBRARY_PATH"

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  # shellcheck disable=SC2317
  __blog.core.default_level() {
    echo "1" 
  }

  __blog.core.set_format_fn "__blog.core.raw_format_fn"

  __blog.core.log "DEBUG" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  __blog.core.log "INFO" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  __blog.core.log "WARN" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  __blog.core.log "ERROR" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  __blog.core.log "FATAL" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

}
