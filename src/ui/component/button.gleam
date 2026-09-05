import ffi/chrome
import ffi/dom.{type Element}
import request.{type Request}

pub const class = "glean-button"

pub fn create(label: String, request: fn() -> Request) -> Element {
  let button = dom.create_element("button")
  dom.set_class(button, class)
  dom.set_text(button, label)
  dom.set_css(
    button,
    "
    padding: 4px 12px;
    border: none;
    border-radius: 50rem;
    background: #007AFF;
    color: #FFFFFF;
    font: bold 13px sans-serif;
    cursor: pointer;
    ",
  )
  dom.on_click(button, fn() { chrome.send_message(request.to_json(request())) })
  button
}
