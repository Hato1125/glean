//// # X (Twitter)
////
//// ## How the original image is found
////
//// Image URLs on the page point at a resized version, with the size given by `name`:
////
////   https://pbs.twimg.com/media/ABC123?format=jpg&name=small
////
//// Setting `name=orig` gives the original. No API call is needed:
////
////   https://pbs.twimg.com/media/ABC123?format=jpg&name=orig
////
//// ## Supported URL forms
////
//// | Form                                                | ID     | Ext |
//// | --------------------------------------------------- | ------ | --- |
//// | pbs.twimg.com/media/ABC123?format=png&name=small    | ABC123 | png |
//// | pbs.twimg.com/media/ABC123.jpg:large   (legacy)     | ABC123 | jpg |
//// | pbs.twimg.com/media/ABC123                          | ABC123 | jpg |
////
//// The extension is `format=` if present, else the one in the path, else jpg.
////
//// ## Saved filename
////
//// `ID.ext` (e.g. ABC123.png)

import ffi/chrome.{type Image, Image}
import gleam/list
import gleam/result
import gleam/string

/// Find the original image for an image URL.
pub fn original(src: String) -> Result(Image, Nil) {
  let #(path, query) = case string.split_once(src, "?") {
    Ok(#(path, query)) -> #(path, query)
    Error(Nil) -> #(src, "")
  }

  use name <- result.try(list.last(string.split(path, "/")))
  let #(id, ext) = case string.split_once(name, ".") {
    Ok(#(id, ext)) -> #(id, Ok(before_colon(ext)))
    Error(Nil) -> #(before_colon(name), Error(Nil))
  }

  let format =
    query_value(query, "format")
    |> result.or(ext)
    |> result.unwrap("jpg")

  Ok(Image(
    url: "https://pbs.twimg.com/media/"
      <> id
      <> "?format="
      <> format
      <> "&name=orig",
    filename: id <> "." <> format,
  ))
}

fn before_colon(s: String) -> String {
  case string.split_once(s, ":") {
    Ok(#(head, _)) -> head
    Error(Nil) -> s
  }
}

fn query_value(query: String, key: String) -> Result(String, Nil) {
  string.split(query, "&")
  |> list.find_map(fn(pair) {
    case string.split_once(pair, "=") {
      Ok(#(k, v)) if k == key -> Ok(v)
      _ -> Error(Nil)
    }
  })
}
