
source ./core/core.bash

log.set_level_debug() {
  __log.core.set_level "DEBUG"
}

log.set_level_info() {
  __log.core.set_level "INFO"
}

log.set_level_warn() {
  __log.core.set_level "WARN"
}

log.set_level_error() {
  __log.core.set_level "ERROR"
}

log.set_level_fatal() {
  __log.core.set_level "FATAL"
}

log.set_level_off() {
  __log.core.set_level "OFF"
}

log.debug() {
  __log.core.log "DEBUG"
}

log.info() {
  __log.core.log "INFO"
}

log.warn() {
  __log.core.log "WARN"
}

log.error() {
  __log.core.log "ERROR"
}

log.fatal() {
  __log.core.log "FATAL"
}

log.set_format_raw() {
  __log.core.set_format_raw
}

log.set_format_space_delimited() {
  __log.core.set_format_bracketed
}

log.set_format_json() {
  __log.core.set_format_json
}
