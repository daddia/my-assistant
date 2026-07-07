# Email thread -- product decision (7 messages)

---

**From:** Sam Patel <sam.patel@northwind-eval.test>
**To:** Alex Rivera <alex.rivera@northwind-eval.test>, Jordan Kim <jordan.kim@northwind-eval.test>
**Subject:** Re: v2 feature scope -- offline mode debate
**Date:** Thu, 2 Jul 2026 09:10:22 +1000

Team,

After the eng spike, offline mode is 6-8 weeks, not 3. Options:

**A.** Ship beta without offline; add in v2.1 (Sam recommends)
**B.** Delay beta 4 weeks; ship with basic offline
**C.** Ship beta with offline flag disabled; enable for enterprise pilot only

We need a decision by Friday so QA can lock the test matrix.

Sam

---

**From:** Jordan Kim <jordan.kim@northwind-eval.test>
**To:** Sam Patel, Alex Rivera
**Subject:** Re: v2 feature scope -- offline mode debate
**Date:** Thu, 2 Jul 2026 10:45:11 +1000

Investors will ask about offline at the 15 Jul board meeting. I'd rather have a story ("coming in v2.1, here's why") than slip the beta date again.

Alex -- what's your call? I'm leaning A but want product sign-off.

Jordan

---

**From:** Alex Rivera <alex.rivera@northwind-eval.test>
**To:** Jordan Kim, Sam Patel
**Subject:** Re: v2 feature scope -- offline mode debate
**Date:** Thu, 2 Jul 2026 14:22:08 +1000

Leaning A too. Let me check with the two beta customers who flagged offline -- if neither is a blocker, we go A.

Alex

---

**From:** Priya Sharma <priya.sharma@northwind-eval.test>
**To:** Alex Rivera
**Subject:** Re: v2 feature scope -- offline mode debate
**Date:** Fri, 3 Jul 2026 08:30:44 +1000

Alex -- reached out to beta contacts:

- **Acme Retail:** offline is nice-to-have, not blocking beta
- **Blue Harbor Logistics:** offline is critical for warehouse floors (no signal)

Blue Harbor is a logo customer for the case study. Worth a conversation before we cut scope.

Priya

---

**From:** Sam Patel <sam.patel@northwind-eval.test>
**To:** Alex Rivera, Jordan Kim, Priya Sharma
**Subject:** Re: v2 feature scope -- offline mode debate
**Date:** Fri, 3 Jul 2026 11:15:33 +1000

If we do option C for Blue Harbor only, eng cost is ~2 weeks (feature flag + limited sync). Not free, but better than full offline for everyone.

Sam

---

**From:** Jordan Kim <jordan.kim@northwind-eval.test>
**To:** All
**Subject:** Re: v2 feature scope -- offline mode debate
**Date:** Fri, 3 Jul 2026 15:40:19 +1000

C sounds like a reasonable compromise. Alex -- can you confirm by EOD Monday? Board pre-read needs the final scope.

Jordan

---

**From:** Sam Patel <sam.patel@northwind-eval.test>
**To:** Alex Rivera
**Subject:** Re: v2 feature scope -- offline mode debate
**Date:** Mon, 6 Jul 2026 08:55:02 +1000

Bumping this -- QA is waiting. Option A, B, or C?

Sam
