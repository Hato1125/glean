// Popup entry point. Only calls main from the compiled ui/popup.mjs.
// build.sh bundles it with its dependencies into dist/popup.js.
import { main } from "../build/dev/javascript/glean/ui/popup.mjs";
main();
