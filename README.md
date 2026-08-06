# min-web-search-skill

**No API key. No Docker. No dependencies. Just search.**

## The Problem

AI agents like Hermes, Claude Code, and OpenCode all have a `web_search` tool — but it rarely works out of the box:

- **API keys are a hassle.** Brave, Tavily, Exa — each requires signing up, getting a key, and configuring it. Most people never bother.
- **Network restrictions.** If you're in China, Brave and Google are blocked. Even with a key, the connection times out.
- **Heavy alternatives.** SearXNG requires Docker. Browser automation needs Chromium + Playwright. Overkill for "just search something."

Meanwhile, **Bing's RSS endpoint** (`cn.bing.com/search?q=...&format=rss`) is:
- Free, no API key needed
- Accessible from mainland China
- Returns clean XML with titles, URLs, and snippets

## What This Does

A single script that queries Bing RSS and returns search results. Three implementations, pick whatever fits your system:

| Script | Platform | What it needs |
|---|---|---|
| `search.sh` | Linux, macOS, Alpine, WSL | curl/wget + sed + grep (almost always pre-installed) |
| `search.py` | Any OS with Python 3.8+ | Python stdlib only (urllib + xml.etree) |
| `search.ps1` | Windows 10+ | PowerShell (built-in) |

## Usage

```bash
# Shell — the lightest option
./scripts/search.sh "how to install docker"
./scripts/search.sh "rust tutorial" --max 3
./scripts/search.sh "openai api" --json

# Python — works everywhere Python exists
python3 scripts/search.py "python packaging guide"

# PowerShell — Windows native
.\scripts\search.ps1 "windows service configuration" -Json
```

## When to Use This

- Your `web_search` tool says "API key not set" and you don't want to get one
- You're behind a firewall that blocks Brave/Google but allows Bing
- You're in a minimal Docker container (Alpine) where installing Python isn't worth it
- You just need a quick search without configuring anything

## Output

Human-readable by default:
```
1. How to Install Docker on Ubuntu 22.04
   https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04
   Step 1: Update your existing list of packages...
```

JSON mode (`--json`) for programmatic use:
```json
{
  "success": true,
  "query": "how to install docker",
  "results": [
    {
      "title": "How to Install Docker on Ubuntu 22.04",
      "url": "https://www.digitalocean.com/...",
      "snippet": "Step 1: Update your existing list of packages..."
    }
  ]
}
```

## Limitations

- Bing China (`cn.bing.com`) may bias results toward Chinese content
- RSS returns max ~10 results, no pagination
- `grep -oP` in the shell version requires GNU grep (macOS users: `brew install grep`)

## License

MIT
