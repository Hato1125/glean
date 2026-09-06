#!/bin/sh

set -eu
cd "$(dirname "$0")"

gleam build

rm -rf dist
mkdir -p dist/content
cp extension/manifest.json extension/rules.json extension/popup.html dist/

bun build extension/background.mjs --outfile dist/background.js
bun build extension/popup.mjs --outfile dist/popup.js
bun build extension/content/x.mjs --outfile dist/content/x.js
bun build extension/content/pixiv.mjs --outfile dist/content/pixiv.js
