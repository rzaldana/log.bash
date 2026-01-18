
source ./date/date.bash
source ./json/json.bash

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
__log.core.utils.get_parent_script_name() {
  # Get the length of FUNCNAME
  local -i funcname_length
  funcname_length="${#FUNCNAME[@]}" 

  local -i top_level_index
  top_level_index=$(( funcname_length - 1 ))
  printf "%s" "${BASH_SOURCE[$top_level_index]##*/}"
}
