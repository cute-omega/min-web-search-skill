#!/bin/sh
# min-web-search: Bing RSS web search — pure POSIX shell
# Usage: ./search.sh "query" [--max N] [--json]
#
# Dependencies: curl or wget + sed + grep -oP + awk
# Works on any Unix-like system with basic utils, no Python needed.

set -e

# ── arg parsing ──
QUERY=""
MAX=5
JSON=0
for arg in "$@"; do
    case "$arg" in
        --json) JSON=1 ;;
        --max) NEXT_MAX=1 ;;
        *)
            if [ "${NEXT_MAX:-}" = "1" ]; then
                MAX="$arg"
                NEXT_MAX=""
            elif [ -z "$QUERY" ]; then
                QUERY="$arg"
            fi
            ;;
    esac
done

if [ -z "$QUERY" ]; then
    echo "Usage: $0 \"query\" [--max N] [--json]" >&2
    exit 1
fi

# ── URL encode ──
urlencode() {
    printf '%s' "$1" | awk '{
        n = split($0, chars, "")
        for (i = 1; i <= n; i++) {
            c = chars[i]
            if (c ~ /^[a-zA-Z0-9_.~-]$/) printf "%s", c
            else printf "%%%02X", int(c)
        }
    }'
}

ENCODED=$(urlencode "$QUERY")
URL="https://cn.bing.com/search?q=${ENCODED}&format=rss"

# ── fetch RSS ──
RSS=""
if command -v curl >/dev/null 2>&1; then
    RSS=$(curl -sS --connect-timeout 10 -A "Mozilla/5.0" "$URL" 2>/dev/null) || true
elif command -v wget >/dev/null 2>&1; then
    RSS=$(wget -q -O - --timeout=10 --header="User-Agent: Mozilla/5.0" "$URL" 2>/dev/null) || true
else
    echo "ERROR: neither curl or wget found" >&2
    exit 1
fi

if [ -z "$RSS" ]; then
    if [ "$JSON" = "1" ]; then
        echo '{"success":false,"error":"network request failed"}'
    else
        echo "ERROR: network request failed" >&2
    fi
    exit 1
fi

# ── parse: split <item> onto separate lines, extract fields ──
ITEM_LINES=$(echo "$RSS" | sed 's/<item>/\n<item>/g' | grep '^<item>')

if [ -z "$ITEM_LINES" ]; then
    if [ "$JSON" = "1" ]; then
        echo '{"success":false,"error":"no results"}'
    else
        echo "ERROR: no results" >&2
    fi
    exit 1
fi

# ── output ──
N=0
echo "$ITEM_LINES" | while IFS= read -r line; do
    N=$((N + 1))
    [ "$N" -gt "$MAX" ] && break

    TITLE=$(echo "$line" | grep -oP '<title>\K[^<]+')
    LINK=$(echo "$line" | grep -oP '<link>\K[^<]+')
    DESC=$(echo "$line" | grep -oP '<description>\K[^<]+' | sed 's/<[^>]*>//g')

    [ -z "$TITLE" ] || [ -z "$LINK" ] && continue

    if [ "$JSON" = "1" ]; then
        # JSON output — collect into array
        [ "$N" -eq 1 ] && printf '{"success":true,"query":"%s","results":[' "$QUERY"
        [ "$N" -gt 1 ] && printf ','
        # escape quotes in fields
        TITLE_ESC=$(echo "$TITLE" | sed 's/"/\\"/g')
        LINK_ESC=$(echo "$LINK" | sed 's/"/\\"/g')
        DESC_ESC=$(echo "$DESC" | sed 's/"/\\"/g')
        printf '{"title":"%s","url":"%s","snippet":"%s"}' "$TITLE_ESC" "$LINK_ESC" "$DESC_ESC"
    else
        echo "${N}. ${TITLE}"
        echo "   ${LINK}"
        [ -n "$DESC" ] && printf '   %.200s\n' "$DESC"
        echo
    fi
done

if [ "$JSON" = "1" ] && [ "$N" -gt 0 ]; then
    echo ']}'
fi
