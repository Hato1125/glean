//// # pixiv
////
//// ## How the original images are found
////
//// The artwork page URL contains the artwork ID (extracted in ui/pixiv.gleam):
////
////   https://www.pixiv.net/artworks/123456
////                                  ^^^^^^ artwork ID
////
//// Images on the page are resized, and the original's extension (jpg or png)
//// cannot be told from their URLs. So we ask the API that returns the original
//// URL of every page of the artwork:
////
////   GET https://www.pixiv.net/ajax/illust/123456/pages
////
////   { "body": [ { "urls": { "original": "https://i.pximg.net/img-original/.../123456_p0.png" } },
////               { "urls": { "original": "https://i.pximg.net/img-original/.../123456_p1.jpg" } } ] }
////
//// `urls.original` of each element of `body` is the original URL, in page order.
//// All of them are saved.
////
//// ## Note
////
//// i.pximg.net returns 403 without a Referer.
//// The declarativeNetRequest rule in extension/rules.json adds one.
////
//// ## Saved filename
////
//// The last path segment of the original URL (e.g. 123456_p0.png)

import ffi/chrome.{type Image, Image}
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/result
import gleam/string

pub fn api_url(id: String) -> String {
  "https://www.pixiv.net/ajax/illust/" <> id <> "/pages"
}

pub fn originals(body: String) -> Result(List(Image), Nil) {
  let decoder =
    decode.at(
      ["body"],
      decode.list(decode.at(["urls", "original"], decode.string)),
    )
  use urls <- result.try(json.parse(body, decoder) |> result.replace_error(Nil))
  list.try_map(urls, fn(url) {
    use filename <- result.try(list.last(string.split(url, "/")))
    Ok(Image(url:, filename:))
  })
}
