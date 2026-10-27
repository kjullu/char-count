# API reference

This page documents every value exported by `char-count.typ`. Most users only
need the entries in the high-level API section.

## High-level API

### `char-count-of(content, exclude: (), footnotes: true, figures: false)`

Immediately counts a string or content value and returns a statistics
dictionary. See the [full guide](char-count-of.md).

### `char-count(content, exclude: (), footnotes: true, figures: false)`

Show-rule function that returns content unchanged and accumulates its count in
document state. See the [full guide](char-count.md).

### `total-characters-with-spaces`

Contextual content containing the final document-wide count. It requires the
`char-count` show rule.

### `total-normal-pages`

Contextual content containing the final document-wide normal-page count. One
normal page is 2,400 characters including spaces. It requires the `char-count`
show rule.

### `total-characters-without-spaces`

Contextual content containing the final document-wide count with whitespace left out. It requires the `char-count` show rule.

### `total-summary`

Contextual content showing the final total with `format-danish`, for example `12 345 tegn · 5,14 normalsider`. It requires the `char-count` show rule.

### `final-stats()`

Returns the final statistics dictionary as numbers. Call it inside `context`. It fails with a hint if `char-count` is not enabled.

### `format-danish(stats, digits: 2)`

Formats a statistics dictionary as `12 345 tegn · 5,14 normalsider`. Normal pages are rounded half up to `digits` decimals for display only. `digits` must be 0 or more. The rounding uses the character count, so `normal-pages` in the dictionary is ignored.

## Configuration

### `IGNORED_ELEMENTS`

An array of represented element-name strings used as the default exclusion
list. The high-level functions always include these defaults. See
[Exclusions](exclusions.md#default-exclusions).

### `BLOCK_ELEMENTS`

Represented element names that `char-count-of` counts as separate pieces, so grapheme clusters never join across them.

### `NORMAL_PAGE_CHARACTERS`

The number of characters including spaces in one Danish normal page. Its value
is `2400`.

## Low-level helpers

These values are exported for advanced composition and testing. Their shapes
may expose implementation details, so prefer the high-level API when possible.

### `string-char-count(string)`

Counts `string.clusters()` and returns a statistics dictionary with `characters-with-spaces`, `characters-without-spaces`, and `normal-pages`.

### `make-stats(with-spaces, without-spaces)`

Builds a statistics dictionary from two cluster counts and calculates `normal-pages`.

### `dictionary-sum(a, b)`

Returns a new dictionary containing the union of both dictionaries' keys.
Values with the same key are added; a missing key is treated as zero. Values
are expected to support addition.

### `map-tree(f, content, exclude: IGNORED_ELEMENTS, boundary: none)`

Recursively traverses a content tree and calls `f` for text-like leaf strings.
It returns nested arrays and callback results, with ignored branches removed as
`none`. Unlike `char-count-of`, its `exclude` argument replaces the default
rather than extending it.

The callback receives strings for text, raw text, represented whitespace, and
smart quotes. Callers are responsible for flattening and reducing the nested
result. When `boundary` is not `none`, that value is placed before and after the results of each element in `BLOCK_ELEMENTS`.

### `global-total(field)`

Returns contextual content that reads `field` from the final statistics stored
by `char-count`. It asserts that counting was enabled and that the field
exists.

## Internal selector helpers

### `parse-basic-where-selector(selector)`

Converts the represented form of a simple `element.where(..)` selector into a
dictionary with `element-fn` and `fields` entries. Other selector shapes panic.

### `interpret-exclude-patterns(exclude)`

Normalizes an array of exclusion patterns. Strings, labels, and dictionaries
pass through; element functions stay functions; supported selectors
are parsed with `parse-basic-where-selector`. Unsupported types panic.
