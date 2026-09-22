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

/// Count grapheme clusters and Danish normal pages in a string.
///
/// Returns character and normal-page counts. One normal page is 2,400
/// characters including spaces.
#let string-char-count(string) = {
  let characters = string.clusters().len()
  (
    characters-with-spaces: characters,
    normal-pages: characters / NORMAL_PAGE_CHARACTERS,
  )
}

/// Element names ignored by `char-count-of` and `char-count` by default.
#let IGNORED_ELEMENTS = (
  "bibliography",
  "outline",
  "cite",
  "display",
  "equation",
  "h",
  "hide",
  "image",
  "line",
  "locate",
  "figure",
  "metadata",
  "path",
  "polygon",
  "ref",
  "repeat",
  "style",
  "update",
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
    if type(pattern) in (str, label, dictionary) { pattern }
    else if type(pattern) == function { repr(pattern) }
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

/// Traverse content, apply `f` to text-like leaves, and return nested results.
///
/// This is a low-level helper. Most callers should use `char-count-of`.
#let map-tree(f, content, exclude: IGNORED_ELEMENTS) = {
  if content == none { return none }

  // Normalize patterns once instead of repeating the work for every node.
  let exclude = interpret-exclude-patterns(exclude)
  let exclude-selectors = exclude.filter(
    pattern => type(pattern) == dictionary and "element-fn" in pattern,
  )

  let map-subtree(content) = {
    if content == none { return none }

    let element-name = repr(content.func())
    let fields = content.fields()

    for (element-fn, fields: wanted-fields) in exclude-selectors {
      if element-name == element-fn {
        let fields-match = wanted-fields.pairs().all(
          ((key, value)) => key in fields and fields.at(key) == value,
        )
        if fields-match { return none }
      }
    }

    if element-name in exclude {
      none
    } else if content.at("label", default: none) in exclude {
      none
    } else if element-name in ("text", "raw") {
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
        if "figure-body" not in exclude { map-subtree(content.body) },
        if "caption" in fields and "caption" not in exclude {
          map-subtree(content.caption)
        },
      ).filter(result => result != none)
    } else if element-name == "styled" {
      map-subtree(content.child)
    } else if "term" in fields and "description" in fields {
      (map-subtree(content.term), map-subtree(content.description))
        .filter(result => result != none)
    } else if "body" in fields {
      map-subtree(content.body)
    } else {
      none
    }
  }

  map-subtree(content)
}

/// Count grapheme clusters in a string or content value.
///
/// - `content`: A string or Typst content.
/// - `exclude`: Additional element functions, element-name strings, labels, or
///   simple `element.where(..)` selectors to omit with their descendants.
///
/// Returns character and normal-page counts. One normal page is 2,400
/// characters including spaces.
#let char-count-of(content, exclude: ()) = {
  if type(content) == str {
    return string-char-count(content)
  }

  let excluded-elements = IGNORED_ELEMENTS + (exclude,).flatten()

  // Join text before segmenting so styling cannot split a grapheme cluster.
  let text = (map-tree(x => x, content, exclude: excluded-elements),)
    .filter(x => x != none)
    .flatten()
    .fold("", (text, fragment) => text + fragment)
  string-char-count(text)
}

/// Read one field from the final document-wide count.
///
/// Use `char-count` as a show rule before calling this function.
#let global-total(field) = context {
  let stats = state("charometer").final()

  assert(
    stats != none,
    message: (
      "Global character count for " + field + " is not enabled.\n"
      + "Hint: Please add `#show: char-count` before the document."
    ),
  )

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

/// The final document-wide number of Danish normal pages.
///
/// One normal page is 2,400 characters including spaces. Requires
/// `#show: char-count` before the document body.
#let total-normal-pages = global-total("normal-pages")

/// A show rule that renders content unchanged and adds its count to the global
/// total. Pass `exclude` to omit additional elements and their descendants.
#let char-count(content, exclude: ()) = {
  let stats = char-count-of(content, exclude: exclude)

  state("charometer").update(old-stats => {
    let previous = if old-stats == none { 0 } else { old-stats.at("characters-with-spaces") }
    let characters = stats.at("characters-with-spaces") + previous
    (
      characters-with-spaces: characters,
      normal-pages: characters / NORMAL_PAGE_CHARACTERS,
    )
  })

  content
}
