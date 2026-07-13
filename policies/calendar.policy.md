# Calendar policy

Scheduling, buffers, and focus-time defence. Setup writes this to `{assistantPath}/policies/calendar.policy.md` — outside the plugin. See `rules/paths.md`.

---

## Timezone

[e.g. Australia/Sydney — usually matches profile identity; repeat here for scheduling skills]

## Working hours

- [e.g. Mon–Fri 09:00–17:30; weekends personal]

## Meeting defaults

- **Default length:** [e.g. 30 min]
- **Buffer between meetings:** [e.g. 15 min]
- **Prep block:** [e.g. 15 min before external or Tier 1–2 meetings]
- **Follow-up block:** [e.g. 15 min after meetings 45 min+ or with decisions]

## Protected focus window

[e.g. Mon–Fri 09:00–10:00 deep work — do not propose meetings here]

## Focus-time defence

`gentle` | `moderate` | `assertive` — how hard to protect focus time

## May auto-propose

[e.g. times within working hours to Tier 2+ — draft only]

## Must always ask

Any booking, move, or decline outside pre-approved rules.

## Habit blocks

Recurring personal or focus habits the protect scan expects on the calendar. If a habit day falls in the scan horizon and no event covers ≥ 80% of the window, protect mode emits a `habit` violation and block proposal.

| habit_id | title | days | start_time | duration_minutes | calendar_mark |
| -------- | ----- | ---- | ---------- | ---------------- | ------------- |
| morning-review | Morning review | mon, tue, wed, thu, fri | 08:00 | 30 | Focus time |

Add rows during setup (0–3 habits typical). Remove rows to disable habit scanning for that pattern.

## Scheduling replies

Offer 2–3 specific slots with timezone; match formality to the contact's VIP tier (see `email.policy.md`).
