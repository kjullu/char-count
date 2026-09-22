# Changelog

## Unreleased

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
