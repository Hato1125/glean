import ffi/chrome.{type Tab}
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
    Ok(request.XImages(srcs)) -> list.each(srcs, x_image(_, tab))
    Ok(request.PixivArtwork(id)) -> pixiv_artwork(id, tab)
    Error(Nil) -> fail(tab, "Unknown request: " <> text)
  }
}

fn x_image(src: String, tab: Tab) -> Nil {
  case x.original(src) {
    Ok(image) -> save(image, tab)
    Error(Nil) -> fail(tab, "Could not resolve image: " <> src)
  }
}

fn pixiv_artwork(id: String, tab: Tab) -> Nil {
  use body <- chrome.fetch_text(pixiv.api_url(id))
  case result.try(body, pixiv.originals) {
    Ok(images) -> list.each(images, pixiv_image(_, tab))
    Error(Nil) -> fail(tab, "Could not fetch pixiv artwork " <> id)
  }
}

fn pixiv_image(image: chrome.Image, tab: Tab) -> Nil {
  use data_url <- chrome.fetch_data_url(image.url)
  case data_url {
    Ok(url) -> save(chrome.Image(url:, filename: image.filename), tab)
    Error(Nil) -> fail(tab, "Could not fetch image: " <> image.filename)
  }
}

fn save(image: chrome.Image, tab: Tab) -> Nil {
  use result <- chrome.download(image)
  case result {
    Ok(Nil) -> Nil
    Error(Nil) -> fail(tab, "Download failed: " <> image.filename)
  }
}

fn fail(tab: Tab, message: String) -> Nil {
  chrome.send_to_tab(tab, notice.to_json(notice.Failed(message)))
}
