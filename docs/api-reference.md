# API reference

This page documents every value exported by `char-count.typ`. Most users only
need the four entries in the high-level API section.

## High-level API

### `char-count-of(content, exclude: ())`

Immediately counts a string or content value and returns a statistics
dictionary. See the [full guide](char-count-of.md).

### `char-count(content, exclude: ())`

Show-rule function that returns content unchanged and accumulates its count in
document state. See the [full guide](char-count.md).

### `total-characters-with-spaces`

Contextual content containing the final document-wide count. It requires the
`char-count` show rule.

### `total-normal-pages`

Contextual content containing the final document-wide normal-page count. One
normal page is 2,400 characters including spaces. It requires the `char-count`
show rule.

## Configuration

### `IGNORED_ELEMENTS`

An array of represented element-name strings used as the default exclusion
list. The high-level functions always include these defaults. See
[Exclusions](exclusions.md#default-exclusions).

### `NORMAL_PAGE_CHARACTERS`

The number of characters including spaces in one Danish normal page. Its value
is `2400`.

## Low-level helpers

These values are exported for advanced composition and testing. Their shapes
may expose implementation details, so prefer the high-level API when possible.

### `string-char-count(string)`

Counts `string.clusters()` and returns character and normal-page counts:

```typ
(
  characters-with-spaces: string.clusters().len(),
  normal-pages: string.clusters().len() / NORMAL_PAGE_CHARACTERS,
)
```

### `dictionary-sum(a, b)`

Returns a new dictionary containing the union of both dictionaries' keys.
Values with the same key are added; a missing key is treated as zero. Values
are expected to support addition.

### `map-tree(f, content, exclude: IGNORED_ELEMENTS)`

Recursively traverses a content tree and calls `f` for text-like leaf strings.
It returns nested arrays and callback results, with ignored branches removed as
`none`. Unlike `char-count-of`, its `exclude` argument replaces the default
rather than extending it.

The callback receives strings for text, raw text, represented whitespace, and
smart quotes. Callers are responsible for flattening and reducing the nested
result.

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
pass through; element functions become represented names; supported selectors
are parsed with `parse-basic-where-selector`. Unsupported types panic.
