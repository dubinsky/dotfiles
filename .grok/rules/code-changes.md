# Code changes

## Comments

Keep existing comments when moving or refactoring (TODOs, ordering constraints, "why" notes).
Move them with the code they describe.
Drop or rewrite a comment only if it is factually wrong.

## Tests

When the repository has `gradlew`, run `./gradlew test` before considering a change complete.

## Build output

`build/` is gitignored generated output and can be very large.
Do not read it.
