# Prefer take/drop over indexed loops

Prefer functional sequence operations (`take`, `drop`, `span`, `takeWhile`, `dropWhile`, `splitAt`, `foreach`, `foldLeft`, …) over walking an index (`var i`, `charAt`, `substring(i, j)`, `while i < n`).

Scan a string by consuming a suffix (`rest.span`, `rest.drop`), not `charAt(i)`. Split a qualified name with `span`/`drop`, not `indexOf` plus `substring`. Iterate a collection with `foreach`/`foldLeft`, not `while idx`.

Use an index only when the API is inherently indexed (Java `Attributes.getLength`/`getLocalName(i)`, array slots that must be filled in place for a recursive cache).
