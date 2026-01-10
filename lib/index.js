import "@vanillawc/wc-codemirror";
import guida from "guida";
import { createFs } from "indexeddb-fs";
import { Elm } from "../tmp/elm.js";

const fs = createFs({ databaseName: "guida-fs" });

const config = {
    XMLHttpRequest: globalThis.XMLHttpRequest,
    writeFile: fs.writeFile,
    readFile: fs.readFile,
    details: fs.details,
    createDirectory: fs.createDirectory,
    readDirectory: fs.readDirectory,
    getCurrentDirectory: async () => "root",
    homedir: async () => "root"
};

(async () => {
    await fs.createDirectory("root/src");

    const theme = localStorage.getItem("theme");
    const app = Elm.Main.init({ flags: { theme, year: new Date().getFullYear() } });

    if (theme === "dark") {
        document.documentElement.classList.add("dark");
    } else {
        document.documentElement.classList.remove("dark");
    }

    app.ports.setTheme.subscribe((theme) => {
        localStorage.setItem("theme", theme);

        if (theme === "dark") {
            document.documentElement.classList.add("dark");
        } else {
            document.documentElement.classList.remove("dark");
        }
    });

    app.ports.setupProject.subscribe(async ({ direct, indirect, content }) => {
        const directDependencies = direct.map((d) => `"${d.author}/${d.project}": "${d.version}"`).join(", ");
        const indirectDependencies = indirect.map((d) => `"${d.author}/${d.project}": "${d.version}"`).join(", ");

        fs.writeFile("root/elm.json", `{
    "type": "application",
    "source-directories": [ "src" ],
    "elm-version": "0.19.1",
    "dependencies": {
        "direct": { ${directDependencies} },
        "indirect": { ${indirectDependencies} }
    },
    "test-dependencies": { "direct": {}, "indirect": {} }
}`);

        if (content) {
            await setEditorContentAndRebuild(content);
        }
    });

    const setEditorContentAndRebuild = async (content) => {
        if (content) {
            document.getElementById("editor").value = content;
        }

        const path = "root/src/Main.guida";
        await fs.writeFile(path, content || document.getElementById("editor").value);

        const result = await guida.make(config, path, {
            debug: false,
            optimize: false,
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

    app.ports.install.subscribe(async (info) => {
        await guida.install(config, info.packageString);
        const elmJsonContent = await fs.readFile("root/elm.json");
        const result = JSON.parse(elmJsonContent);
        app.ports.installResult.send({ ...info, result });
    });

    app.ports.uninstall.subscribe(async (info) => {
        await guida.uninstall(config, info.packageString);
        const elmJsonContent = await fs.readFile("root/elm.json");
        const result = JSON.parse(elmJsonContent);
        app.ports.uninstallResult.send({ ...info, result });
    });
})();