import "@vanillawc/wc-codemirror";
import guida from "guida";
import { Elm } from "../tmp/elm.js";

(async () => {
    const guidaApp = await guida.init();

    const app = Elm.Main.init({ flags: new Date().getFullYear() });

    app.ports.rebuild.subscribe(async () => {
        const result = await guidaApp.make(document.getElementById("editor").value, {
            debug: true,
            optimize: false,
            sourcemaps: false
        });

        app.ports.rebuildResult.send(result);
    });
})();