# Code changes

## Comments

Keep existing comments when moving or refactoring (TODOs, ordering constraints, "why" notes).
Move them with the code they describe.
Drop or rewrite a comment only if it is factually wrong.

## Tests

When the repository has `gradlew`, run `./gradlew test` before considering a change complete.

The shell starts in the session workspace.
That directory is often the main checkout, and a linked worktree is a different Gradle project.
`./gradlew` builds the checkout it is started in.
`git -C <worktree>` does not select that checkout.
`cd` into the checkout whose sources changed, then run `./gradlew`.
`BUILD SUCCESSFUL` or `UP-TO-DATE` from any other checkout is not a result for this one.
When more than one worktree changed, run the suite in each of them.

site-publisher stays on `/home/dub/Podval/site-publisher`.
`settings.gradle` includeBuilds `../xml`, so a worktree outside Podval tests a different classpath.
Do not run that suite from such a worktree, and do not report the Podval checkout's result as that worktree's result.

## Build output

`build/` is gitignored generated output and can be very large.
Do not read it.
