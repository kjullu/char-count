# `char-count`

Acts as a show rule: it leaves content visually unchanged while adding the
content's statistics to a Typst state value.

## Complete-document example

```typ
#import "char-count.typ": char-count, total-characters-with-spaces, total-normal-pages

#show: char-count

Hello world.

Characters: #total-characters-with-spaces
Normal pages: #total-normal-pages
```

Place the show rule before the content that should be counted. The displayed
total is resolved contextually from the final state.

## Signature

```typ
char-count(content, exclude: ()) -> content
```

### `content`

`content` — supplied by Typst when used with `#show:`

The original content is returned unchanged.

### `exclude`

Additional exclusion patterns, with the same forms and behavior as
[`char-count-of`](char-count-of.md#exclude). Bind the named argument with
`.with` when installing the show rule:

```typ
#show: char-count.with(exclude: (heading, emph))
```

## Reading the total

`total-characters-with-spaces` is contextual content containing the final
value of the `characters-with-spaces` field:

```typ
Total: #total-characters-with-spaces
```

`total-normal-pages` reads the same document-wide count as Danish normal pages,
using 2,400 characters including spaces per page.

It must be used in a document where `#show: char-count` has initialized the
global state. Otherwise it fails with a hint explaining how to enable the
count.

The lower-level `global-total(field)` reads any named field from the final
statistics dictionary.

## Scope of the show rule

Typst show rules apply from their declaration onward. Content before
`#show: char-count` is not accumulated. Install the rule once at the start of
the document or template for a single document-wide count.
