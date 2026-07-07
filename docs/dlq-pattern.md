# Dead-Letter Queue Pattern

This document explains why the notification pipeline uses a
dead-letter queue (DLQ), how it's implemented, and how to inspect and
recover failed messages.

## The Problem

Kafka consumers process messages from a partition **in order**. If a
single message can never be processed successfully (invalid email,
SMTP provider down, malformed payload), the consumer has only two bad
options without a DLQ:

1. **Retry forever** — the consumer blocks on that one message,
   nothing else in the partition gets processed, and the pipeline
   effectively stalls.
2. **Drop it silently** — the message (and the notification it
   represents) is lost with no trace and no way to investigate later.

Neither is acceptable for a system meant to reliably deliver
notifications.

## The Solution

The consumer retries a bounded number of times with exponential
backoff, and only after exhausting retries does it move the message
to a separate topic (`notifications-dlq`) — then commits the original
offset and moves on. The main pipeline keeps flowing; nothing is lost.

```
notifications topic
        │
        ▼
  ┌───────────┐
  │  Consumer │
  └─────┬─────┘
        │
   attempt 1 ──fail──▶ wait (base delay)
        │
   attempt 2 ──fail──▶ wait (base delay × 2)
        │
   attempt 3 ──fail──▶ give up
        │
        ▼
  notifications-dlq topic ──▶ DLQ Handler (logs the failure)
```

## Retry Configuration

Controlled via environment variables on the consumer deployment:

| Variable | Default | Meaning |
|---|---|---|
| `MAX_RETRIES` | `3` | Total attempts before giving up |
| `RETRY_BASE_DELAY_MS` | `500` | Initial backoff delay; doubles each retry |

With defaults: attempt 1 (immediate) → wait 500ms → attempt 2 → wait
1000ms → attempt 3 → give up. Total added latency before a message
reaches the DLQ: ~1.5 seconds.

## DLQ Message Format

When a message fails all retries, the consumer publishes a new message
to `notifications-dlq` (not the original message unmodified) containing:

```json
{
  "email": "original recipient",
  "message": "original message body",
  "error": "the error string from the last failed attempt",
  "failed_at": "ISO8601 timestamp of when retries were exhausted"
}
```

This is intentionally richer than the original message — the `error`
and `failed_at` fields are what make the DLQ actually useful for
triage, rather than just a copy of the input.

## The DLQ Handler

A separate consumer (its own consumer group: `dlq-handler-group`, kept
distinct from the main `notification-consumer-group` so the two never
compete for partitions) reads `notifications-dlq` and currently logs
each failure in a structured, greppable format:

```
DLQ MESSAGE | email=... | message="..." | error="..." | failed_at=...
```

This is deliberately minimal for this lab. In a production system, the
natural next steps here would be:
- Persisting DLQ entries to a database for manual review
- Alerting (Slack/PagerDuty) when the DLQ receives messages
- A separate "replay" tool to re-publish DLQ messages back to
  `notifications` after the underlying issue (e.g. SMTP outage) is
  fixed

## Inspecting the DLQ Manually

```bash
kubectl exec -it -n kafka kafka-cluster-dual-role-0 -- \
  /opt/kafka/bin/kafka-console-consumer.sh \
  --bootstrap-server localhost:9092 \
  --topic notifications-dlq \
  --from-beginning
```

Or check the DLQ handler's own logs, which already parse and format
each entry:

```bash
kubectl logs -n notifications deployment/dlq-handler --tail=50
```

## Why Partition Counts Matter Here

`notifications` has 3 partitions (allowing up to 3 consumer replicas
to process in parallel, and giving KEDA something meaningful to scale
against). `notifications-dlq` has only 1 partition — the failure path
is expected to be low-volume, and there's no benefit to parallelizing
DLQ writes/reads at this scale.