#!/usr/bin/env bash

# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIBRARY_PATH="$SCRIPT_DIR/../../log.bash"

# shellcheck source=../../log.bash
source "$LIBRARY_PATH"

log.set_level_info
log.info <<<"hello"
log.warn <<<"bye"

log.set_format_raw
log.info <<<"hello"
log.warn <<<"bye"


log.set_format_bracketed
echo "hello" | log.info
echo "bye" | log.warn
echo "hello" | log.error
