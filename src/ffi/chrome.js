// Thin wrapper around the Chrome extension API for use from Gleam.
// See chrome.gleam for the Gleam-side declarations.
import { Ok, Error } from "../gleam.mjs";

export function send_message(json) {
  chrome.runtime.sendMessage(JSON.parse(json));
}

export function on_message(on_message) {
  chrome.runtime.onMessage.addListener((msg, sender) => {
    on_message(JSON.stringify(msg), sender.tab);
  });
}

export function send_to_tab(tab, json) {
  if (tab) chrome.tabs.sendMessage(tab.id, JSON.parse(json));
}

export function on_background_message(on_message) {
  chrome.runtime.onMessage.addListener((msg) => {
    on_message(JSON.stringify(msg));
  });
}

export function download(image, callback) {
  chrome.downloads.download(
    { url: image.url, filename: image.filename },
    (id) => {
      if (id === undefined) {
        console.error("glean: download failed", image.url, chrome.runtime.lastError);
        callback(new Error(undefined));
        return;
      }
      // The download runs in the background; wait for it to finish or fail.
      const listener = (delta) => {
        if (delta.id !== id || !delta.state) return;
        switch (delta.state.current) {
          case "complete":
            done(new Ok(undefined));
            break;
          case "interrupted":
            console.error("glean: download interrupted", image.url, delta.error?.current);
            done(new Error(undefined));
            break;
        }
      };
      const done = (result) => {
        chrome.downloads.onChanged.removeListener(listener);
        callback(result);
      };
      chrome.downloads.onChanged.addListener(listener);
    },
  );
}

export function storage_get(key, callback) {
  chrome.storage.sync.get(key, (items) => {
    const value = items[key];
    callback(typeof value === "string" ? new Ok(value) : new Error(undefined));
  });
}

export function storage_set(key, value) {
  chrome.storage.sync.set({ [key]: value });
}

export function fetch_data_url(url, callback) {
  fetch(url, { credentials: "include" })
    .then((res) => {
      if (!res.ok) return Promise.reject(res.status);
      const type = res.headers.get("content-type") ?? "";
      if (!type.startsWith("image/")) return Promise.reject("not an image: " + type);
      return res.blob();
    })
    .then(
      (blob) =>
        new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onload = () => resolve(reader.result);
          reader.onerror = () => reject(reader.error);
          reader.readAsDataURL(blob);
        }),
    )
    .then((data_url) => callback(new Ok(data_url)))
    .catch((err) => {
      console.error("glean: fetch failed", url, err);
      callback(new Error(undefined));
    });
}

export function fetch_text(url, callback) {
  fetch(url, { credentials: "include" })
    .then((res) => (res.ok ? res.text() : Promise.reject(res.status)))
    .then((text) => callback(new Ok(text)))
    .catch((err) => {
      console.error("glean: fetch failed", url, err);
      callback(new Error(undefined));
    });
}
