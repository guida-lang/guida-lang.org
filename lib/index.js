import "@vanillawc/wc-codemirror";
import guida from "guida";
import { Elm } from "../tmp/elm.js";

(async () => {
    const guidaApp = await guida.init({
        GUIDA_REGISTRY: "https://guida-package-registry.fly.dev"
    });

    const app = Elm.Main.init({ flags: new Date().getFullYear() });

    const setEditorContentAndRebuild = async (content) => {
        if (content) {
            document.getElementById("editor").value = content;
        }

        const result = await guidaApp.make(content || document.getElementById("editor").value, {
            debug: false,
            optimize: true,
            sourcemaps: false
        });

        if (result.error) {
            app.ports.rebuildResult.send({ error: JSON.parse(result.error) });
        } else {
            app.ports.rebuildResult.send(result);
        }
    };

    app.ports.setEditorContentAndRebuild.subscribe(setEditorContentAndRebuild);
    app.ports.rebuild.subscribe(async () => {
        await setEditorContentAndRebuild(null);
    });
})();