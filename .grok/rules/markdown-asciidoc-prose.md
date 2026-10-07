# Markdown and AsciiDoc prose: sentence per line, wrap at 120

When you write or edit Markdown or AsciiDoc (`.md`, `.markdown`, `.adoc`, `.asciidoc`), reformat the whole file by
running:

```
/home/dub/Podval/site-publisher/bin/pretty-print FILE
```

Do not reflow by hand.
Do not write a Python or regex script.
Do not leave the rest of the file in the old wrap.
This applies to every such file you touch: README, notes, fixtures, `AGENTS.md`, skills, and Grok rules.
Do not reformat a file you only read.
Do not apply this to chat replies, commit messages, memory files, or other file types.

If the script exits 2, run `./gradlew :org.podval.tools.publisher:prosePrettyPrintClasspath` once from the
site-publisher repo and retry.
If it exits 1, the stderr line names the file.
Do not finish that reflow yourself.

Memory files are the notes under `~/.grok/memory-v2/` (`topics/`, `observations/`, and archives).
When you edit one, change the fact and leave the rest of the file as it is.
Do not point the script at that tree.

`--sentence-per-line` defaults to true.
`--sentence-per-line=false` only wraps.
`--width=N` defaults to 120.
`--width=0` does not wrap.
The flag is `--width=N`, with the equals sign.

A checkout that has `_site_config.yml` can use Gradle `prettyPrintSite` for the whole tree.
Root `README.md` and `README.adoc` are ignored by that walk.
Use the script for those.
`AGENTS.md` and a rule file use the script, not `prettyPrintSite`.

## Layout

The script is the implementation of this contract.

- Each sentence starts on a new line, unless `--sentence-per-line=false`.
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

The script leaves these as authored:

- Fenced code, indented code, and AsciiDoc listing or literal blocks (`----`, `....`)
- Tables (one source row per table row)
- YAML or TOML front matter
- AsciiDoc attribute entries, `include::`, `ifdef::`, `endif::`
- Headings (keep one line even if longer than 120)
- HTML comments and Mermaid, math, or other diagram fences
