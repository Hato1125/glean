// Content script entry point for pixiv. Only calls main from the compiled ui/pixiv.mjs.
import { main } from "../../build/dev/javascript/glean/ui/pixiv.mjs";
main();
