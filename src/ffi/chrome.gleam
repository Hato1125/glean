//// Gleam-side declarations of the Chrome extension API. Implemented in chrome.js.

/// An image to download: its URL and the filename to save as.
pub type Image {
  Image(url: String, filename: String)
}

/// A browser tab. Only used to reply to the tab that sent a message.
pub type Tab

/// Content script: send a JSON string to the background.
@external(javascript, "./chrome.js", "send_message")
pub fn send_message(json: String) -> Nil

/// Background: call `on_message` with each message from a content script,
/// as a JSON string, along with the tab it came from.
@external(javascript, "./chrome.js", "on_message")
pub fn on_message(on_message: fn(String, Tab) -> Nil) -> Nil

/// Background: send a JSON string to the content script of `tab`.
@external(javascript, "./chrome.js", "send_to_tab")
pub fn send_to_tab(tab: Tab, json: String) -> Nil

/// Content script: call `on_message` with each message from the background,
/// as a JSON string.
@external(javascript, "./chrome.js", "on_background_message")
pub fn on_background_message(on_message: fn(String) -> Nil) -> Nil

/// Save an image to the downloads folder. `callback` gets Error(Nil) if the
/// download could not start or was interrupted (e.g. a 403 from the server).
@external(javascript, "./chrome.js", "download")
pub fn download(image: Image, callback: fn(Result(Nil, Nil)) -> Nil) -> Nil

/// Read a string saved with `storage_set`. Error(Nil) if it was never saved.
/// Works in the background and in the popup.
@external(javascript, "./chrome.js", "storage_get")
pub fn storage_get(key: String, callback: fn(Result(String, Nil)) -> Nil) -> Nil

/// Save a string under `key`. Synced across the user's browsers.
@external(javascript, "./chrome.js", "storage_set")
pub fn storage_set(key: String, value: String) -> Nil

/// Fetch an image URL and pass it to `callback` as a data URL. Error(Nil) on
/// failure or if the response is not an image. Unlike `download`, this request
/// goes through the declarativeNetRequest rules, so it can add a Referer.
@external(javascript, "./chrome.js", "fetch_data_url")
pub fn fetch_data_url(
  url: String,
  callback: fn(Result(String, Nil)) -> Nil,
) -> Nil

/// Fetch a URL and pass the body text to `callback`. Error(Nil) on failure.
@external(javascript, "./chrome.js", "fetch_text")
pub fn fetch_text(url: String, callback: fn(Result(String, Nil)) -> Nil) -> Nil
