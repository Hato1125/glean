import ffi/chrome
import gleam/io
import gleam/list
import gleam/result
import request
import site/pixiv
import site/x

pub fn main() -> Nil {
  chrome.on_message(on_message)
}

fn on_message(text: String) -> Nil {
  case request.parse(text) {
    Ok(request.XImages(srcs)) -> list.each(srcs, download_x)
    Ok(request.PixivArtwork(id)) -> download_pixiv(id)
    Error(Nil) -> io.println("glean: 不明な要求: " <> text)
  }
}

fn download_x(src: String) -> Nil {
  case x.original(src) {
    Ok(image) -> chrome.download(image)
    Error(Nil) -> io.println("glean: ダウンロードできませんでした: " <> src)
  }
}

fn download_pixiv(id: String) -> Nil {
  use body <- chrome.fetch_text(pixiv.api_url(id))
  case result.try(body, pixiv.originals) {
    Ok(images) -> list.each(images, chrome.download)
    Error(Nil) -> io.println("glean: ダウンロードできませんでした: pixiv " <> id)
  }
}
