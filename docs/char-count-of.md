# `char-count-of`

Counts one string or Typst content value immediately and returns a statistics
dictionary.

## Example

```typ
#import "char-count.typ": char-count-of

#let stats = char-count-of([Hello *Typst*!])
#assert(stats.at("characters-with-spaces") == 12)
#assert(stats.at("normal-pages") == 0.005)
```

## Signature

```typ
char-count-of(content, exclude: (), footnotes: true, figures: false) -> dictionary
```

## Parameters

### `content`

`str` or `content` — required, positional

Strings are counted directly. Content is traversed recursively. Text and raw
text contribute their grapheme clusters; spaces and explicit breaks contribute
the whitespace they represent.

```typ
#assert(char-count-of("á").at("characters-with-spaces") == 1)
#assert(char-count-of([Hello world]).at("characters-with-spaces") == 11)
```

### `exclude`

element function, `str`, `label`, selector, array of those, or `()` — optional,
named — default: `()`

Adds patterns to the package's default exclusions. A matching element and all
of its descendants contribute nothing.

```typ
#let body = [Keep #emph[omit]]
#char-count-of(body, exclude: emph).at("characters-with-spaces")
// 5
```

See [Exclusions](exclusions.md) for accepted patterns and limitations.

### `footnotes`

`bool` — optional, named — default: `true`

Footnote text counts by default. Set `footnotes: false` to leave it out.

### `figures`

`bool` — optional, named — default: `false`

Figures are left out by default, body and caption included. Set `figures: true` to count them. Images and equations inside a figure stay excluded either way.

## Result

The returned dictionary currently contains:

```typ
(characters-with-spaces: 12, characters-without-spaces: 11, normal-pages: 0.005)
```

The count uses grapheme clusters rather than bytes or Unicode code points. `characters-without-spaces` skips every whitespace cluster, including the line and paragraph breaks below. `normal-pages` divides `characters-with-spaces` by 2,400, the standard Danish normal-page length. It is not rounded; round it yourself or use `format-danish`.

## Content mapping

Whitespace-like elements are represented as follows:

| Element | Counted representation |
| --- | --- |
| normal space | `" "` |
| `linebreak()` | `"\n"` |
| paragraph break | `"\n\n"` |
| `pagebreak()` | `"\n\n\n\n"` |
| single or double smart quote | one quote character |

So a paragraph break adds 2 characters and a page break adds 4. Blank lines at the start or end of the counted content count too. Whitespace from other sources, like `h()` and `v()`, adds nothing.

Other containers are traversed through `children`, `body`, or their special
figure fields when the container is not excluded.

Term-list items contribute both their term and description. Inline text fragments are joined before counting grapheme clusters, so formatting within a combining sequence or joined emoji does not increase its count. Block-level elements, such as table and grid cells, list items, headings, and footnotes, are counted as separate pieces. A combining accent at the start of one table cell therefore never merges with the last letter of the previous cell.

Nothing is added between neighbouring cells or items. `table([a], [b])` counts as 2 characters, not 3. Generated separators and numbering are not added either.

This function counts the source content tree. It cannot inspect the output of `context` expressions or apply layout-time show rules. See [counting limits](char-count.md#counting-limits) for details and a way to count text inside a context expression.
