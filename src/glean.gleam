import ffi/chrome.{type Tab}
import gleam/io
import gleam/list
import gleam/result
import messages/notice
import messages/request
import site/pixiv
import site/x

pub fn main() -> Nil {
  chrome.on_message(on_message)
}

fn on_message(text: String, tab: Tab) -> Nil {
  case request.parse(text) {
    Ok(request.XImages(srcs)) -> list.each(srcs, download_x(_, tab))
    Ok(request.PixivArtwork(id)) -> download_pixiv(id, tab)
    Error(Nil) -> fail(tab, "Unknown request: " <> text)
  }
}

fn download_x(src: String, tab: Tab) -> Nil {
  case x.original(src) {
    Ok(image) -> download(image, tab)
    Error(Nil) -> fail(tab, "Could not resolve image: " <> src)
  }
}

fn download_pixiv(id: String, tab: Tab) -> Nil {
  use body <- chrome.fetch_text(pixiv.api_url(id))
  case result.try(body, pixiv.originals) {
    Ok(images) -> list.each(images, download_pixiv_image(_, tab))
    Error(Nil) -> fail(tab, "Could not fetch pixiv artwork " <> id)
  }
}

fn download_pixiv_image(image: chrome.Image, tab: Tab) -> Nil {
  use data_url <- chrome.fetch_data_url(image.url)
  case data_url {
    Ok(url) -> download(chrome.Image(url:, filename: image.filename), tab)
    Error(Nil) -> fail(tab, "Could not fetch image: " <> image.filename)
  }
}

fn download(image: chrome.Image, tab: Tab) -> Nil {
  use result <- chrome.download(image)
  case result {
    Ok(Nil) -> Nil
    Error(Nil) -> fail(tab, "Download failed: " <> image.filename)
  }
}

fn fail(tab: Tab, message: String) -> Nil {
  io.println("glean: " <> message)
  chrome.send_to_tab(tab, notice.to_json(notice.Failed(message)))
}
