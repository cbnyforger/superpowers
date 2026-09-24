#!/usr/bin/env bash
# SessionStart hook: injects every extensions/*.md as standing instructions
# layered on top of the official superpowers skills. Nothing in the plugin
# cache is modified, so plugin updates never wipe these additions.
set -euo pipefail

EXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

escape_for_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '%s' "$s"
}

content=""
for f in "$EXT_DIR"/*.md; do
    [ -e "$f" ] || continue
    content+="$(cat "$f")"$'\n\n'
done
[ -n "$content" ] || exit 0

context="<EXTREMELY_IMPORTANT>
Your human partner has extended some superpowers skills. When you use one of the skills named below, apply its extension as well.

${content}</EXTREMELY_IMPORTANT>"

printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$(escape_for_json "$context")"
