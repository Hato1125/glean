//// Gleam-side declarations of the DOM. Implemented in dom.js. Used by content scripts.

pub type Element

@external(javascript, "./dom.js", "body")
pub fn body() -> Element

/// Every element under `root` that matches `selector`.
@external(javascript, "./dom.js", "query_all")
pub fn query_all(root: Element, selector: String) -> List(Element)

/// The first element under `root` that matches `selector`.
@external(javascript, "./dom.js", "query")
pub fn query(root: Element, selector: String) -> Result(Element, Nil)

/// The closest of `element` itself or its ancestors that matches `selector`.
@external(javascript, "./dom.js", "closest")
pub fn closest(element: Element, selector: String) -> Result(Element, Nil)

/// Whether `child` is inside `parent`.
@external(javascript, "./dom.js", "contains")
pub fn contains(parent: Element, child: Element) -> Bool

@external(javascript, "./dom.js", "get_attribute")
pub fn get_attribute(element: Element, name: String) -> Result(String, Nil)

@external(javascript, "./dom.js", "create_element")
pub fn create_element(tag: String) -> Element

@external(javascript, "./dom.js", "set_class")
pub fn set_class(element: Element, class: String) -> Nil

@external(javascript, "./dom.js", "set_text")
pub fn set_text(element: Element, text: String) -> Nil

/// Set one CSS property. `name` is the CSS name, such as "margin-left".
@external(javascript, "./dom.js", "set_style")
pub fn set_style(element: Element, name: String, value: String) -> Nil

/// Append a block of inline CSS (`name: value;` pairs) to the element's style.
/// Properties already set are overridden if they appear again.
@external(javascript, "./dom.js", "set_css")
pub fn set_css(element: Element, css: String) -> Nil

/// Call `handler` on click. The event does not propagate, so the page's own
/// click handling is not triggered.
@external(javascript, "./dom.js", "on_click")
pub fn on_click(element: Element, handler: fn() -> Nil) -> Nil

/// Call `handler` with True when a pointer goes down on the element, and with
/// False when it is released, leaves the element, or is cancelled.
@external(javascript, "./dom.js", "on_press")
pub fn on_press(element: Element, handler: fn(Bool) -> Nil) -> Nil

@external(javascript, "./dom.js", "append")
pub fn append(parent: Element, child: Element) -> Nil

@external(javascript, "./dom.js", "remove")
pub fn remove(element: Element) -> Nil

/// The path part of the current URL (e.g. "/artworks/123456").
@external(javascript, "./dom.js", "pathname")
pub fn pathname() -> String

/// Call `callback` after `ms` milliseconds.
@external(javascript, "./dom.js", "set_timeout")
pub fn set_timeout(ms: Int, callback: fn() -> Nil) -> Nil

/// Call `callback` once the browser has painted the current DOM. Style changes
/// made in `callback` are animated by CSS transitions instead of applied at once.
@external(javascript, "./dom.js", "next_frame")
pub fn next_frame(callback: fn() -> Nil) -> Nil

/// Call `update` once now and again whenever the page changes.
/// SPAs change constantly, so bursts of changes are merged into one frame.
@external(javascript, "./dom.js", "observe")
pub fn observe(update: fn() -> Nil) -> Nil
