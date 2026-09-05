//// A download request sent from a content script button to the background.
////
//// JSON shape:
////
////   { "site": "x", "srcs": ["https://pbs.twimg.com/media/ABC?format=jpg&name=small", ...] }
////   { "site": "pixiv", "id": "123456" }

import gleam/dynamic/decode
import gleam/json
import gleam/result

pub type Request {
  /// X: URLs of every photo in a tweet
  XImages(srcs: List(String))
  /// pixiv: artwork ID; every page of the artwork is downloaded
  PixivArtwork(id: String)
}

pub fn to_json(request: Request) -> String {
  case request {
    XImages(srcs) ->
      json.object([
        #("site", json.string("x")),
        #("srcs", json.array(srcs, json.string)),
      ])
    PixivArtwork(id) ->
      json.object([#("site", json.string("pixiv")), #("id", json.string(id))])
  }
  |> json.to_string
}

pub fn parse(text: String) -> Result(Request, Nil) {
  json.parse(text, decoder()) |> result.replace_error(Nil)
}

fn decoder() -> decode.Decoder(Request) {
  use site <- decode.field("site", decode.string)
  case site {
    "x" -> {
      use srcs <- decode.field("srcs", decode.list(decode.string))
      decode.success(XImages(srcs:))
    }
    "pixiv" -> {
      use id <- decode.field("id", decode.string)
      decode.success(PixivArtwork(id:))
    }
    _ -> decode.failure(XImages([]), "Request")
  }
}
