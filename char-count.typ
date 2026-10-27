// char-count: count source-content grapheme clusters in strings and Typst content.

/// Add the numeric values from two dictionaries, treating missing keys as 0.
#let dictionary-sum(a, b) = {
  let result = (:)
  for key in (a.keys() + b.keys()).dedup() {
    result.insert(key, a.at(key, default: 0) + b.at(key, default: 0))
  }
  result
}

/// Number of characters, including spaces, in one Danish normal page.
#let NORMAL_PAGE_CHARACTERS = 2400

/// Build a statistics dictionary from the two raw cluster counts.
#let make-stats(with-spaces, without-spaces) = (
  characters-with-spaces: with-spaces,
  characters-without-spaces: without-spaces,
  normal-pages: with-spaces / NORMAL_PAGE_CHARACTERS,
)

/// Count grapheme clusters and Danish normal pages in a string.
///
/// Returns character counts with and without whitespace, and normal pages.
/// One normal page is 2,400 characters including spaces.
#let string-char-count(string) = {
  let clusters = string.clusters()
  let whitespace = clusters.filter(cluster => cluster.match(regex("^\\s+$")) != none)
  make-stats(clusters.len(), clusters.len() - whitespace.len())
}

/// Element names ignored by `char-count-of` and `char-count` by default.
#let IGNORED_ELEMENTS = (
  "bibliography",
  "outline",
  "cite",
  "counter-update",
  "equation",
  "h",
  "hide",
  "image",
  "line",
  "figure",
  "metadata",
  "path",
  "polygon",
  "ref",
  "repeat",
  "state-update",
  "v",
)

#let parse-basic-where-selector(selector) = {
  // Typst does not expose a selector's target and fields directly. Limit this
  // representation-based fallback to the simple form we can interpret safely.
  let matched = repr(selector).match(regex("^([\\w]+)\\.where(.*)$"))
  if matched == none {
    panic("Only `element.where(key: value, ..)` selectors are supported.")
  }
  let (element-fn, fields) = matched.captures
  (element-fn: element-fn, fields: eval(fields))
}

#let interpret-exclude-patterns(exclude) = {
  exclude.map(pattern => {
    // Element functions stay functions so `list.item` and `enum.item`, which
    // share the represented name "item", can be told apart.
    if type(pattern) in (str, label, dictionary, function) { pattern }
    else if type(pattern) == selector {
      parse-basic-where-selector(pattern)
    } else {
      panic(
        "Exclude patterns must be element functions, strings, "
          + "selectors, or labels; got:",
        pattern,
      )
    }
  })
}

/// Represented names of elements that start and end their own text segment.
/// Grapheme clusters never join across a segment boundary, so `a` in one table
/// cell and a combining accent in the next still count as two characters.
#let BLOCK_ELEMENTS = (
  "align",
  "block",
  "box",
  "caption",
  "cell",
  "columns",
  "enum",
  "figure",
  "footnote",
  "grid",
  "heading",
  "item",
  "list",
  "pad",
  "par",
  "place",
  "quote",
  "stack",
  "table",
  "terms",
)

/// Traverse content, apply `f` to text-like leaves, and return nested results.
///
/// When `boundary` is not `none`, it is inserted before and after the results
/// of every block-level element listed in `BLOCK_ELEMENTS`, and between a term
/// and its description.
///
/// This is a low-level helper. Most callers should use `char-count-of`.
#let map-tree(f, content, exclude: IGNORED_ELEMENTS, boundary: none) = {
  if content == none { return none }

  // Normalize patterns once instead of repeating the work for every node.
  let exclude = interpret-exclude-patterns(exclude)
  let exclude-selectors = exclude.filter(
    pattern => type(pattern) == dictionary and "element-fn" in pattern,
  )
  let exclude-functions = exclude.filter(pattern => type(pattern) == function)
  let exclude-names = exclude.filter(pattern => type(pattern) == str)
  let exclude-labels = exclude.filter(pattern => type(pattern) == label)

  let wrap(result) = {
    if result == none or boundary == none { result }
    else { (boundary, result, boundary) }
  }

  let map-subtree(content) = {
    if content == none { return none }

    let element-fn = content.func()
    let element-name = repr(element-fn)
    let fields = content.fields()

    // Selectors only carry the represented name, so `table.cell.where(..)`
    // also matches grid cells with the same fields.
    let excluded = (
      exclude-selectors.any(((element-fn: wanted-name, fields: wanted-fields)) => (
        element-name == wanted-name
          and wanted-fields.pairs().all(
            ((key, value)) => key in fields and fields.at(key) == value,
          )
      ))
        or exclude-functions.any(excluded => excluded == element-fn)
        or element-name in exclude-names
        or content.at("label", default: none) in exclude-labels
    )
    if excluded {
      // An excluded block still separates the text on either side of it.
      return if boundary != none and element-name in BLOCK_ELEMENTS { (boundary,) }
    }

    let result = if element-name in ("text", "raw") {
      f(content.text)
    } else if element-name == "space" {
      f(" ")
    } else if element-name == "linebreak" {
      f("\n")
    } else if element-name == "parbreak" {
      f("\n\n")
    } else if element-name == "pagebreak" {
      f("\n\n\n\n")
    } else if element-name == "smartquote" {
      f(if content.double { "\"" } else { "'" })
    } else if "children" in fields {
      content.children.map(map-subtree).filter(result => result != none)
    } else if element-name == "figure" {
      (
        if "figure-body" not in exclude-names { wrap(map-subtree(content.body)) },
        if "caption" in fields { map-subtree(content.caption) },
      ).filter(result => result != none)
    } else if element-name == "styled" {
      map-subtree(content.child)
    } else if "term" in fields and "description" in fields {
      (wrap(map-subtree(content.term)), wrap(map-subtree(content.description)))
        .filter(result => result != none)
    } else if "body" in fields {
      map-subtree(content.body)
    } else {
      none
    }

    if element-name in BLOCK_ELEMENTS { wrap(result) } else { result }
  }

  map-subtree(content)
}

