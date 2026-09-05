//// X: puts a "DL" button at the right end of each tweet's action bar
//// (reply, repost, like, ...). Clicking it downloads every photo in the tweet.
//// Photos of a quoted tweet are not included.

import ffi/dom.{type Element}
import gleam/list
import request
import ui/button
import ui/snackbar

const tweet = "article[data-testid=\"tweet\"]"

const action_bar = "div[role=\"group\"]"

const photo = "img[src^=\"https://pbs.twimg.com/media/\"]"

const quoted = "div[role=\"link\"]"

pub fn main() -> Nil {
  snackbar.listen()
  use <- dom.observe
  dom.query_all(dom.body(), tweet)
  |> list.each(attach)
}

fn attach(article: Element) -> Nil {
  case dom.query(article, "." <> button.class) {
    Ok(_) -> Nil
    Error(Nil) -> add_button(article)
  }
}

fn add_button(article: Element) -> Nil {
  case photos(article), dom.query(article, action_bar) {
    [_, ..], Ok(bar) -> {
      let b =
        button.create("DL", fn() { request.XImages(srcs: photos(article)) })
      dom.set_style(b, "margin-left", "8px")
      dom.append(bar, b)
    }
    _, _ -> Nil
  }
}

fn photos(article: Element) -> List(String) {
  dom.query_all(article, photo)
  |> list.filter(fn(img) {
    case dom.closest(img, quoted) {
      Ok(link) -> !dom.contains(article, link)
      Error(Nil) -> True
    }
  })
  |> list.filter_map(dom.get_attribute(_, "src"))
}
