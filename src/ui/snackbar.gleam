//// A snackbar that slides up from the bottom center of the screen and goes
//// away by itself. Used to show failures reported by the background.

import ffi/chrome
import ffi/dom.{type Element}
import notice

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
  dom.set_style(bar, "position", "fixed")
  dom.set_style(bar, "left", "50%")
  dom.set_style(bar, "bottom", "24px")
  dom.set_style(bar, "z-index", "10001")
  dom.set_style(bar, "max-width", "80vw")
  dom.set_style(bar, "padding", "12px 20px")
  dom.set_style(bar, "border-radius", "12px")
  dom.set_style(bar, "background", "#C12020")
  dom.set_style(bar, "color", "#FFFFFF")
  dom.set_style(bar, "font", "14px sans-serif")
  dom.set_style(bar, "box-shadow", "0 4px 12px rgba(0, 0, 0, 0.3)")
  dom.set_style(bar, "pointer-events", "none")
  dom.set_style(
    bar,
    "transition",
    "transform 300ms ease-out, opacity 300ms ease-out",
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
