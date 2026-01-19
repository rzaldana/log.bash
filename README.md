# 🪵 log.bash 
A tiny, no‑nonsense logging library for Bash 

It gives you clean log levels, simple formatting, and predictable output, all through a lightweight shell‑friendly API. 

Only functions **without** the `__` prefix are meant for direct use. 

## Features 
- Log levels: `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL`, `OFF`
- Default level: `WARN` 
- Two built‑in formatters: 
    - **raw** — plain text 
    - **bracketed** — `[script_name][ INFO]: message` 
- Output goes to **stderr** by default 
- Minimal, pipeline‑driven design 

## Basic Usage 
```bash 
log.info <<<"Server started" 
log.warn <<<"Low disk space" 
log.error <<<"Something failed"
```

## Dependencies 
The following versions of bash are supported:
- 5.2.15
- 4.0.44
- 4.4.23
- 3.2.57

External binaries:
- `date` for timestamps feature (tested version: BusyBox v1.36.1)
- `jq` for JSON formatted logging (tested version: 1.8.1)

If `date` is not available in the environment, log.bash emits a warning to stderr and removes timestamps from logs.
If `jq` is not available and JSON formatting is set, log.bash emits a warning to stderr and falls back to space delimited formatting.

