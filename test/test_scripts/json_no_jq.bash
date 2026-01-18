set -euo pipefail

# Get the directory of the script that's currently running
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIBRARY_PATH="$SCRIPT_DIR/../../log.bash"

# shellcheck source=../../log.bash
source "$LIBRARY_PATH"


log.set_level_debug
hash -d jq
PATH= log.set_format_json

echo "hello" | log.info
echo "hi" | log.debug
echo "no" | log.error
