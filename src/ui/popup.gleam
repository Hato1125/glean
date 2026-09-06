//// The popup opened from the extension's toolbar icon. Edits the settings.
//// extension/popup.html is only a shell that loads this; everything on the
//// page is built here.

import ffi/dom.{type Element}
import settings.{type Settings, type Site, Pixiv, X}

pub fn main() -> Nil {
  let body = dom.body()
  dom.set_css(
    body,
    "
    width: 260px;
    margin: 0;
    padding: 16px;
    font: 13px sans-serif;
    color: #1C1C1E;
    ",
  )
  use current <- settings.load

  field(body, X, "X folder", "glean/x", current)
  field(body, Pixiv, "pixiv folder", "glean/pixiv", current)
}

fn field(
  parent: Element,
  site: Site,
  label_text: String,
  placeholder: String,
  current: Settings,
) -> Nil {
  let label = dom.create_element("label")
  dom.set_text(label, label_text)
  dom.set_css(label, "display: block; margin-bottom: 14px; font-weight: bold;")
  let input = dom.create_element("input")
  dom.set_attribute(input, "type", "text")
  dom.set_attribute(input, "placeholder", placeholder)
  dom.set_attribute(input, "spellcheck", "false")
  dom.set_css(
    input,
    "
    display: block;
    box-sizing: border-box;
    width: 100%;
    margin-top: 6px;
    padding: 6px 8px;
    border: 1px solid #C7C7CC;
    border-radius: 6px;
    font: inherit;
    font-weight: normal;
    ",
  )
  dom.set_value(input, settings.folder(current, site))
  dom.append(label, input)
  dom.append(parent, label)

  use typed <- dom.on_change(input)
  let folder = settings.normalize_folder(typed)
  dom.set_value(input, folder)

  use latest <- settings.load
  settings.save(settings.set_folder(latest, site, folder))
}
