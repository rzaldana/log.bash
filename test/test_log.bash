test_basic() {
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  ./test_scripts/test.bash >&2 2>"$tmpfile"

  assert_no_diff "./expected_outputs/test.txt" "$tmpfile"
}


test_json() {
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  ./test_scripts/json.bash >&2 2>"$tmpfile"

  assert_no_diff "./expected_outputs/json.txt" "$tmpfile"
}


test_json_no_jq() {
  tmpfile="$(mktemp)"
  # shellcheck disable=SC2064
  trap "rm $tmpfile" EXIT

  ./test_scripts/json_no_jq.bash >&2 2>"$tmpfile"

  assert_no_diff "./expected_outputs/json_no_jq.txt" "$tmpfile"
}
