

########## START library utils.bash ###########
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
__blog.core.format_fn.utils.get_parent_script_name() {
  # Get the length of FUNCNAME
  local -i funcname_length
  funcname_length="${#FUNCNAME[@]}" 

  local -i top_level_index
  top_level_index=$(( funcname_length - 1 ))
  printf "%s" "$( basename "${BASH_SOURCE[$top_level_index]}" )"
}
########## END library utils.bash ###########


__blog.format_fn.raw_format_fn() {
  while IFS= read -r line; do
    echo "$line"
  done
}

__blog.format_fn.bracketed_format_fn() {
  local log_level_name
  log_level_name="$1"

  # get parent script's name
  local parent_script_name
  parent_script_name="$(__blog.core.format_fn.utils.get_parent_script_name)"

  while IFS= read -r line; do
    printf "[%s][%5s]: %s\n" "$parent_script_name" "$log_level_name" "$line"
  done
}
