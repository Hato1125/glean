//// A snackbar that slides up from the bottom center of the screen and goes
//// away by itself. Used to show failures reported by the background.

import ffi/chrome
import ffi/dom.{type Element}
import messages/notice

const class = "glean-snackbar"

const visible_ms = 4000

const transition_ms = 300

pub fn listen() -> Nil {
  use text <- chrome.on_background_message
  case notice.parse(text) {
    Ok(notice.Failed(message)) -> show(message)
    Error(Nil) -> Nil
  }
}

pub fn show(message: String) -> Nil {
  case dom.query(dom.body(), "." <> class) {
    Ok(old) -> dom.remove(old)
    Error(Nil) -> Nil
  }
  let bar = create(message)
  dom.append(dom.body(), bar)

  use <- dom.next_frame
  slide(bar, in: True)
  use <- dom.set_timeout(visible_ms)
  slide(bar, in: False)
  use <- dom.set_timeout(transition_ms)
  dom.remove(bar)
}

fn create(message: String) -> Element {
  let bar = dom.create_element("div")
  dom.set_class(bar, class)
  dom.set_text(bar, message)
  dom.set_css(
    bar,
    "
    position: fixed;
    left: 50%;
    bottom: 24px;
    z-index: 10001;
    max-width: 80vw;
    padding: 12px 20px;
    border-radius: 12px;
    background: #C12020;
    color: #FFFFFF;
    font: 14px sans-serif;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
    pointer-events: none;
    transition: transform 300ms ease-out, opacity 300ms ease-out;
    ",
  )
  slide(bar, in: False)
  bar
}

fn slide(bar: Element, in shown: Bool) -> Nil {
  case shown {
    True -> {
      dom.set_style(bar, "transform", "translate(-50%, 0)")
      dom.set_style(bar, "opacity", "1")
    }
    False -> {
      dom.set_style(bar, "transform", "translate(-50%, 150%)")
      dom.set_style(bar, "opacity", "0")
    }
  }
}
