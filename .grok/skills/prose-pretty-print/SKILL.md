---
name: prose-pretty-print
description: >
  Reflow Markdown and AsciiDoc with bin/pretty-print instead of by hand or with a script.
  Use when editing a .md, .markdown, .adoc, or .asciidoc file.
  Do not use for memory files, HTML, XML, or a file that was only read.
metadata:
  short-description: "Run bin/pretty-print; do not reflow prose by hand"
---

# Prose pretty-print

Run this on a Markdown or AsciiDoc file you are editing.
Do not reflow it by hand and do not write a script.

```
/home/dub/Podval/site-publisher/bin/pretty-print [--width=N] [--sentence-per-line=true|false] FILE...
```

`--width=N` defaults to 120.
`--width=0` does not wrap.
`--sentence-per-line` defaults to true.
`--sentence-per-line=false` only wraps.
Write the number as `--width=N`.
A space before the number is not accepted.

The extensions are the ones on the Markdown and AsciiDoc `Markup` instances: `.md`, `.markdown`, `.adoc`, `.asciidoc`.

## Leave unchanged

Fences, indented code, AsciiDoc listings and literals, tables, YAML and TOML front matter, AsciiDoc attributes,
`include::`, `ifdef::`, headings, HTML comments, and diagram or math fences.

A skip on stderr (`asset`, `crlf`, `malformed`, `bad-utf8`) is a failure.
Do not finish that file by hand.

## Do not run it

- Anything under `~/.grok/memory-v2/`.
- HTML, XML, TEI, or DocBook.
  The site walk pretty-prints TEI and DocBook.
  This script does not.
- A file you only read.
- Chat replies and commit messages.

## Site tree

`prettyPrintSite` reflows Markdown and AsciiDoc in a checkout that has `_site_config.yml`, plus TEI and DocBook.
It is not the command for `AGENTS.md` or a rule file.
The site walk skips root `README.md` and `README.adoc`.
Those go through the script.

## Classpath

Exit 2 means the classpath file is missing or a flag is wrong.
From `/home/dub/Podval/site-publisher` run:

```
./gradlew :org.podval.tools.publisher:prosePrettyPrintClasspath
```

Then retry the script.
Do not start Gradle from the script itself.
