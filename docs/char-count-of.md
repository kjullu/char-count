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
char-count-of(content, exclude: ()) -> dictionary
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

## Result

The returned dictionary currently contains:

```typ
(characters-with-spaces: 12, normal-pages: 0.005)
```

The count uses grapheme clusters rather than bytes or Unicode code points. It
does not currently provide a character count with spaces removed. `normal-pages`
divides `characters-with-spaces` by 2,400, the standard Danish normal-page
length.

## Content mapping

Whitespace-like elements are represented as follows:

| Element | Counted representation |
| --- | --- |
| normal space | `" "` |
| `linebreak()` | `"\n"` |
| paragraph break | `"\n\n"` |
| `pagebreak()` | `"\n\n\n\n"` |
| single or double smart quote | one quote character |

Other containers are traversed through `children`, `body`, or their special
figure fields when the container is not excluded.

Term-list items contribute both their term and description. Inline text fragments are joined before counting grapheme clusters, so formatting within a combining sequence or joined emoji does not increase its count. Generated separators and numbering are not added.

This function counts the source content tree. It cannot inspect the output of `context` expressions or apply layout-time show rules. See [counting limits](char-count.md#counting-limits) for details and a way to count text inside a context expression.
