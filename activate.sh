#!/usr/bin/env bash
# Source this file (do NOT execute it) to export Claude Code telemetry env vars:
#   source activate.sh

set -a
# shellcheck source=.env
source "$(dirname "${BASH_SOURCE[0]}")/.env"
set +a

# ── Claude Code telemetry toggle ──────────────────────────────────────────────
export CLAUDE_CODE_ENABLE_TELEMETRY=1

# ── OTLP exporters ────────────────────────────────────────────────────────────
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp

# Coralogix expects HTTP/protobuf
export OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf

# Coralogix OTLP ingress endpoint (base URL — no signal suffix)
export OTEL_EXPORTER_OTLP_ENDPOINT="${CX_OTLP_ENDPOINT}"

# Authenticate with the Coralogix Send-Your-Data API key
# Application and subsystem names are passed as resource attributes
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Bearer ${CX_API_KEY}"

# Map application / subsystem via OTEL resource attributes
export OTEL_RESOURCE_ATTRIBUTES="cx.application.name=${CX_APPLICATION_NAME},cx.subsystem.name=${CX_SUBSYSTEM_NAME}"

# Coralogix works best with delta temporality for counters
export OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE=delta

echo "✓  Claude Code → Coralogix telemetry configured"
echo "   Endpoint : ${OTEL_EXPORTER_OTLP_ENDPOINT}"
echo "   App      : ${CX_APPLICATION_NAME}"
echo "   Subsystem: ${CX_SUBSYSTEM_NAME}"
echo ""
echo "Run 'claude' to start a session with telemetry enabled."
