//// A notice sent from the background to the content script of the tab that
//// made a request.
////
//// JSON shape:
////
////   { "type": "failed", "message": "Download failed: ABC123.png" }

import gleam/dynamic/decode
import gleam/json
import gleam/result

pub type Notice {
  /// Something went wrong; `message` is shown to the user.
  Failed(message: String)
}

pub fn to_json(notice: Notice) -> String {
  case notice {
    Failed(message) ->
      json.object([
        #("type", json.string("failed")),
        #("message", json.string(message)),
      ])
  }
  |> json.to_string
}

pub fn parse(text: String) -> Result(Notice, Nil) {
  json.parse(text, decoder()) |> result.replace_error(Nil)
}

fn decoder() -> decode.Decoder(Notice) {
  use kind <- decode.field("type", decode.string)
  case kind {
    "failed" -> {
      use message <- decode.field("message", decode.string)
      decode.success(Failed(message:))
    }
    _ -> decode.failure(Failed(""), "Notice")
  }
}
