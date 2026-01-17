# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIBRARY_PATH="$SCRIPT_DIR/../core.bash"

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
 
  # shellcheck disable=SC2317 
  # mock filter function
  __log.filter.filter() {
    filter_got_level="$1"
    echo "$filter_got_level" >"$filter_level_tmpfile"
    while IFS= read -r line; do
      echo "[filtered] $line"
    done
  }
 
  declare format_got_level

  # shellcheck disable=SC2317 
  # mock format function
  __log.format.format() {
    format_got_level="$1"
    echo "$format_got_level" >"$format_level_tmpfile"
    while IFS= read -r line; do
      echo "[formatted] $line"
    done
  }

  # mock write function
  # shellcheck disable=SC2317 
  __log.write.write() {
    while IFS= read -r line; do
      echo "[written] $line"
    done
  }
  

  __log.core.log "WARN" <<<"$message" >"$tmpfile"

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
  __log.core.default_format_fn() {
    echo "mock_format_fn" 
  }

  __log.core.set_level "DEBUG"
  __log.core.set_destination_fd "3"
  __log.core.log "DEBUG" <<<"hello!" 3>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "[bracket]: hello!" )
  : > "$tmpfile" # clear file contents
}


test_log_uses_default_destination_fd_if_no_destination_fd_is_configured() {
  set -euo pipefail
  source "$LIBRARY_PATH"

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT



  # shellcheck disable=SC2317
  __log.core.default_format_fn() {
    echo "mock_format_fn" 
  }

  __log.core.default_destination_fd() {
    echo "6"
  }


  __log.core.set_level "DEBUG"
  __log.core.set_format_raw
  __log.core.log "DEBUG" <<<"hello!" 6>"$tmpfile"
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
  __log.core.default_level() {
    echo "1" 
  }

  __log.core.set_format_raw

  __log.core.log "DEBUG" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  __log.core.log "INFO" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  __log.core.log "WARN" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  __log.core.log "ERROR" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  __log.core.log "FATAL" <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

}
