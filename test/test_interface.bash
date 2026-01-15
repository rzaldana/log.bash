#!/usr/bin/env bash

test_debug() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_format_raw
  blog.set_level_debug

  blog.debug <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.info <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.warn <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.error <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.fatal <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents
}


test_info() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_format_raw
  blog.set_level_info

  blog.debug <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.info <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.warn <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.error <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.fatal <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents
}

test_warn() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_format_raw
  blog.set_level_warn

  blog.debug <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.info <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.warn <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.error <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.fatal <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents
}

test_error() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_format_raw
  blog.set_level_error

  blog.debug <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.info <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.warn <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.error <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.fatal <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents
}

test_fatal() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_format_raw
  blog.set_level_fatal

  blog.debug <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.info <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.warn <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.error <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.fatal <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents
}

test_off() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_format_raw
  blog.set_level_off

  blog.debug <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.info <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.warn <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.error <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents

  blog.fatal <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo -n "")
  : > "$tmpfile" # clear file contents
}


test_debug_uses_default_format_fn_if_no_format_fn_is_configured() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_level_debug

  # mock bracketed format_fn
  __blog.format_fn.mock() {
  # shellcheck disable=SC2317
    while IFS= read -r line; do
     echo "[bracket]: $line" 
    done
  }

  # shellcheck disable=SC2317
  __blog.defaults.format_fn() {
    echo "__blog.format_fn.mock" 
  }

  blog.debug <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "[bracket]: hello!" )
  : > "$tmpfile" # clear file contents
}

test_info_uses_default_format_fn_if_no_format_fn_is_configured() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_level_debug

  # mock bracketed format_fn
  __blog.format_fn.mock() {
  # shellcheck disable=SC2317
    while IFS= read -r line; do
     echo "[bracket]: $line" 
    done
  }

  # shellcheck disable=SC2317
  __blog.defaults.format_fn() {
    echo "__blog.format_fn.mock" 
  }

  blog.info <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "[bracket]: hello!" )
  : > "$tmpfile" # clear file contents
}

test_warn_uses_default_format_fn_if_no_format_fn_is_configured() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_level_debug

  # mock bracketed format_fn
  __blog.format_fn.mock() {
  # shellcheck disable=SC2317
    while IFS= read -r line; do
     echo "[bracket]: $line" 
    done
  }

  # shellcheck disable=SC2317
  __blog.defaults.format_fn() {
    echo "__blog.format_fn.mock" 
  }

  blog.warn <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "[bracket]: hello!" )
  : > "$tmpfile" # clear file contents
}

test_error_uses_default_format_fn_if_no_format_fn_is_configured() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_level_debug

  # mock bracketed format_fn
  __blog.format_fn.mock() {
  # shellcheck disable=SC2317
    while IFS= read -r line; do
     echo "[bracket]: $line" 
    done
  }

  # shellcheck disable=SC2317
  __blog.defaults.format_fn() {
    echo "__blog.format_fn.mock" 
  }

  blog.error <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "[bracket]: hello!" )
  : > "$tmpfile" # clear file contents
}

test_fatal_uses_default_format_fn_if_no_format_fn_is_configured() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_level_debug

  # mock bracketed format_fn
  __blog.format_fn.mock() {
  # shellcheck disable=SC2317
    while IFS= read -r line; do
     echo "[bracket]: $line" 
    done
  }

  # shellcheck disable=SC2317
  __blog.defaults.format_fn() {
    echo "__blog.format_fn.mock" 
  }

  blog.fatal <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "[bracket]: hello!" )
  : > "$tmpfile" # clear file contents
}

test_log_functions_use_default_level_if_no_level_is_configured() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  # shellcheck disable=SC2317
  __blog.defaults.level() {
    echo "0" 
  }

  blog.set_format_raw

  blog.debug <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.info <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.warn <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.error <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.fatal <<<"hello!" 2>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

}


test_log_functions_use_default_destination_fd_if_no_destination_fd_is_configured() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  # shellcheck disable=SC2317
  __blog.defaults.destination_fd() {
    echo "4" 
  }

  blog.set_format_raw
  blog.set_level_debug

  blog.debug <<<"hello!" 4>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.info <<<"hello!" 4>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.warn <<<"hello!" 4>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.error <<<"hello!" 4>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

  blog.fatal <<<"hello!" 4>"$tmpfile"
  assert_no_diff "$tmpfile" <( echo "hello!")
  : > "$tmpfile" # clear file contents

}

test_set_format_bracketed_sets_bracketed_format_fn() {
  set -euo pipefail
  source ../blog.bash

  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm '$tmpfile'" EXIT

  blog.set_level_debug
  blog.set_format_bracketed
  assert_equals "$__BLOG_FORMAT_FUNCTION" "__blog.format_fn.bracketed"
}
