//// Gleam-side declarations of the Chrome extension API. Implemented in chrome.js.

/// An image to download: its URL and the filename to save as.
pub type Image {
  Image(url: String, filename: String)
}

/// Send a JSON string from a content script to the background.
@external(javascript, "./chrome.js", "send_message")
pub fn send_message(json: String) -> Nil

/// Call `on_message` with each message from a content script, as a JSON string.
@external(javascript, "./chrome.js", "on_message")
pub fn on_message(on_message: fn(String) -> Nil) -> Nil

/// Save an image to the downloads folder.
@external(javascript, "./chrome.js", "download")
pub fn download(image: Image) -> Nil

/// Fetch a URL and pass the body text to `callback`. Error(Nil) on failure.
@external(javascript, "./chrome.js", "fetch_text")
pub fn fetch_text(url: String, callback: fn(Result(String, Nil)) -> Nil) -> Nil
