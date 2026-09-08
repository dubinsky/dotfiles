# Prefer take/drop over indexed loops

Prefer functional sequence operations (`take`, `drop`, `span`, `takeWhile`, `dropWhile`, `splitAt`, `foreach`, `foldLeft`, …) over walking an index (`var i`, `charAt`, `while i < n`).

`String.substring` is a slice, same family as `drop`/`take` — use either. Do not treat `substring` as an indexed loop.

Scan a string by consuming a suffix (`rest.span`, `rest.drop` / `rest.substring`), not `charAt(i)` in a loop. Iterate a collection with `foreach`/`foldLeft`, not `while idx`.

Use an index only when the API is inherently indexed (Java `Attributes.getLength`/`getLocalName(i)`, array slots that must be filled in place for a recursive cache).
