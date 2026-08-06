---
name: min-web-search
description: "Minimal cross-platform web search via Bing RSS — no API key, no dependencies beyond Python 3.8+ or curl."
version: 1.1.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [web, search, bing, cross-platform, minimal]
    related_skills: []
---

# min-web-search

Minimal web search using Bing's public RSS endpoint. No API key, no third-party packages, no Docker.

## When to Use

Use this skill when the user asks you to search the web and the built-in `web_search` tool is unavailable (e.g. no API key configured, or the configured backend is unreachable).

## How It Works

Queries `cn.bing.com/search?q=...&format=rss` and parses the XML response. The RSS feed returns titles, URLs, and snippets — everything needed for a basic web search.

## Usage

### Unix-like (shell) — recommended, zero dependencies

```bash
# Requires only: curl (or wget) + sed + grep -oP — available on virtually all Unix systems
./scripts/search.sh "your query"
./scripts/search.sh "your query" --max 3
./scripts/search.sh "your query" --json
```

### Linux / macOS / Windows (Python)

```bash
# Requires: Python 3.8+ (standard library only)
python3 scripts/search.py "your query"
python3 scripts/search.py "your query" --max 3
python3 scripts/search.py "your query" --json
```

### Windows (PowerShell)

```powershell
# Requires: PowerShell 5.1+ (built into Windows 10+)
.\scripts\search.ps1 "your query"
.\scripts\search.ps1 "your query" -Max 3
.\scripts\search.ps1 "your query" -Json
```

## Which Implementation to Use

| Environment | Recommended | Fallback |
|---|---|---|
| Linux / macOS with Python | `search.sh` | `search.py` |
| Linux / macOS without Python | `search.sh` | — |
| Windows (PowerShell) | `search.ps1` | `search.py` |
| Minimal Docker / Alpine | `search.sh` | — |

## Output Format

**Human-readable** (default):
```
1. Title of Result
   https://example.com/page
   Snippet text up to 200 chars...
```

**JSON** (`--json`):
```json
{
  "success": true,
  "query": "your query",
  "results": [
    {"title": "...", "url": "...", "snippet": "..."}
  ]
}
```

## Limitations

- Uses Bing China (`cn.bing.com`) — results may be region-biased
- RSS endpoint returns ~10 results max per query
- No pagination support (RSS doesn't provide offsets)
- Rate limiting may apply under heavy use

## Integration with Hermes

To use as a fallback when `web_search` fails, run the script from the terminal tool:

```
terminal: ~/.hermes/skills/min-web-search/scripts/search.sh "query" --json
```

## Common Pitfalls

- On some networks `cn.bing.com` may be slow; `www.bing.com` is an alternative
- The RSS feed occasionally returns empty results for very niche queries
- `grep -oP` requires GNU grep (standard on Linux; macOS needs `ggrep` via `brew install grep`)
- PowerShell 5.1+ is required on Windows (ships with Windows 10+)

## Verification Checklist

- [ ] Script runs without errors on target platform
- [ ] Returns valid JSON with `--json` flag
- [ ] Human-readable output shows title, URL, snippet
- [ ] Handles network errors gracefully (returns `{"success": false, ...}`)
