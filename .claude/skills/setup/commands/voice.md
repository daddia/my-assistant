# /setup:voice

Populates `context/voice-and-style.md` through conversation.

## Questions to ask (one at a time)

1. "How would you describe your writing voice in one sentence? (e.g. 'Direct and warm, no corporate fluff')"
2. "What locale/spelling? (e.g. Australian English, British English, American English)"
3. "Any date, time, or number format preferences? (e.g. '24 May' not '05/24', 24-hour clock)"
4. "How do you want me to structure responses? (e.g. short paragraphs, always use bullet points for lists, lead with the answer)"
5. "How long should responses be by default?"
6. "When writing personal messages or emails AS you — how should I sign off? (e.g. first name only, full name for formal)"
7. "Anything to always avoid in tone? (e.g. no flattery, no 'Great question!', no corporate-speak)"

## Show an example

After question 5, ask: "Here's a sample response in that style. Does it sound right?" and show a short example in the described voice. Adjust if needed.

## Write the file

```markdown
# Voice and style

## Voice in one line

> [user's description]

## Language

- [locale]: [examples of spelling]
- Dates: [format]
- Time: [format]
- Currency: [format]
- Units: [metric / imperial]

## Tone

- [list of tone principles]

## Structure

- [list of structural principles]

## Length

- [default length preference]
- [long-form: when to use]

## What to avoid

- [list]

## When writing AS me

- Sign-off: [context → name]
- Opener: [e.g. "Hi [Name],"]
- Tone: [description]

## When writing TO me

- [list of preferences]
```

Confirm: "I've saved your voice and style. Does the sample still sound right?"
