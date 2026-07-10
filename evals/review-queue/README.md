# Review queue fixtures

Synthetic working-folder fixtures for dashboard smoke tests and schema validation. Maintainer docs: [`.agency/work/review-queue/`](../../.agency/work/review-queue/) (design, spec, tasks).

**Schema:** [`config/review.schema.yaml`](../../config/review.schema.yaml)  
**Runtime rule:** [`rules/approval-frame.md`](../../rules/approval-frame.md)

## Copy into a test working folder

```bash
WORK=/tmp/my-assistant-review-queue-test
mkdir -p "$WORK/review-queue" "$WORK/drafts" "$WORK/pending-memory" "$WORK/pending-profile"

cp evals/review-queue/fixtures/sample-index.yaml "$WORK/review-queue/index.yaml"
cp -R evals/review-queue/fixtures/sources/drafts "$WORK/"
cp -R evals/review-queue/fixtures/sources/pending-memory "$WORK/"
cp -R evals/review-queue/fixtures/sources/pending-profile "$WORK/"
cp evals/review-queue/fixtures/sources/review-queue/archives-2026-07-08.yaml "$WORK/review-queue/"
```

Then open `skills/dashboard.html`, select `$WORK`, and switch to the **Review** tab — six queue types should appear.

## Error-path fixture

`fixtures/broken-index.yaml` — copy to `$WORK/review-queue/index.yaml` to verify the dashboard surfaces a parse error instead of a silent empty queue.

## Schema validation

Compare `fixtures/sample-index.yaml` items against `config/review.schema.yaml`. Optional: `yamllint evals/review-queue/fixtures/sample-index.yaml`.
