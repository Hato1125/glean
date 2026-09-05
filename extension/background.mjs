// Extension entry point. Only calls main from the compiled glean.mjs.
// build.sh bundles it with its dependencies into dist/background.js.
import { main } from "../build/dev/javascript/glean/glean.mjs";
main();
