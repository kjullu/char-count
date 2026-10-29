# `char-count`

Acts as a show rule: it leaves content visually unchanged while adding the
content's statistics to a Typst state value.

## Complete-document example

```typ
#import "char-count.typ": char-count, total-characters-with-spaces, total-normal-pages, total-summary

#show: char-count

Hello world.

Characters: #total-characters-with-spaces
Normal pages: #total-normal-pages
Summary: #total-summary
```

Place the show rule before the content that should be counted. The displayed
total is resolved contextually from the final state.

## Signature

```typ
char-count(content, exclude: (), footnotes: true, figures: false) -> content
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

### `footnotes` and `figures`

Same as in [`char-count-of`](char-count-of.md#footnotes):

```typ
#show: char-count.with(footnotes: false, figures: true)
```

## Reading the total

`total-characters-with-spaces` is contextual content containing the final
value of the `characters-with-spaces` field:

```typ
Total: #total-characters-with-spaces
```

`total-normal-pages` reads the same document-wide count as Danish normal pages,
using 2,400 characters including spaces per page. It is not rounded.

`total-characters-without-spaces` shows the count with whitespace left out.

`total-summary` shows the total the Danish way, with normal pages rounded to two decimals:

```typ
#total-summary // 12.345 tegn · 5,14 normalsider
```

For your own formatting, `format-danish` formats any statistics dictionary. You can change the decimals, the thousands separator and the dot between the two numbers:

```typ
#context format-danish(final-stats(), digits: 1, thousands-separator: " ", separator: " – ")
// 12 345 tegn – 5,1 normalsider
```
 To calculate with the totals, call `final-stats()` inside `context`. It returns the numbers, not content:

```typ
#context {
  let stats = final-stats()
  [#calc.round(stats.normal-pages, digits: 1) normal pages]
}
```

It must be used in a document where `#show: char-count` has initialized the
global state. Otherwise it fails with a hint explaining how to enable the
count.

The lower-level `global-total(field)` reads any named field from the final
statistics dictionary.

## Scope of the show rule

Typst show rules apply from their declaration onward. Content before
`#show: char-count` is not accumulated. Install the rule once at the start of
the document or template for a single document-wide count.

## Counting limits

The total describes the source content passed to the rule, before layout. It is not a count of the final rendered document. Text generated inside `context` expressions is opaque and omitted. Text inserted or replaced by element or string show rules is not reflected in the total. Generated numbering and headers or footers supplied through page settings are also outside the traversed body.

For example, `#context [Hello]` contributes no characters, and a show rule replacing `Hi` with `Hello world` still counts the original `Hi`. The displayed character and normal-page totals themselves are contextual and do not count toward their own totals.

When you control a context expression, count its resolved text inside that expression:

```typ
#show: char-count

#context {
  let resolved = [Hello]
  char-count(resolved)
}
```

This adds `Hello` once because the outer traversal cannot see inside the context expression. Do not wrap ordinary, already-counted body text in another `char-count` call, since that would count it twice. Grapheme clusters are combined within each call, not across separate calls.
