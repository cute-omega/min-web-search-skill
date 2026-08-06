# min-web-search

Minimal cross-platform web search via Bing RSS — no API key, no dependencies.

## What it does

Queries `cn.bing.com/search?q=...&format=rss` and returns search results (title, URL, snippet). No API key required.

## Implementations

| File | Platform | Dependencies |
|---|---|---|
| `scripts/search.sh` | Unix-like (Linux, macOS, Alpine, WSL) | curl/wget + sed + grep |
| `scripts/search.py` | Anywhere with Python 3.8+ | Python stdlib only |
| `scripts/search.ps1` | Windows (PowerShell 5.1+) | None (built-in) |

## Usage

### Shell (recommended — zero dependencies)

```bash
./scripts/search.sh "python tutorial"
./scripts/search.sh "python tutorial" --max 3
./scripts/search.sh "python tutorial" --json
```

### Python

```bash
python3 scripts/search.py "python tutorial"
python3 scripts/search.py "python tutorial" --max 3
python3 scripts/search.py "python tutorial" --json
```

### PowerShell

```powershell
.\scripts\search.ps1 "python tutorial"
.\scripts\search.ps1 "python tutorial" -Max 3
.\scripts\search.ps1 "python tutorial" -Json
```

## Output

**Human-readable:**
```
1. Welcome to Python.org
   https://www.python.org/
   The mission of the Python Software Foundation...
```

**JSON (`--json`):**
```json
{
  "success": true,
  "query": "python tutorial",
  "results": [
    {"title": "Welcome to Python.org", "url": "https://www.python.org/", "snippet": "..."}
  ]
}
```

## Limitations

- Uses Bing China (`cn.bing.com`) — results may be region-biased
- RSS returns max ~10 results, no pagination
- `grep -oP` needs GNU grep (macOS: `brew install grep` for `ggrep`)

## License

MIT
