#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail() {
  printf 'spec validation failed: %s\n' "$1" >&2
  exit 1
}

require_file() {
  [[ -s "$1" ]] || fail "required file is missing or empty: $1"
}

require_text() {
  local file="$1"
  local text="$2"
  grep -Fq -- "$text" "$file" || fail "$file must contain: $text"
}

required_files=(
  README.md
  agent-gateway-http-v2.md
  execution-report-v1.md
  agent-listener-spec-v1.md
)

for file in "${required_files[@]}"; do
  require_file "$file"
done

require_text README.md '(agent-gateway-http-v2.md)'
require_text README.md '(execution-report-v1.md)'
require_text README.md '(agent-listener-spec-v1.md)'

require_text agent-gateway-http-v2.md 'All production requests use HTTPS and JSON.'
require_text agent-gateway-http-v2.md 'Maximum request body: 1 MiB'
require_text agent-gateway-http-v2.md 'Authorization: Bearer <agent-token>'
require_text agent-gateway-http-v2.md 'POST /api/v2/agents/register'
require_text agent-gateway-http-v2.md 'POST /api/v2/agents/{agentId}/poll'
require_text agent-gateway-http-v2.md 'POST /api/v2/agents/{agentId}/discovery-reports'
require_text agent-gateway-http-v2.md 'POST /api/v2/agents/{agentId}/execution-reports'
require_text agent-gateway-http-v2.md 'Idempotency-Key: <uuid-v4>'
require_text agent-gateway-http-v2.md 'execution-report-v1.md'

require_text execution-report-v1.md 'POST /api/v2/agents/{agentId}/execution-reports'
require_text agent-listener-spec-v1.md '**Historical:**'
require_text agent-listener-spec-v1.md 'HTTP v2'

if grep -n $'\r' "${required_files[@]}"; then
  fail 'carriage-return characters found in Markdown'
fi

if grep -nE '[[:blank:]]+$' "${required_files[@]}"; then
  fail 'trailing whitespace found in Markdown'
fi

printf 'Specification validation passed.\n'
