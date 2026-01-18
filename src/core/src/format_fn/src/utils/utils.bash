

########## START library json.bash ###########

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
########## END library json.bash ###########


# description: |
#   Returns the name of the script that's currently 
#   executing, even if the function is called from
#   a sourced library. Only the basename, not the
#   entire path, is returned
# inputs:
#   stdin: null 
#   args: null
# outputs:
#   stdout: null
#   stderr: null
#   return_code:
#     0: "always" 
# tags:
#   - "std"
__log.core.format_fn.utils.get_parent_script_name() {
  # Get the length of FUNCNAME
  local -i funcname_length
  funcname_length="${#FUNCNAME[@]}" 

  local -i top_level_index
  top_level_index=$(( funcname_length - 1 ))
  printf "%s" "$( basename "${BASH_SOURCE[$top_level_index]}" )"
}
