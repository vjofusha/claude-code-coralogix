# Claude Code Observability with Coralogix

Monitor your Claude Code AI agent sessions in real time — token spend, costs, session activity, code changes, and tool behaviour — all flowing into Coralogix over native OpenTelemetry.

No SDK. No code changes. Just environment variables.

---

## What you get

Once connected, Coralogix receives two types of signals automatically:

**Metrics** — counters that accumulate across every session:

| Metric | What it tracks |
|---|---|
| `claude_code_session_count_1_total` | Sessions started |
| `claude_code_token_usage_1_total` | Tokens per model and type (input / output / cache) |
| `claude_code_cost_usage_USD_total` | Estimated USD cost per model |
| `claude_code_lines_of_code_count_1_total` | Lines added and removed |
| `claude_code_commit_count_total` | Git commits made during a session |
| `claude_code_code_edit_tool_decision_total` | Accept / reject decisions on code edits |
| `claude_code_active_time_total_s_total` | Time Claude was actively processing |

**Log events** — one record per notable action, routed to your chosen subsystem:

| Event | What it captures |
|---|---|
| `claude_code.user_prompt` | Prompt submitted (content redacted by default) |
| `claude_code.api_request` | Token counts, cost, latency, and model per request |
| `claude_code.api_error` | API failures with status and error message |
| `claude_code.tool_result` | Tool execution outcome, duration, and decision |

All signals include `session.id`, `user.id`, `user.email`, `organization.id`, `app.version`, and `terminal.type` as attributes.

---

## Pre-built dashboard

A ready-to-import Coralogix dashboard is included as `coralogix-dashboard.json`. It covers:

| Section | Widgets |
|---|---|
| **KPI Overview** | Total Sessions · Total Cost (USD) · Total Tokens · Active Time |
| **Engineering** | Lines Added & Removed · Commits Over Time · Cost per Model · Sessions Over Time |
| **Tool Activity** | Edit Tool Decisions by type · Acceptance Rate gauge · Token Usage by Type |
| **User Activity** | Cost per Session · Tokens per Session · Avg Session Duration · Tokens by Model |
| **Prompt Log** | Live table — timestamp, session ID, model, event type, body |

**To import:**
1. In your Coralogix tenant go to **Dashboards → New Dashboard**
2. Open the import menu and paste the contents of `coralogix-dashboard.json`
3. Save — widgets populate as soon as data flows in

To regenerate or customise the JSON:

```bash
python3 gen_dashboard.py
```

---

## Quick start

### 1. Set your credentials

```bash
cp .env.example .env
```

Edit `.env`:

```
CX_API_KEY=<your-send-your-data-api-key>
CX_OTLP_ENDPOINT=https://ingress.eu1.coralogix.com
CX_APPLICATION_NAME=claude-code
CX_SUBSYSTEM_NAME=claude-code-sessions
```

**Endpoint by region:**

| Coralogix domain | Region | OTLP endpoint |
|---|---|---|
| `us1.coralogix.com` | US1 | `https://ingress.us1.coralogix.com` |
| `us2.coralogix.com` | US2 | `https://ingress.us2.coralogix.com` |
| `eu1.coralogix.com` | EU1 | `https://ingress.eu1.coralogix.com` |
| `eu2.coralogix.com` | EU2 | `https://ingress.eu2.coralogix.com` |
| `ap1.coralogix.com` | AP1 | `https://ingress.ap1.coralogix.com` |
| `ap2.coralogix.com` | AP2 | `https://ingress.ap2.coralogix.com` |
| `ap3.coralogix.com` | AP3 | `https://ingress.ap3.coralogix.com` |

Your domain appears in the URL when you log in to your Coralogix tenant.

### 2. Start a session with telemetry

```bash
source activate.sh
claude
```

> `activate.sh` must be **sourced**, not executed — this keeps the exported variables in your current shell. Re-source it whenever you open a new terminal.

### 3. Persistent setup (optional)

To avoid sourcing on every terminal, add these to `~/.config/claude-code/settings.json`:

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "http/protobuf",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "https://ingress.eu1.coralogix.com",
    "OTEL_EXPORTER_OTLP_HEADERS": "Authorization=Bearer <YOUR_CX_API_KEY>",
    "OTEL_RESOURCE_ATTRIBUTES": "cx.application.name=<APP>,cx.subsystem.name=<SUBSYSTEM>",
    "OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE": "delta"
  }
}
```

---

## Verify the connection

Run the included test script before starting a real session:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 ping.py
```

Expected output:

```
Sending test telemetry to: https://ingress.eu1.coralogix.com
────────────────────────────────────────────────────────────
Recording test metrics …
Recording test log events …

Flushing … (waiting 7 s for the metric export interval)
✓  Metrics exported successfully
✓  Log events exported successfully

Done! Open your Coralogix tenant and look for:
  Metrics  → Metrics Explorer → search "claude_code"
  Logs     → filter subsystemName = claude-code-sessions
```

---

## Finding your data in Coralogix

| Where | What to look for |
|---|---|
| **Metrics Explorer** | Search `claude_code` — all counters appear here |
| **Logs** | Filter `subsystemName = claude-code-sessions` |
| **Dashboards** | Import `coralogix-dashboard.json` (see above) |

---

## Advanced configuration

| Variable | Default | Effect |
|---|---|---|
| `OTEL_METRIC_EXPORT_INTERVAL` | `60000` | Metric flush interval in ms — set to `10000` while debugging |
| `OTEL_LOGS_EXPORT_INTERVAL` | `5000` | Log flush interval in ms |
| `OTEL_LOG_USER_PROMPTS` | off | Set to `1` to capture prompt content in log events |
| `OTEL_LOG_TOOL_DETAILS` | off | Set to `1` to include MCP server and tool names in tool events |
| `OTEL_RESOURCE_ATTRIBUTES` | — | Append custom attributes, e.g. `team=platform,env=prod` |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | `true` | Adds `session.id` to metric labels (increases cardinality) |
| `OTEL_METRICS_INCLUDE_ACCOUNT_UUID` | `true` | Adds `user.account_uuid` to metric labels |
