
__log.core.format_fn.utils.json.is_jq_installed() {
  if ! command -v jq >/dev/null 2>&1; then
    return 1 
  fi
}

__log.core.format_fn.utils.json.object.new() {
  jq \
    --monochrome-output \
    --null-input \
    --compact-output \
    '{}'
}

__log.core.format_fn.utils.json.object.add_key_value() {
  IFS= read -r -d '' object || :
    local key
    local value
    key="$1" 
    value="$2"
    jq \
      --slurp \
      --monochrome-output \
      --null-input \
      --compact-output \
      --arg key "$key" \
      --arg value "$value" \
      --argjson object "$object" \
      '[$object, { $key: $value }] | add'
}
