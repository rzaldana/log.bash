
source ./core/core.bash

blog.set_level_debug() {
  __blog.core.set_level "DEBUG"
}

blog.set_level_info() {
  __blog.core.set_level "INFO"
}

blog.set_level_warn() {
  __blog.core.set_level "WARN"
}

blog.set_level_error() {
  __blog.core.set_level "ERROR"
}

blog.set_level_fatal() {
  __blog.core.set_level "FATAL"
}

blog.debug() {
  __blog.core.log "DEBUG"
}

blog.info() {
  __blog.core.log "INFO"
}

blog.warn() {
  __blog.core.log "WARN"
}

blog.error() {
  __blog.core.log "ERROR"
}

blog.fatal() {
  __blog.core.fatal "FATAL"
}

blog.set_format_raw() {
  __blog.core.set_format_fn "__blog.core.raw_format_fn"
}

blog.set_format_bracketed() {
  __blog.core.set_format_fn "__blog.core.bracketed_format_fn"
}
