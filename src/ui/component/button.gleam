import ffi/chrome
import ffi/dom.{type Element}
import request.{type Request}

pub const class = "glean-button"

pub fn create(label: String, request: fn() -> Request) -> Element {
  let button = dom.create_element("button")
  dom.set_class(button, class)
  dom.set_text(button, label)
  dom.set_style(button, "padding", "4px 12px")
  dom.set_style(button, "border", "none")
  dom.set_style(button, "border-radius", "50rem")
  dom.set_style(button, "background", "#007AFF")
  dom.set_style(button, "color", "#FFFFFF")
  dom.set_style(button, "font", "bold 13px sans-serif")
  dom.set_style(button, "cursor", "pointer")
  dom.on_click(button, fn() { chrome.send_message(request.to_json(request())) })
  button
}
