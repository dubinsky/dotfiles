# Markdown and AsciiDoc prose: sentence per line, wrap at 120

When you write or edit Markdown or AsciiDoc (`.md`, `.markdown`, `.adoc`, `.asciidoc`), reformat the **whole file**.
Do not leave the rest of the file in the old wrap.
This applies to every such file you touch: README, notes, fixtures, `AGENTS.md`, skills, Grok rules, and memory notes.
Do not reformat a file you only read.
Do not apply this to chat replies, commit messages, or other file types.

## Layout

- Each sentence starts on a new line.
- Wrap a sentence that would run past column 120 at a word boundary (the last space at or before 120).
- Do not break inside inline code, a URL, or a link/wiki-link target.
  Keep that token on one line even if it exceeds 120.
- Separate paragraphs with a blank line.

A wrapped continuation in a paragraph is flush left.
Markdown and AsciiDoc join adjacent lines in a paragraph.
In a list item or block quote, hanging-indent wrapped lines so they remain part of that item or quote.

Do not start a new sentence on the same line after `.`, `?`, or `!`.
Do not treat `e.g.`, `i.e.`, `etc.`, `vs.`, `Dr.`, or version numbers like `0.2.0` as sentence ends.

## Do not reflow

Leave these as authored (do not wrap or sentence-split inside them):

- Fenced code, indented code, and AsciiDoc listing or literal blocks (`----`, `....`)
- Tables (one source row per table row)
- YAML or TOML front matter
- AsciiDoc attribute entries, `include::`, `ifdef::`, `endif::`
- Headings (keep one line even if longer than 120)
- HTML comments and Mermaid, math, or other diagram fences