/// Count grapheme clusters in a string or content value.
///
/// - `content`: A string or Typst content.
/// - `exclude`: Additional element functions, element-name strings, labels, or
///   simple `element.where(..)` selectors to omit with their descendants.
/// - `footnotes`: Whether footnote text counts. Default: `true`.
/// - `figures`: Whether figure bodies and captions count. Default: `false`.
///
/// Returns character counts with and without whitespace, and normal pages.
/// One normal page is 2,400 characters including spaces.
#let char-count-of(content, exclude: (), footnotes: true, figures: false) = {
  if type(content) == str {
    return string-char-count(content)
  }

  let defaults = if figures {
    IGNORED_ELEMENTS.filter(name => name != "figure")
  } else { IGNORED_ELEMENTS }
  let excluded-elements = (
    defaults + (exclude,).flatten() + if footnotes { () } else { (footnote,) }
  )

  // Join inline text before segmenting so styling cannot split a grapheme
  // cluster, but keep block-level elements in separate segments.
  let boundary = (char-count-boundary: true)
  let pieces = (map-tree(x => x, content, exclude: excluded-elements, boundary: boundary),)
    .filter(x => x != none)
    .flatten()
  let segments = pieces.fold(("",), (segments, piece) => {
    if piece == boundary {
      if segments.last() != "" { segments.push("") }
    } else {
      segments.at(-1) += piece
    }
    segments
  })
  let totals = segments
    .map(string-char-count)
    .fold(string-char-count(""), dictionary-sum)
  make-stats(totals.characters-with-spaces, totals.characters-without-spaces)
}

/// Return the final document-wide statistics dictionary.
///
/// Must be called inside `context`, in a document that uses `#show: char-count`.
/// Use it to calculate with or round the totals, for example
/// `#context calc.round(final-stats().normal-pages, digits: 2)`.
#let final-stats() = {
  let stats = state("charometer").final()
  assert(
    stats != none,
    message: (
      "Global character count is not enabled.\n"
      + "Hint: Please add `#show: char-count` before the document."
    ),
  )
  stats
}

/// Read one field from the final document-wide count.
///
/// Use `char-count` as a show rule before calling this function.
#let global-total(field) = context {
  let stats = final-stats()

  assert(
    field in stats,
    message: (
      "Total " + repr(field)
      + " not found in character count result.\n"
      + "Hint: the counter returned " + repr(stats) + "."
    ),
  )

  stats.at(field)
}

/// The final document-wide number of grapheme clusters, including spaces.
///
/// Requires `#show: char-count` before the document body.
#let total-characters-with-spaces = global-total(
  "characters-with-spaces",
)

/// The final document-wide number of grapheme clusters, excluding whitespace.
///
/// Requires `#show: char-count` before the document body.
#let total-characters-without-spaces = global-total(
  "characters-without-spaces",
)

/// The final document-wide number of Danish normal pages.
///
/// One normal page is 2,400 characters including spaces. Requires
/// `#show: char-count` before the document body.
#let total-normal-pages = global-total("normal-pages")

/// Format statistics the Danish way, e.g. `12 345 tegn · 5,14 normalsider`.
///
/// Normal pages are rounded half up to `digits` decimals for display only.
#let format-danish(stats, digits: 2) = {
  assert(
    type(digits) == int and digits >= 0,
    message: "`digits` must be a non-negative integer.",
  )

  let characters = str(stats.characters-with-spaces)
  let groups = ()
  while characters.len() > 3 {
    groups.insert(0, characters.slice(-3))
    characters = characters.slice(0, -3)
  }
  groups.insert(0, characters)

  // Round with integers from the character count, since floats like
  // 2412 / 2400 = 1.005 cannot be rounded reliably.
  let scale = calc.pow(10, digits)
  let scaled = stats.characters-with-spaces * scale
  let rounded = calc.quo(scaled, NORMAL_PAGE_CHARACTERS)
  if 2 * calc.rem(scaled, NORMAL_PAGE_CHARACTERS) >= NORMAL_PAGE_CHARACTERS {
    rounded += 1
  }
  let whole = calc.quo(rounded, scale)
  let fraction = str(calc.rem(rounded, scale))
  let pages-text = str(whole) + if digits > 0 {
    "," + "0" * (digits - fraction.len()) + fraction
  }

  groups.join(" ") + " tegn · " + pages-text + " normalsider"
}

/// The final document-wide count formatted with `format-danish`.
///
/// Requires `#show: char-count` before the document body.
#let total-summary = context format-danish(final-stats())

/// A show rule that renders content unchanged and adds its count to the global
/// total. Accepts the same named arguments as `char-count-of`.
#let char-count(content, exclude: (), footnotes: true, figures: false) = {
  let stats = char-count-of(
    content,
    exclude: exclude,
    footnotes: footnotes,
    figures: figures,
  )

  state("charometer").update(old-stats => {
    let totals = if old-stats == none { stats } else { dictionary-sum(old-stats, stats) }
    make-stats(totals.characters-with-spaces, totals.characters-without-spaces)
  })

  content
}
