---
name: weekly-review
description: Friday afternoon review for the example workspace
schedule: "0 16 * * 5"
skill: /weekly-review
enabled: true
output: output/weekly/{{date}}-review.md
connectors: []
---

## Scheduled task prompt

Run /weekly-review. Save output to output/weekly/YYYY-MM-DD-review.md.

## How to recreate in Cowork

  /schedule "Every Friday at 4pm: run /weekly-review and save
  the output to output/weekly/YYYY-MM-DD-review.md"

Cron: `0 16 * * 5`

## Prerequisites

- Claude Desktop open; machine awake
- On macOS, Cowork view may need to be focused (see docs/product/research.md)

## Known issues

Missed runs when laptop sleeps. No backfill.
