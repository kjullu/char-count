# Changelog

## Unreleased

- Excluding an element function no longer removes other elements with the same name, like `enum.item` when excluding `list.item`.
- Keep table cells, list items, and other blocks apart when counting grapheme clusters.
- Add `characters-without-spaces`, `total-characters-without-spaces`, `final-stats`, `format-danish`, and `total-summary`.
- Add `footnotes` and `figures` options to `char-count-of` and `char-count`.
- Drop element names from older Typst versions from `IGNORED_ELEMENTS`.

- Avoid matching exclusion selectors against missing fields.
- Count both terms and descriptions in term lists.
- Count grapheme clusters across inline formatting boundaries.
- Calculate normal pages from the accumulated character count.
- Document source-content counting limits and counting inside context expressions.

- Report Danish normal pages using 2,400 characters including spaces per page.

## 0.1.0

Initial packaged release.

- Count Unicode grapheme clusters in strings and Typst content.
- Accumulate a document-wide count through a show rule.
- Exclude elements by function, name, label, or a simple `where` selector.
