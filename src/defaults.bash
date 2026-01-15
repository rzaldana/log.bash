#!/usr/bin/env bash

__blog.defaults.format_fn() {
  echo "__blog.format_fn.bracketed"
}

__blog.defaults.level() {
  echo "2" # warn
}

__blog.defaults.destination_fd() {
  echo "2" # stderr
}
