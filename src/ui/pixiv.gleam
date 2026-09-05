//// pixiv: on an artwork page (/artworks/ID), puts a "Download" button at the
//// bottom right of the screen. Clicking it downloads every page of the artwork.
//// The button is removed on other pages.

import ffi/dom
import gleam/int
import gleam/result
import gleam/string
import request
import ui/component/button
import ui/component/snackbar

pub fn main() -> Nil {
  snackbar.listen()
  use <- dom.observe
  let existing = dom.query(dom.body(), "." <> button.class)
  case artwork_id(dom.pathname()), existing {
    Ok(_), Ok(_) | Error(Nil), Error(Nil) -> Nil
    Error(Nil), Ok(b) -> dom.remove(b)
    Ok(_), Error(Nil) -> dom.append(dom.body(), create())
  }
}

fn create() -> dom.Element {
  let b =
    button.create("Download", fn() {
      request.PixivArtwork(id: result.unwrap(artwork_id(dom.pathname()), ""))
    })
  dom.set_css(
    b,
    "
    position: fixed; right: 24px; bottom: 24px; z-index: 10000;
    padding: 10px 20px; font-size: 14px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
    ",
  )
  b
}

pub fn artwork_id(pathname: String) -> Result(String, Nil) {
  case string.split(pathname, "/") {
    ["", "artworks", id, ..] | ["", "en", "artworks", id, ..] ->
      int.parse(id) |> result.replace(id)
    _ -> Error(Nil)
  }
}
