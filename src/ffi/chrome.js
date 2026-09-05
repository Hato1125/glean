// Thin wrapper around the Chrome extension API for use from Gleam.
// See chrome.gleam for the Gleam-side declarations.
import { Ok, Error } from "../gleam.mjs";

export function send_message(json) {
  chrome.runtime.sendMessage(JSON.parse(json));
}

export function on_message(on_message) {
  chrome.runtime.onMessage.addListener((msg) => {
    on_message(JSON.stringify(msg));
  });
}

export function download(image) {
  chrome.downloads.download({ url: image.url, filename: image.filename });
}

export function fetch_text(url, callback) {
  fetch(url, { credentials: "include" })
    .then((res) => (res.ok ? res.text() : Promise.reject(res.status)))
    .then((text) => callback(new Ok(text)))
    .catch((err) => {
      console.error("glean: fetch に失敗", url, err);
      callback(new Error(undefined));
    });
}
