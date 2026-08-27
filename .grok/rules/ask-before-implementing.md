# Ask before implementing

Before starting to implement — in this project or any other — ask Leonid every question needed to fill blanks and disambiguate the request.

Do not guess product intent, scope, names, file placement, markup/syntax, or “the usual way” when the request leaves it open. Explore the codebase first so the questions are the remaining human decisions, not things already specified in the prompt, AGENTS.md, or existing code.

Ask them all in one pass. Do not start coding, scaffolding, or “a first cut” until those answers are in. Do not drip-feed a question after already changing files.

Skip the questionnaire only when the request is already fully determined (typo, exact command, explicit “just do X as specified”). Clear reversible work still does not need permission; it needs no blanks.

Use `ask_user_question` when the choices are discrete. Open-ended gaps go in the reply. If a later discovery opens a new blank, stop and ask before continuing.
