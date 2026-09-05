import ffi/chrome.{Image}
import gleeunit
import request
import site/pixiv
import site/x
import ui/pixiv as ui_pixiv

pub fn main() -> Nil {
  gleeunit.main()
}

// --- X ---

pub fn x_query_form_test() {
  assert x.original("https://pbs.twimg.com/media/ABC123?format=png&name=small")
    == Ok(Image(
      url: "https://pbs.twimg.com/media/ABC123?format=png&name=orig",
      filename: "ABC123.png",
    ))
}

pub fn x_legacy_form_test() {
  assert x.original("https://pbs.twimg.com/media/ABC123.jpg:large")
    == Ok(Image(
      url: "https://pbs.twimg.com/media/ABC123?format=jpg&name=orig",
      filename: "ABC123.jpg",
    ))
}

pub fn x_no_format_test() {
  assert x.original("https://pbs.twimg.com/media/ABC123")
    == Ok(Image(
      url: "https://pbs.twimg.com/media/ABC123?format=jpg&name=orig",
      filename: "ABC123.jpg",
    ))
}

// --- pixiv ---

const api_body = "
{
  \"error\": false,
  \"body\": [
    { \"urls\": { \"original\": \"https://i.pximg.net/img-original/img/2024/01/02/03/04/05/123456_p0.png\" } },
    { \"urls\": { \"original\": \"https://i.pximg.net/img-original/img/2024/01/02/03/04/05/123456_p1.jpg\" } }
  ]
}"

pub fn pixiv_originals_test() {
  assert pixiv.originals(api_body)
    == Ok([
      Image(
        url: "https://i.pximg.net/img-original/img/2024/01/02/03/04/05/123456_p0.png",
        filename: "123456_p0.png",
      ),
      Image(
        url: "https://i.pximg.net/img-original/img/2024/01/02/03/04/05/123456_p1.jpg",
        filename: "123456_p1.jpg",
      ),
    ])
}

// --- request ---

pub fn request_x_test() {
  assert request.parse("{\"site\":\"x\",\"srcs\":[\"a\",\"b\"]}")
    == Ok(request.XImages(srcs: ["a", "b"]))
}

pub fn request_pixiv_test() {
  assert request.parse("{\"site\":\"pixiv\",\"id\":\"123456\"}")
    == Ok(request.PixivArtwork(id: "123456"))
}

pub fn request_unknown_test() {
  assert request.parse("{\"site\":\"other\"}") == Error(Nil)
  assert request.parse("not json") == Error(Nil)
}

pub fn request_roundtrip_test() {
  let x = request.XImages(srcs: ["a", "b"])
  let pixiv = request.PixivArtwork(id: "123456")
  assert request.parse(request.to_json(x)) == Ok(x)
  assert request.parse(request.to_json(pixiv)) == Ok(pixiv)
}

// --- ui/pixiv ---

pub fn pixiv_artwork_id_test() {
  assert ui_pixiv.artwork_id("/artworks/123456") == Ok("123456")
  assert ui_pixiv.artwork_id("/en/artworks/123456") == Ok("123456")
  assert ui_pixiv.artwork_id("/artworks/123456/") == Ok("123456")
  assert ui_pixiv.artwork_id("/artworks/abc") == Error(Nil)
  assert ui_pixiv.artwork_id("/users/123456") == Error(Nil)
  assert ui_pixiv.artwork_id("/") == Error(Nil)
}
