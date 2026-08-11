# char-count documentation

`char-count` counts Unicode grapheme clusters: the user-perceived characters
returned by Typst's `str.clusters()`. A combining sequence such as `á` and a
joined family emoji each count as one character.

## Main functions

| Function | Use it for |
| --- | --- |
| [`char-count-of`](char-count-of.md) | Count one string or content value immediately. |
| [`char-count`](char-count.md) | Accumulate a count across a complete document. |
| [`total-characters-with-spaces`](char-count.md#reading-the-total) | Display the final document-wide total. |

For most one-off counts, use `char-count-of`. Use `char-count` as a show rule
when the total must include the document body.

## Basic usage

```typ
#import "char-count.typ": char-count-of

#let stats = char-count-of([Hello *world*!])
There are #stats.at("characters-with-spaces") characters.
```

The result is a dictionary so more statistics can be added without changing
the calling convention. Version 0.1.0 provides one field:

| Field | Type | Meaning |
| --- | --- | --- |
| `characters-with-spaces` | `int` | Grapheme clusters, including represented whitespace. |

See [Exclusions](exclusions.md) for the default ignored elements and ways to
omit additional content. [The API reference](api-reference.md) documents every
exported value, including low-level traversal helpers.
