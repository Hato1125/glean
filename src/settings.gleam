//// User settings, saved in chrome.storage.sync. Edited in the popup
//// (ui/popup.gleam) and read by the background when saving images.

import ffi/chrome
import gleam/result
import gleam/string

pub type Site {
  X
  Pixiv
}

pub type Settings {
  Settings(x_folder: String, pixiv_folder: String)
}

pub const default = Settings(x_folder: "glean/x", pixiv_folder: "glean/pixiv")

const x_key = "x_folder"

const pixiv_key = "pixiv_folder"

pub fn load(callback: fn(Settings) -> Nil) -> Nil {
  use x <- chrome.storage_get(x_key)
  use pixiv <- chrome.storage_get(pixiv_key)
  callback(Settings(
    x_folder: result.unwrap(x, default.x_folder),
    pixiv_folder: result.unwrap(pixiv, default.pixiv_folder),
  ))
}

pub fn save(settings: Settings) -> Nil {
  chrome.storage_set(x_key, settings.x_folder)
  chrome.storage_set(pixiv_key, settings.pixiv_folder)
}

pub fn folder(settings: Settings, site: Site) -> String {
  case site {
    X -> settings.x_folder
    Pixiv -> settings.pixiv_folder
  }
}

pub fn set_folder(settings: Settings, site: Site, folder: String) -> Settings {
  case site {
    X -> Settings(..settings, x_folder: folder)
    Pixiv -> Settings(..settings, pixiv_folder: folder)
  }
}

/// Clean up a folder typed by the user: trim whitespace and slashes, so that
/// " glean/pixiv/ " becomes "glean/pixiv" and "/" becomes "".
pub fn normalize_folder(folder: String) -> String {
  folder
  |> string.replace("\\", "/")
  |> string.trim
  |> trim_slashes
}

fn trim_slashes(s: String) -> String {
  case string.starts_with(s, "/"), string.ends_with(s, "/") {
    True, _ -> trim_slashes(string.drop_start(s, 1))
    _, True -> trim_slashes(string.drop_end(s, 1))
    False, False -> string.trim(s)
  }
}

/// The path to pass to the downloads API: `folder/filename`, or just
/// `filename` when no folder is set for the site.
pub fn path(settings: Settings, site: Site, filename: String) -> String {
  case folder(settings, site) {
    "" -> filename
    folder -> folder <> "/" <> filename
  }
}
