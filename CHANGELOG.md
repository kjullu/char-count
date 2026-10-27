# Changelog

## 0.2.0

### Added

- Report Danish normal pages, using 2,400 characters including spaces per page.
- Add `characters-without-spaces`, `total-characters-without-spaces`, `final-stats`, `format-danish`, and `total-summary`.
- Add `footnotes` and `figures` options to `char-count-of` and `char-count`.

### Fixed

- Excluding an element function no longer removes other elements with the same name, like `enum.item` when excluding `list.item`.
- Keep table cells, list items, and other blocks apart when counting grapheme clusters, also when they are excluded.
- Count grapheme clusters across inline formatting boundaries.
- Count both terms and descriptions in term lists.
- Avoid matching exclusion selectors against missing fields.
- Calculate normal pages from the accumulated character count.

### Changed

- Drop element names from older Typst versions from `IGNORED_ELEMENTS`.
- Rewrite the README and document source-content counting limits and counting inside context expressions.

## 0.1.0

Initial packaged release.

- Count Unicode grapheme clusters in strings and Typst content.
- Accumulate a document-wide count through a show rule.
- Exclude elements by function, name, label, or a simple `where` selector.
