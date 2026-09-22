# Exclusions

Both counting functions omit non-prose content by default. The `exclude`
argument adds patterns; it does not remove the defaults.

## Default exclusions

The exported `IGNORED_ELEMENTS` array contains these element names:

```text
bibliography, outline, cite, display, equation, h, hide, image, line,
locate, figure, metadata, path, polygon, ref, repeat, style, update, v
```

Because `figure` is excluded, both its body and caption are omitted by the
high-level counting functions unless you use the low-level `map-tree` helper
with a different exclusion list.

## Element functions

Pass an element function to omit every instance of that element:

```typ
#char-count-of([Keep #emph[omit]], exclude: emph)
#char-count-of([Title #footnote[omit]], exclude: (emph, footnote))
```

A single value and an array are both accepted.

## Element-name strings

Strings use Typst's represented element names and are useful when a function
is inconvenient to pass:

```typ
#char-count-of([Keep #emph[omit]], exclude: "emph")
```

The low-level figure traversal also recognizes the special strings
`"figure-body"` and `"caption"`.

## Labels

A label excludes the labelled element and all descendants:

```typ
#char-count-of([Keep #emph[omit] <private>], exclude: <private>)
```

The whitespace outside the labelled element is still counted.

## Simple `where` selectors

Selectors can match element fields:

```typ
#char-count-of(
  [#heading(level: 1)[Keep] #heading(level: 2)[Omit]],
  exclude: heading.where(level: 2),
)
```

Only selectors represented as `element.where(key: value, ..)` are supported.
Compound selectors, regex selectors, selector combinations, and arbitrary
selector transformations are rejected. This limitation exists because Typst
does not expose selector targets and fields directly.

## Subtree behavior

An exclusion removes the entire matched subtree. For example, excluding
`emph` removes the emphasized text itself rather than merely ignoring its
styling. Excluding multiple nested elements does not double-subtract content.

Selectors compare only fields explicitly present in the input content. Missing fields never match, even if a set rule or Typst default would supply a value during layout. For headings written with `=` syntax, use `heading.where(depth: 2)` to exclude `==` headings. Use `heading.where(level: 2)` when the heading explicitly supplies `level: 2`. Inherited styles and computed heading levels are not resolved by this traversal.
