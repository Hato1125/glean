// Thin wrapper around the DOM. See dom.gleam for the Gleam-side declarations.
import { Ok, Error, List } from "../gleam.mjs";

const some = (value) => (value ? new Ok(value) : new Error(undefined));

export function body() {
  return document.body;
}

export function query_all(root, selector) {
  return List.fromArray([...root.querySelectorAll(selector)]);
}

export function query(root, selector) {
  return some(root.querySelector(selector));
}

export function closest(element, selector) {
  return some(element.closest(selector));
}

export function contains(parent, child) {
  return parent.contains(child);
}

export function get_attribute(element, name) {
  return some(element.getAttribute(name));
}

export function create_element(tag) {
  return document.createElement(tag);
}

export function set_class(element, cls) {
  element.className = cls;
}

export function set_text(element, text) {
  element.textContent = text;
}

export function set_style(element, name, value) {
  element.style.setProperty(name, value);
}

export function on_click(element, handler) {
  element.addEventListener("click", (e) => {
    e.preventDefault();
    e.stopPropagation();
    handler();
  });
}

export function append(parent, child) {
  parent.appendChild(child);
}

export function remove(element) {
  element.remove();
}

export function pathname() {
  return location.pathname;
}

export function set_timeout(ms, callback) {
  setTimeout(callback, ms);
}

export function next_frame(callback) {
  // Two frames: the first lets the browser lay out the new element, so that
  // style changes in the second start a transition from its initial state.
  requestAnimationFrame(() => requestAnimationFrame(callback));
}

export function observe(update) {
  let scheduled = false;
  const schedule = () => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => {
      scheduled = false;
      update();
    });
  };
  schedule();
  new MutationObserver(schedule).observe(document.body, {
    childList: true,
    subtree: true,
  });
}
