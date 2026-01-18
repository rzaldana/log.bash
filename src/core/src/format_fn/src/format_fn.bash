
source ./utils/utils.bash

__log.core.format_fn.raw_format_fn() {
  while IFS= read -r line; do
    echo "$line"
  done
}

__log.core.format_fn.bracketed_format_fn() {
  local log_level_name
  log_level_name="$1"

  # get parent script's name
  local parent_script_name
  parent_script_name="$(__log.core.format_fn.utils.get_parent_script_name)"

  while IFS= read -r line; do
    printf "[%s][%5s]: %s\n" "$parent_script_name" "$log_level_name" "$line"
  done
}


__log.core.format_fn.json_format_fn() {
  local log_level_name
  log_level_name="$1"

  # get parent script's name
  local parent_script_name
  parent_script_name="$(__log.core.format_fn.utils.get_parent_script_name)"

  while IFS= read -r line; do
    __log.core.format_fn.utils.json.object.new \
      | __log.core.format_fn.utils.json.object.add_key_value "parent" "$parent_script_name" \
      | __log.core.format_fn.utils.json.object.add_key_value "level" "$log_level_name" \
      | __log.core.format_fn.utils.json.object.add_key_value "message" "$line"
  done
}
