# blog 🐝🪵
A tiny, no‑nonsense logging library for Bash — pronounced **“bee‑log.”** 

It gives you clean log levels, simple formatting, and predictable output, all through a lightweight shell‑friendly API. 

Only functions **without** the `__` prefix are meant for direct use. 

## ✨ Features 
- Log levels: `DEBUG`, `INFO`, `WARN`, `ERROR`, `FATAL` 
- Default level: `WARN` 
- Two built‑in formatters: 
    - **raw** — plain text 
    - **bracketed** — `[ INFO]: message` 
- Output goes to **stderr** by default 
- Minimal, pipeline‑driven design 

## 🚀 Basic Usage 
```bash 
blog.info <<<"Server started" 
blog.warn <<<"Low disk space" 
blog.error <<<"Something failed"
```

## 📦 Dependencies 
blog has no external dependencies. All functionality is implemented entirely in Bash. The following versions of bash are supported:
- 5.2.15
- 4.0.44
- 4.4.23
- 3.2.57
