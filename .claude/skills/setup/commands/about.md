# /setup:about

Populates `context/about-me.md` through conversation.

## Questions to ask (one at a time, in order)

1. "What's your name, and what do you like to be called?"
2. "Where are you based? (city, country, timezone)"
3. "Who's in your household? (partner, kids, others — as much or as little as you want to share)"
4. "What are the main areas of your life you'd like help with? (e.g. family logistics, home admin, cooking, health, side projects, personal finances)"
5. "Is there anything you explicitly don't want help with in this workspace? (e.g. work, investment advice)"
6. "What do you value most? (e.g. family time, honesty, doing things properly — a few words is fine)"
7. "Any strong preferences I should know upfront? (e.g. short answers, Australian English, always give options not just one answer)"

## After collecting answers

Write `context/about-me.md` using the template below. Fill in what the user provided; leave placeholders for anything they skipped.

```markdown
# About me

## Basics

- **Name:** [name]
- **Preferred name:** [preferred name]
- **Location:** [city, country]
- **Timezone:** [timezone]

## Household

[household description]

## What I want help with

[bulleted list of areas]

## What I don't want help with here

[list, or "Nothing excluded" if none]

## Things I value

[list]

## Preferences

[list]
```

Confirm: "I've saved your about-me. Does anything look wrong or need adjusting?"
