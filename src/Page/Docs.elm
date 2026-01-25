module Page.Docs exposing
    ( Model
    , init
    , view
    )

import Browser
import Components.CodeBlock as CodeBlock
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Icon
import Layout.Main as Layout
import Layout.Navigation exposing (Navigation)
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer exposing (Renderer, defaultHtmlRenderer)
import Parser
import Parser.Advanced
import Result.Extra as Result
import Route
import Session exposing (Session)
import Svg.Attributes as SvgAttr



-- MARKDOWN


markdownRender : String -> List (Html msg)
markdownRender =
    Markdown.Parser.parse
        >> Result.mapError deadEndsToString
        >> Result.andThen (\ast -> Markdown.Renderer.render htmlRenderer ast)
        >> Result.mapError (List.singleton << Html.text)
        >> Result.merge


deadEndsToString : List (Parser.Advanced.DeadEnd String Parser.Problem) -> String
deadEndsToString =
    List.map Markdown.Parser.deadEndToString >> String.join "\n"


htmlRenderer : Renderer (Html msg)
htmlRenderer =
    { defaultHtmlRenderer
        | heading =
            \{ level, rawText, children } ->
                let
                    tag : List (Html.Attribute msg) -> List (Html msg) -> Html msg
                    tag =
                        case level of
                            Markdown.Block.H1 ->
                                Html.h1

                            Markdown.Block.H2 ->
                                Html.h2

                            Markdown.Block.H3 ->
                                Html.h3

                            Markdown.Block.H4 ->
                                Html.h4

                            Markdown.Block.H5 ->
                                Html.h5

                            Markdown.Block.H6 ->
                                Html.h6
                in
                tag [ Attr.id (String.replace " " "-" (String.toLower rawText)) ]
                    children
        , codeBlock = \{ body } -> CodeBlock.view body
        , html =
            Markdown.Html.oneOf
                [ Markdown.Html.tag "properties"
                    (Html.ul
                        [ Aria.role "list"
                        , Attr.class "m-0 list-none divide-y divide-zinc-900/5 p-0 dark:divide-white/5"
                        ]
                    )
                , Markdown.Html.tag "property"
                    (\name maybeType children ->
                        let
                            typeDescriptionTerm : List (Html msg)
                            typeDescriptionTerm =
                                maybeType
                                    |> Maybe.map
                                        (\type_ ->
                                            [ Html.dt [ Attr.class "sr-only" ] [ Html.text "Type" ]
                                            , Html.dd [ Attr.class "font-mono text-xs text-zinc-400 dark:text-zinc-500" ] [ Html.text type_ ]
                                            ]
                                        )
                                    |> Maybe.withDefault []
                        in
                        Html.li [ Attr.class "m-0 px-0 py-4 first:pt-0 last:pb-0" ]
                            [ Html.dl [ Attr.class "m-0 flex flex-wrap items-center gap-x-3 gap-y-2" ]
                                (Html.dt [ Attr.class "sr-only" ] [ Html.text "Name" ]
                                    :: Html.dd [] [ Html.code [] [ Html.text name ] ]
                                    :: typeDescriptionTerm
                                    ++ [ Html.dt [ Attr.class "sr-only" ] [ Html.text "Description" ]
                                       , Html.dd [ Attr.class "w-full flex-none [&>:first-child]:mt-0 [&>:last-child]:mb-0" ]
                                            children
                                       ]
                                )
                            ]
                    )
                    |> Markdown.Html.withAttribute "name"
                    |> Markdown.Html.withOptionalAttribute "type"
                , Markdown.Html.tag "todo"
                    (\_ ->
                        Html.div [ Attr.class "my-6 flex gap-2.5 rounded-2xl border border-amber-500/20 bg-amber-50/50 p-4 text-sm/6 text-amber-900 dark:border-amber-500/30 dark:bg-amber-500/5 dark:text-amber-200 dark:[--tw-prose-links-hover:var(--color-amber-300)] dark:[--tw-prose-links:var(--color-white)]" ]
                            [ Icon.info [ SvgAttr.class "mt-1 h-4 w-4 flex-none fill-amber-500 stroke-white dark:fill-amber-200/20 dark:stroke-amber-200" ]
                            , Html.div [ Attr.class "[&>:first-child]:mt-0 [&>:last-child]:mb-0" ]
                                [ Html.text "🚧 Work in Progress" ]
                            ]
                    )
                , Markdown.Html.tag "info"
                    (\children ->
                        Html.div [ Attr.class "not-prose my-6 flex gap-2.5 rounded-2xl border border-amber-500/20 bg-amber-50/50 p-4 text-sm/6 text-amber-900 dark:border-amber-500/30 dark:bg-amber-500/5 dark:text-amber-200 dark:[--tw-prose-links-hover:var(--color-amber-300)] dark:[--tw-prose-links:var(--color-white)]" ]
                            [ Icon.info [ SvgAttr.class "mt-1 h-4 w-4 flex-none fill-amber-500 stroke-white dark:fill-amber-200/20 dark:stroke-amber-200" ]
                            , Html.div [ Attr.class "[&>:first-child]:mt-0 [&>:last-child]:mb-0" ] children
                            ]
                    )
                ]
    }



-- MODEL


type alias Model =
    { section : Route.DocumentationSection
    }


init : Route.DocumentationSection -> ( Model, Cmd msg )
init section =
    ( { section = section }, Cmd.none )



-- VIEW


view : Session -> (Session.Msg -> msg) -> Model -> Browser.Document msg
view session toSessionMsg model =
    { title = "Guida: Documentation"
    , body =
        Layout.view { sidebarNavigation = sidebarNavigation, currentRoute = model.section } session toSessionMsg <|
            case model.section of
                Route.Introduction ->
                    introductionView

                Route.WhatIsGuida ->
                    whatIsGuidaView

                Route.Installation ->
                    markdownRender """
# Installation

Guida is distributed as an **npm package**, making it easy to install globally as a CLI tool or locally as a library in your JavaScript or Node.js projects.

## Prerequisites

Before installing, make sure you have:

- **Node.js v22.8.0** or later  
- **npm** (comes bundled with Node)

You can verify your versions with:

```bash
node --version
npm --version
````

If you need Node.js, visit [nodejs.org](https://nodejs.org/) or use a version manager such as [nvm](https://github.com/nvm-sh/nvm).

## Installing Guida (CLI)

To install Guida globally on your system:

```bash
npm install -g guida
```

This will make the `guida` command available from your terminal.

Check that the installation worked:

```bash
guida --version
```

You should see the installed version printed to the console.

## Using Guida as a Library

Guida can also be used **programmatically** inside Node.js or browser-based projects.
Install it locally in your project:

```bash
npm install guida
```

Import it in your JavaScript or TypeScript code:

```js
// Node.js (CommonJS)
const guida = require('guida');

// or ES Modules
import guida from 'guida';
```

## Upgrading

To upgrade to the latest release:

```bash
npm update -g guida
```

For project-local installations:

```bash
npm update guida
```

## Local Development (Optional)

If you want to build or test Guida locally:

```bash
git clone https://github.com/guida-lang/compiler
cd compiler
nvm use
npm install
npm run build
npm link
```

This links your local build so that `guida` runs your development version.

## Troubleshooting

If `guida` isn't found after installation:

* Ensure your global npm bin path is in your system's `PATH` variable.
* Try reinstalling with elevated permissions if necessary.
* On Windows, restart your terminal after installation.

For more help, join the [Guida Discord server](https://discord.gg/Ur33engz).
"""

                Route.YourFirstProgram ->
                    markdownRender """
# Your First Program

Now that you have Guida installed, let's create your first program!

This short example walks you through setting up a simple project, compiling it, and running the output in your browser or terminal.

## Create a Project Folder

Start by creating a new directory for your project:

```bash
mkdir hello-guida
cd hello-guida
````

Initialize it as a Guida project:

```bash
guida init
```

This command creates a basic folder structure:

```
hello-guida/
├── guida.json
├── src/
│   └── Main.guida
├── tests/
│   └── Example.guida
```

## Write Your First Program

Open `src/Main.guida` and replace its contents with:

```guida
module Main exposing (main)

import Html exposing (text)

main =
    text "Hello, Guida!"
```

This simple program displays a piece of text in your browser.

## Compile and Run

To compile the program, run:

```bash
guida make src/Main.guida --output=index.html
```

This generates an `index.html` file in your project folder.
You can open it directly in your browser:

```bash
open index.html
```

You should see:

> **Hello, Guida!**

## Using Guida in Node.js or the Browser

You can also import Guida as a JavaScript module.
This is useful for programmatic compilation or embedding the compiler in web tools.

### Node.js Example

<todo />

### Browser Example

With the help of a dependency such as [indexeddb-fs](https://www.npmjs.com/package/indexeddb-fs),
to simulate a filesystem in the browser, you can use Guida to compile code directly
in web applications like so:

```js
const guida = require("guida");

const { createFs } = require("indexeddb-fs");
const fs = createFs({ databaseName: "guida-fs" });

const config = {
    XMLHttpRequest: globalThis.XMLHttpRequest,
    env: {},
    writeFile: fs.writeFile,
    readFile: fs.readFile,
    details: fs.details,
    createDirectory: fs.createDirectory,
    readDirectory: fs.readDirectory,
    getCurrentDirectory: async () => "root",
    homedir: async () => "root"
};

const defaultGuidaJson = `{
  "type": "application",
  "source-directories": [
    "src"
  ],
  "guida-version": "1.0.0",
  "dependencies": {
    "direct": {
      "guida-lang/stdlib": "1.0.1"
    },
    "indirect": {}
  },
  "test-dependencies": {
    "direct": {},
    "indirect": {}
  }
}`;

window.addEventListener("load", async () => {
  await fs.createDirectory("root/src");
  await fs.writeFile("root/guida.json", defaultGuidaJson);

  const code = document.getElementById("code");
  const preview = document.getElementById("preview");

  await fs.writeFile("root/src/Main.guida", code.value);

  const result = await guida.make(config, "root/src/Main.guida", {
    debug: true,
    optimize: false,
    sourcemaps: false
  });

  if (Object.prototype.hasOwnProperty.call(result, "error")) {
    console.error(result.error);
  } else {
    preview.srcdoc = result.output;
  }
});
```

With the following HTML structure:

```html
<!doctype html>
<html>

<head>
  <meta charset="UTF-8" />
  <title>Try Guida!</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <script src="/app.js"></script>
</head>

<body>
  <textarea id="code">
module Main exposing (..)

import Html exposing (text)

main = text "Hello Guida!"
</textarea>

  <iframe id="preview"></iframe>
</body>

</html>
```

You can find the full code on how to use Guida in a browser-based project on Guida's
complier repository here: <https://github.com/guida-lang/compiler/tree/master/try>.

This makes Guida useful not only as a CLI tool but also as a **programmable compiler**
that can power editors, online sandboxes, and development tools.
"""

                Route.ProjectSetup ->
                    markdownRender """
# Project Setup

Before building larger applications, let's take a closer look at how a **Guida project** is organized and configured.

Guida uses a structure that's fully compatible with Elm 0.19.1, so existing Elm projects can run without changes.

## Project Structure

A minimal Guida project looks like this:

```
my-app/
├── guida.json
├── src/
│   └── Main.guida
├── tests/
│   └── Example.guida
````

### `guida.json`

This file defines your project's metadata, dependencies, and type (application or package).
Here's an example:

```json
{
  "type": "application",
  "source-directories": ["src"],
  "guida-version": "1.0.0",
  "dependencies": {
    "direct": {
      "guida-lang/stdlib": "1.0.1"
    },
    "indirect": {}
  },
  "test-dependencies": {
    "direct": {},
    "indirect": {}
  }
}
````

## Source Files

By default, all source files are located in the `src/` folder.
Each file must start with a **module declaration**, such as:

```guida
module Main exposing (..)
```

Modules can import one another by name, for example:

```guida
import MyApp.Utils
```

## Building the Project

Use the `guida make` command to compile your project:

```bash
guida make src/Main.elm --output=dist/index.html
```

Guida will automatically resolve all module dependencies, compile your code, and write the output to the given file.

You can also compile to JavaScript directly:

```bash
guida make src/Main.elm --output=dist/app.js
```

This is useful when configuring the HTML and CSS yourself.

## Local Packages and Custom Registries

By default, Guida will use the [public Guida package registry](https://package.guida-lang.org) to resolve dependencies.

But Guida also supports **local registries**, allowing you to host your own package
server for internal development. To point Guida to a local or custom registry,
use the `GUIDA_REGISTRY` environment variable:

```bash
GUIDA_REGISTRY=http://localhost:3000 guida make src/Main.elm --output=dist/index.html
```

To run a local registry server, you can use the
[`guida-lang/package-registry`](https://github.com/guida-lang/package-registry) project.

## Project Commands Summary

| Command           | Description                                              |
| ----------------- | -------------------------------------------------------- |
| `guida repl`      | Start an interactive REPL (if available)                 |
| `guida init`      | Create a new project scaffold                            |
| `guida make`      | Compile source files to HTML or JS                       |
| `guida install`   | Install project dependencies                             |
| `guida uninstall` | Uninstall project dependencies                           |
| `guida bump`      | Figures out the next version number based on API changes |
| `guida diff`      | Detects API changes                                      |
| `guida publish`   | Publishes your package                                   |
| `guida format`    | Format source files                                      |
| `guida test`      | Run project tests                                        |
"""

                Route.MigrationFromElm ->
                    markdownRender """
# Migration from Elm

Guida is designed to be **fully backward compatible** with **Elm 0.19.1**.

If you already have an existing Elm project, the goal is that you can still compile
and run it using Guida without any changes.

Also, transitioning to Guida should be as simple as introducing a `guida.json`
file to your project root. For this you can run the [`guida init`](/docs/1.0.0/commands/init) command.

<info>
Only Guida projects can contain `.guida` files, and consequently, Guida syntax.
This helps making sure that Elm projects still compile with Elm tooling.
</info>

## Why Migration Matters

Elm has a strong foundation — Guida builds on that same foundation while expanding the ecosystem, tooling, and long-term maintainability.  

Guida's first priority is to give teams the confidence that **existing Elm projects continue to work exactly as before**, while opening the door to future improvements and a self-hosted compiler environment.

## Step-by-Step Migration

### 1. Install Guida

You can install Guida globally or locally in your existing Elm project:

```bash
npm install -g guida
````

Or as a local dev dependency:

```bash
npm install --save-dev guida
```

### 2. Try Compiling with Guida

From your Elm project directory, simply run:

```bash
guida make src/Main.elm
```

If everything is compatible, Guida will compile your project just like Elm.
You can compare the output to verify that behavior is consistent.

You can now move forward using Guida commands like `guida make`, `guida test`, and others.

### 3. Create a `guida.json` file

The next step is to create a `guida.json` file in your project root.
You can do this by running [`guida init`](/docs/1.0.0/commands/init) and adjusting the generated file to match your existing Elm setup.

<info>
One difference between Elm and Guida is it's base dependencies. While Elm relies on `elm/core` and `elm/browser`,
Guida uses a single [`guida-lang/stdlib`](https://package.guida-lang.org/packages/guida-lang/stdlib/latest/) package that combines the functionality contained on `elm` and `elm-explorations` packages.
</info>

This will allow you to create `.guida` files and use Guida-specific syntax in your project, while `.elm` files will continue to work as before.

You can optionally delete the existing `elm.json` file once you're confident everything works.

## Compatibility Notes

* **Elm 0.19.1 Compatibility:** Guida currently targets full behavioral compatibility with Elm 0.19.1, including its syntax, compiler rules, and even certain edge cases.
* **No Code Changes Required:** Your existing `elm.json`, imports, and module structure remain valid.
* **Dependencies:** Guida uses the same package ecosystem as Elm but can also connect to a **custom registry**, allowing private or local package development.

<info>
If you use a local registry such as [`guida-lang/package-registry`](https://github.com/guida-lang/package-registry), you can mirror all Elm packages locally and work offline.
</info>
"""

                Route.SyntaxOverview ->
                    markdownRender """
# Syntax Overview

Guida builds on Elm's syntax and semantics, but it is **not limited to Elm 0.19.1**.
In addition to supporting existing Elm syntax, Guida introduces **new language features and extensions**
designed to improve expressiveness, ergonomics, and long-term evolution.

If you already know Elm, Guida will feel familiar — but with carefully chosen enhancements.

This section provides a high-level overview of Guida's syntax, highlighting both
**core constructs** and **Guida-specific additions**.

---

## Files and Modules

Every Guida source file defines exactly one module:

```guida
module Main exposing (main)
````

* The file name must match the module name (`Main.guida`)
* The `exposing` clause controls public visibility

This follows the same rules as Elm.

---

## Values and Functions

Values and functions are defined using `=`:

```guida
answer =
    42
```

Functions list parameters before the `=`:

```guida
add x y =
    x + y
```

Functions are pure and evaluated eagerly.

---

## Function Application

Function application uses whitespace instead of parentheses:

```guida
add 2 3
```

Parentheses are only used for grouping:

```guida
add (2 + 3) 4
```

---

## Let Expressions

Local bindings are introduced with `let ... in`:

```guida
area radius =
    let
        pi =
            3.14159
    in
    pi * radius * radius
```

Bindings are immutable and scoped to the `in` expression.

---

## Conditionals

Conditionals are expressions and require both branches:

```guida
sign n =
    if n < 0 then
        -1
    else
        1
```

The condition must evaluate to a `Bool`.

---

## Pattern Matching

Pattern matching is commonly done with `case` expressions:

```guida
describe list =
    case list of
        [] ->
            "empty"

        x :: xs ->
            "non-empty"
```

### Wildcard Patterns (Guida Extension)

Guida allows **named wildcard patterns**, which bind nothing but improve readability:

```guida
case value of
    _unused ->
        defaultResult
```

This differs from `_`, which is anonymous.

<info>
Elm only allows the anonymous wildcard `_`.
Guida allows **named wildcards** (`_name`) for clarity, without introducing a binding.
</info>

---

## Custom Types

Custom (algebraic) types are defined using `type`:

```guida
type Status
    = Loading
    | Success String
    | Error String
```

Guida follows Elm's approach here.

---

## Records

Records are collections of named fields:

```guida
user =
    { name = "Alice"
    , age = 30
    }
```

### Record Access

```guida
user.name
```

### Record Updates

```guida
{ user | age = 31 }
```

Guida allows **updating records referenced by another record's field**:

```guida
model.user = { model.user | age = 31 }
```

<info>
Elm requires nested updates using intermediate bindings.
Guida allows **direct nested record updates**, reducing boilerplate.
</info>

Guida also allows modifying records via **qualified names**, improving clarity in deeply nested structures:

```guida
config = { Configuration.defaultConfig | timeout = 3000 }
```

<info>
Elm does not allow **record updates through qualified paths**.
Guida introduces this syntax to improve readability in larger codebases.
</info>

---

## Tuples

```guida
pair =
    ( "Alice", 30 )
```

Guida supports **tuples with more than three elements**:

```guida
coordinates =
    ( x, y, z, time )
```

<info>
Elm limits tuples to a maximum of 3 elements.
Guida allows **tuples of arbitrary length**.
</info>

---

## Numbers

### Numeric Separators (Guida Extension)

Guida allows underscores in numeric literals for readability:

```guida
million =
    1_000_000

piApprox =
    3.141_592
```

<info>
Elm does not support numeric separators.
Guida allows **`_` in numeric literals** for readability.
</info>

---

## Lists

```guida
numbers =
    [ 1, 2, 3 ]
```

Lists are homogeneous and immutable.

---

## Comments

Single-line comments:

```guida
-- This is a comment
```

Multi-line comments:

```guida
{- This
   spans
   multiple lines -}
```
"""

                Route.ValuesAndTypes ->
                    markdownRender """
# Values and Types

Values and types are central to Guida.
Every expression has a type, and types are checked at compile time to catch errors early and make programs easier to reason about.

Guida follows Elm's type system closely, while laying the groundwork for future extensions.

---

## Values

A **value** is the result of evaluating an expression.  
Values are **immutable** — once defined, they never change.

```guida
count =
    10

greeting =
    "Hello"
````

Functions are also values:

```guida
increment x =
    x + 1
```

---

## Primitive Types

Guida provides the same core primitive types as Elm:

| Type     | Description              |
| -------- | ------------------------ |
| `Int`    | Whole numbers            |
| `Float`  | Floating-point numbers   |
| `Bool`   | `True` or `False`        |
| `Char`   | Single Unicode character |
| `String` | UTF-8 encoded text       |

### Numeric Literals (Guida extension)

Guida allows underscores in numeric literals for readability:

```guida
timeout =
    60_000

piApprox =
    3.141_592
```

<info>
Elm does not support numeric separators.
Guida allows **`_` in numeric literals** for readability.
</info>

---

## Type Inference

Guida uses **global type inference**.
In most cases, you do not need to write type annotations — the compiler can infer them automatically.

```guida
add x y =
    x + y
```

The inferred type is:

```guida
add : number -> number -> number
```

---

## Type Annotations

You can add type annotations to make code clearer or to guide the compiler:

```guida
add : number -> number -> number
add x y =
    x + y
```

Type annotations are recommended.

---

## Function Types

Function types use arrows (`->`):

```guida
isEven : Int -> Bool
```

Functions that return functions are common:

```guida
add : Int -> Int -> Int
```

This means “a function that takes an `Int` and returns a function that takes an `Int` and returns another `Int`”.

---

## Composite Types

### Tuples

```guida
pair : ( String, Int )
pair =
    ( "Alice", 30 )
```

Guida allows tuples with more than three elements:

```guida
recording :
    ( String, Int, Bool, Float )
```

<info>
Elm limits tuples to a maximum of 3 elements.
Guida allows **tuples of arbitrary length**.
</info>

---

### Records

Records group named values together:

```guida
user : { name : String, age : Int }
user =
    { name = "Alice", age = 30 }
```

Records use **structural typing** — only field names and types matter.

---

## Record Updates and Types

Basic record updates:

```guida
{ user | age = 31 }
```

Guida allows **updating records referenced by another record's field**:

```guida
model.user = { model.user | age = 31 }
```

<info>
Elm requires nested updates using intermediate bindings.
Guida allows **direct nested record updates**, reducing boilerplate.
</info>

---

## Custom Types

Custom types let you define your own data shapes:

```guida
type Status
    = Loading
    | Success String
    | Error String
```

Each constructor introduces a new possible value of the type.

---

## Pattern Matching and Types

Pattern matching ensures **exhaustiveness** — all possible cases must be handled:

```guida
statusMessage status =
    case status of
        Loading ->
            "Loading..."

        Success _ ->
            "Done"

        Error msg ->
            msg
```

### Named Wildcards

```guida
case value of
    _ignored ->
        defaultValue
```

<info>
Elm only allows the anonymous wildcard `_`.
Guida allows **named wildcards** (`_name`) to improve readability without introducing bindings.
</info>

---

## Type Aliases

Type aliases create readable names for complex types:

```guida
type alias User =
    { name : String
    , age : Int
    }
```

Aliases do not create new types — they only help writting types that are easier to read.

---

## Ports and Types

Guida supports Elm-style ports, with planned extensions.

```guida
port sendMessage : String -> Cmd msg
port messageReceiver : (String -> msg) -> Sub msg
```
"""

                Route.FunctionsAndExpressions ->
                    markdownRender """
# Functions and Expressions

Functions are the primary building block of Guida programs.
Everything in Guida is an **expression**, and expressions always evaluate to a value.

This section explains how functions are defined, applied, and composed, and how expressions are structured.

---

## Defining Functions

Functions are defined by listing parameters followed by `=`:

```guida
add x y =
    x + y
````

This defines a function that takes two arguments and returns their sum.

Functions are **pure** — given the same inputs, they always produce the same output.

---

## Function Application

Function application uses whitespace instead of parentheses:

```guida
add 2 3
```

Application is **left-associative**:

```guida
add 2 3 4
```

is interpreted as:

```guida
((add 2) 3) 4
```

---

## Anonymous Functions

Anonymous (lambda) functions are written using `\\`:

```guida
List.map (\\x x * 2) [ 1, 2, 3 ]
```

Anonymous functions are commonly used for short transformations.

---

## Partial Application

Functions can be partially applied:

```guida
addTwo =
    add 2
```

Here, `addTwo` is a function that takes one argument and adds `2`.

Partial application is a core feature of Guida.

---

## Let Expressions

Use `let ... in` to define local bindings:

```guida
greet name =
    let
        message =
            "Hello, " ++ name
    in
    message
```

Everything inside `let` is an expression and must produce a value.

---

## If Expressions

Conditionals are expressions and must include both branches:

```guida
absolute n =
    if n < 0 then
        -n
    else
        n
```

The `then` and `else` branches must return values of the same type.

---

## Case Expressions

Use `case` to branch on data using pattern matching:

```guida
describe list =
    case list of
        [] ->
            "empty"

        x :: xs ->
            "non-empty"
```

### Exhaustiveness

Guida requires all possible cases to be handled:

```guida
case status of
    Loading ->
        "Loading"
```

This will result in a compile-time error if cases are missing.

---

## Pattern Matching in Function Arguments

Patterns can be used directly in function parameters:

```guida
length list =
    case list of
        [] ->
            0

        _ :: xs ->
            1 + length xs
```

---

## Named Wildcards in Patterns

```guida
case value of
    _ignored ->
        defaultValue
```

<info>
Elm only allows the anonymous `_`.
Guida allows named wildcards for improved readability without introducing bindings.
</info>

---

## Operators as Functions

Operators are functions and can be used infix or prefix:

```guida
1 + 2
(+) 1 2
```

This allows operators to be passed as arguments:

```guida
List.foldl (+) 0 numbers
```

---

## Pipelines

Pipelines help write readable, left-to-right code:

```guida
numbers
    |> List.map (\\x x * 2)
    |> List.filter (\\x x > 5)
```

Pipelines do not change evaluation order — they only affect readability.

---

## Composition

Function composition uses `<<` and `>>`:

```guida
toString << sqrt << toFloat
```

---

## Expressions Everywhere

In Guida, everything is an expression:

* `if` expressions
* `case` expressions
* `let` expressions
* Function bodies

This consistency enables strong composability.
"""

                Route.ModulesAndImports ->
                    markdownRender """
# Modules and Imports

Modules are Guida's primary unit of organization.
They define **namespaces**, control **visibility**, and help structure applications and libraries into clear, reusable components.

Guida follows Elm's module system closely, while leaving room for future extensions.

---

## Defining a Module

Every Guida source file defines exactly one module.

```guida
module Main exposing (main)
````

* The module name must match the file name (`Main.guida`)
* Module names are capitalized and may be nested using dots

Example:

```guida
module MyApp.Utils.String exposing (capitalize)
```

File path:

```
src/MyApp/Utils/String.guida
```

---

## Exposing Values

The `exposing` clause defines what is accessible from outside the module.

### Exposing Specific Values

```guida
module Math exposing (add, subtract)
```

Only `add` and `subtract` are public.

---

### Exposing Everything

```guida
module Math exposing (..)
```

All values, types, and constructors become public.

> ⚠️ Exposing everything is convenient for small modules but discouraged for libraries.

---

## Importing Modules

Use `import` to bring another module into scope:

```guida
import Html
```

Imported values must be referenced using the module name:

```guida
Html.text "Hello"
```

---

## Importing with Aliases

Aliases make long module names easier to work with:

```guida
import Html.Attributes as Attr
```

Usage:

```guida
Attr.class "container"
```

---

## Importing Specific Values

You can import only what you need:

```guida
import Html exposing (text)
```

This allows using `text` without the module prefix.

```guida
Html.div [] [ text "Hello" ]
```

---

## Importing Types and Constructors

Custom types can be imported with or without constructors.

```guida
import Status exposing (Status(..))
```

This imports the type and all of its constructors.

To import only the type name:

```guida
import Status exposing (Status)
```

---

## Qualified Imports and Clarity

Guida encourages **explicit imports** and qualified access for clarity, especially in large codebases.

```guida
import User.Profile as Profile
```

This makes it clear where values originate from.

---

## Module Cycles

Guida does not allow circular module dependencies.

```text
A → B → C → A  ❌
```

This restriction ensures predictable compilation and clearer architecture.

---

## Modules and Types

Type aliases and custom types follow the same exposure rules as values:

```guida
module User exposing (User, create)
```

Constructors must be explicitly exposed if needed:

```guida
module Status exposing (Status(..))
```
"""

                Route.CustomTypes ->
                    markdownRender """
# Custom Types

Custom types allow you to define your own data structures by explicitly listing all possible shapes a value can take.  
They are a core feature of Guida and are commonly used to model state, domain concepts, and control flow.

Guida follows Elm's custom type system closely, while allowing room for future extensions.

---

## Defining a Custom Type

Custom types are defined using the `type` keyword:

```guida
type Status
    = Loading
    | Success String
    | Error String
````

This defines a new type `Status` with three possible values.

Each variant is called a **constructor**.

---

## Constructors

Constructors are functions that create values of the custom type:

```guida
loading : Status
loading =
    Loading

success : String -> Status
success msg =
    Success msg
```

Each constructor has a type derived from its parameters.

---

## Using Custom Types

Custom types are commonly used with `case` expressions:

```guida
statusMessage status =
    case status of
        Loading ->
            "Loading..."

        Success msg ->
            msg

        Error err ->
            err
```

Guida ensures that all cases are handled at compile time.

---

## Exhaustiveness Checking

Guida requires pattern matches on custom types to be **exhaustive**:

```guida
case status of
    Loading ->
        "Loading"
```

This will result in a compile-time error if cases are missing.

This guarantees that no case is accidentally ignored.

---

## Custom Types vs Type Aliases

Custom types and type aliases serve different purposes.

### Type Alias

```guida
type alias User =
    { name : String
    , age : Int
    }
```

Type aliases name an existing structure.

### Custom Type

```guida
type User
    = Guest
    | Registered String
```

Custom types define a closed set of possible values.

---

## Parameterized Custom Types

Custom types can take type parameters:

```guida
type Result error value
    = Ok value
    | Err error
```

This allows custom types to be reused with different data.

---

## Recursive Custom Types

Custom types can be recursive:

```guida
type Tree
    = Empty
    | Node Int Tree Tree
```

Recursive types are commonly used for trees and other hierarchical data.

---

## Pattern Matching with Custom Types

Pattern matching can destructure values inside constructors:

```guida
case result of
    Ok value ->
        value

    Err _ ->
        defaultValue
```

### Named Wildcards (Guida Extension)

```guida
Err _ignored ->
    defaultValue
```

<info>
Elm only allows the anonymous `_`.
Guida allows named wildcards to improve readability without introducing bindings.
</info>

---

## Custom Types in Public APIs

When exposing custom types from a module, you control whether constructors are public:

```guida
module Status exposing (Status(..))
```

This exposes both the type and its constructors.

To expose the type without constructors:

```guida
module Status exposing (Status)
```

This allows consumers to work with the type abstractly.
"""

                Route.PatternMatching ->
                    markdownRender """
# Pattern Matching

Pattern matching allows you to inspect and destructure values based on their shape.
It is one of the most powerful features in Guida and is used extensively with custom types, lists, tuples, and records.

Guida follows Elm's pattern-matching model closely, with a few targeted extensions.

---

## Where Pattern Matching Is Used

Pattern matching appears in several places:

- `case` expressions
- Function arguments
- `let` bindings
- Destructuring assignments

---

## Case Expressions

The most explicit form of pattern matching is the `case` expression:

```guida
describe value =
    case value of
        Just x ->
            x

        Nothing ->
            "none"
````

Every possible case must be handled.

---

## Exhaustiveness Checking

Guida checks pattern matches at compile time to ensure they are **exhaustive**.

```guida
case status of
    Loading ->
        "Loading"
```

This will produce a compiler error if other cases are missing.

This guarantees that pattern matching cannot fail at runtime.

---

## Matching Custom Types

Custom types are commonly matched by constructor:

```guida
case result of
    Ok value ->
        value

    Err error ->
        error
```

Each constructor introduces a new branch.

---

## Matching Lists

Lists can be matched using `[]` and `(::)`:

```guida
case list of
    [] ->
        "empty"

    x :: xs ->
        "non-empty"
```

---

## Matching Tuples

Tuples can be destructured positionally:

```guida
case pair of
    ( name, age ) ->
        name
```

Guida allows matching tuples with more than three elements:

```guida
( x, y, z, t ) ->
    x + y
```

<info>
Elm limits tuples to three elements.
Guida allows tuples of arbitrary length.
</info>

---

## Record Pattern Matching

Records can be destructured by field name:

```guida
case user of
    { name, age } ->
        name
```

Only the listed fields are matched.

---

## Pattern Matching in Function Arguments

Patterns can appear directly in function parameters:

```guida
userAge { age } =
    age
```

---

## Wildcard Patterns

### Anonymous Wildcard

```guida
case value of
    _ ->
        defaultValue
```

This matches anything and ignores the value.

Guida allows named wildcards:

```guida
case value of
    _unused ->
        defaultValue
```

<info>
Elm only supports the anonymous `_`.
Guida allows named wildcards to improve readability without introducing bindings.
</info>

Named wildcards do not introduce a usable variable.

---

## Literal Patterns

You can match on literals:

```guida
case number of
    0 ->
        "zero"

    1 ->
        "one"

    _ ->
        "many"
```

---

## Pattern Matching in Let Bindings

Values can be destructured in `let` bindings:

```guida
let
    ( x, y ) =
        point
in
x + y
```

The pattern must match, or compilation fails.

---

## Nested Patterns

Patterns can be nested:

```guida
case data of
    Just ( x, y ) ->
        x + y

    Nothing ->
        0
```
"""

                Route.ErrorHandling ->
                    markdownRender """
# Error Handling

Guida does not use exceptions for error handling.
Instead, errors are represented explicitly in the type system, making all failure cases visible and enforceable at compile time.

This approach encourages safer, more predictable programs.

---

## Errors as Data

In Guida, errors are values.
They are typically represented using custom types such as `Maybe` and `Result`.

```guida
type Result error value
    = Ok value
    | Err error
````

A function that may fail returns a value that encodes both success and failure cases.

---

## Using `Maybe`

`Maybe` represents an optional value:

```guida
type Maybe a
    = Just a
    | Nothing
```

Example:

```guida
findUser : Int -> Maybe User
```

Handling a `Maybe` value requires pattern matching:

```guida
case findUser id of
    Just user ->
        user.name

    Nothing ->
        "Unknown user"
```

This makes missing data explicit.

---

## Using `Result`

`Result` is used when failures need more information:

```guida
parseInt : String -> Result String Int
```

Handling a `Result`:

```guida
case parseInt input of
    Ok value ->
        value

    Err message ->
        message
```

The error type can be any type, including a custom one.

---

## Chaining Computations

Guida provides functions for working with `Maybe` and `Result` values:

```guida
Result.map toString result
Result.andThen parseNext result
```

This allows errors to propagate naturally without explicit branching at every step.

---

## Custom Error Types

For larger applications, custom error types improve clarity:

```guida
type LoginError
    = InvalidCredentials
    | NetworkError
    | ServerError String
```

Using a custom error type ensures all error cases are handled explicitly.

---

## Pattern Matching and Exhaustiveness

When matching on error values, Guida enforces exhaustiveness:

```guida
case login user pass of
    Ok session ->
        session

    Err InvalidCredentials ->
        "Wrong password"

    Err NetworkError ->
        "Connection failed"

    Err (ServerError msg) ->
        msg
```

This prevents unhandled error cases.

---

## No Runtime Exceptions

Guida does not support runtime exceptions for user code.

<info>
Errors are not thrown or caught at runtime.
All error cases must be handled explicitly through types.
</info>

This leads to more predictable and maintainable programs.

---

## Compiler Errors vs Runtime Errors

It's important to distinguish between:

* **Compiler errors**: Type mismatches, missing cases, invalid syntax
* **Runtime errors**: Represented explicitly using `Maybe` or `Result`

Many classes of runtime errors are eliminated by the compiler.
"""

                Route.GuidaJson ->
                    markdownRender """
# guida.json

Guida introduces a configuration file called **`guida.json`**.
Its presence at the root of a project determines whether the project is treated as a **Guida project** or an **Elm project**.

This file plays a role similar to `elm.json`, but with important differences that enable Guida-specific syntax, files, and dependencies, while still supporting gradual migration from Elm.

---

## Elm Projects vs Guida Projects

Guida distinguishes projects based on which configuration file is present:

### Elm Project
- Contains an `elm.json`
- Does **not** contain a `guida.json`
- Only `.elm` files are allowed
- Only Elm 0.19.1 syntax is allowed
- Fully compatible with the Elm toolchain

### Guida Project
- Contains a `guida.json` at the project root
- May also contain an `elm.json`, but **`guida.json` takes precedence**
- Allows:
  - `.guida` files using Guida syntax
  - `.elm` files using **Elm-only syntax**
- Enables gradual migration from Elm to Guida

<info>
Adding a `guida.json` turns an Elm project into a Guida project.  
Existing `.elm` files continue to work unchanged, while new Guida features can be adopted incrementally.
</info>

---

## Why `guida.json` Exists

`guida.json` serves two main purposes:

1. **Project identity**  
   It explicitly marks a project as a Guida project, enabling Guida syntax and `.guida` files.

2. **Dependency and version management**  
   It replaces Elm's package structure with a Guida-specific one, centered around a unified standard library.

This design allows Elm and Guida code to coexist during migration, without ambiguity or breaking changes.

---

## Application Projects

Running `guida init` creates a `guida.json` file for an application project.

Example:

```json
{
  "type": "application",
  "source-directories": [
    "src"
  ],
  "guida-version": "1.0.0",
  "dependencies": {
    "direct": {
      "guida-lang/stdlib": "1.0.1"
    },
    "indirect": {}
  },
  "test-dependencies": {
    "direct": {},
    "indirect": {}
  }
}
````

### Key Differences from `elm.json`

* **`guida-version`** replaces `elm-version`

  This specifies which versions of Guida the project is compatible with.

* **Unified standard library**

  By default, Guida depends only on `guida-lang/stdlib`.
  This package includes the functionality traditionally provided by  `elm/*` and `elm-explorations/*`.
  As a result, Guida projects typically require fewer explicit dependencies.

---

## Package Projects

Running `guida init --package` creates a `guida.json` suitable for publishing a Guida package.

Example:

```json
{
  "type": "package",
  "name": "author/project",
  "summary": "helpful summary of your project, less than 80 characters",
  "license": "BSD-3-Clause",
  "version": "1.0.0",
  "exposed-modules": [],
  "guida-version": "1.0.0 <= v < 2.0.0",
  "dependencies": {
    "guida-lang/stdlib": "1.0.1 <= v < 2.0.0"
  },
  "test-dependencies": {}
}
```

### Differences from Elm Packages

* Uses **`guida-version`** instead of `elm-version`
* Depends on **`guida-lang/stdlib`** instead of individual `elm` and `elm-explorations` packages

---

## Mixing `.elm` and `.guida` Files

In a Guida project:

* `.guida` files:
  * Can use Guida syntax and features
* `.elm` files:
  * Must remain valid Elm 0.19.1 code
  * Cannot use Guida-specific syntax

This rule ensures:

* Backward compatibility
* Clear boundaries between Elm and Guida code
* Safe, incremental migration paths

---

## Summary

* `guida.json` defines a project as a **Guida project**
* Its presence enables Guida syntax and `.guida` files
* It takes precedence over `elm.json` if both exist
* Guida simplifies dependency management via `guida-lang/stdlib`
* Elm code remains first-class and supported during migration

With `guida.json`, Guida extends Elm's project model while keeping it familiar and predictable.
"""

                Route.ImmutabilityAndPurity ->
                    markdownRender """
# Immutability and Purity

Immutability and purity are foundational concepts in Guida.
They shape how data is modeled, how programs are structured, and how systems remain reliable as they grow.

Guida inherits these principles from Elm and preserves them as core guarantees of the language.

---

## Immutability

In Guida, **values are immutable**.

Once a value is created, it can never be changed. There is no assignment that mutates existing data, and there is no concept of in-place updates.

```guida
count = 0
newCount = count + 1
````

Here, `newCount` is a new value. The original `count` remains unchanged.

This applies uniformly to:

* Numbers and strings
* Lists and arrays
* Records
* Custom types

---

## Updating Data by Creating New Values

Instead of modifying data, Guida encourages **creating updated copies**.

### Records

```guida
user =
    { name = "Alex"
    , age = 30
    }

olderUser =
    { user | age = user.age + 1 }
```

The original `user` record is unchanged.
`olderUser` is a new record with an updated `age`.

---

## Why Immutability Matters

Immutability provides strong guarantees:

* **No hidden state changes**
* **Predictable behavior**
* **Safe concurrency**
* **Simpler reasoning about code**

When data cannot change unexpectedly, understanding and refactoring code becomes significantly easier.

---

## Purity

Guida functions are **pure by default**.

A pure function:

* Always produces the same output for the same input
* Has no side effects
* Does not depend on external or hidden state

```guida
add a b =
    a + b
```

Calling `add 2 3` will *always* return `5`.

---

## Side Effects Are Explicit

Operations that interact with the outside world, such as:

* HTTP requests
* Reading the current time
* Random number generation
* Interacting with JavaScript

are not performed directly inside functions.

Instead, Guida models side effects explicitly, making them visible in the program structure.

This ensures:

* Side effects are controlled
* Behavior remains predictable
* Testing becomes easier

---

## Immutability and the Architecture

These principles enable Guida's application architecture:

* State is represented as immutable data
* Updates create new versions of state
* Effects are described, not executed directly

This separation keeps business logic clean and declarative.

---

## Guida vs Elm

<info>
Guida preserves Elm's guarantees around immutability and purity.
Even as Guida introduces new syntax and capabilities, these principles remain non-negotiable.
</info>

---

## Summary

* All values in Guida are immutable
* Functions are pure by default
* State changes are modeled by creating new values
* Side effects are explicit and controlled

These guarantees form the basis for reliable, maintainable Guida programs and underpin every other core concept in the language.
"""

                Route.TheTypeSystem ->
                    markdownRender """
# The Type System

Guida has a **strong, static type system** designed to catch errors early, make code easier to understand, and support long-term maintainability.

The type system is closely aligned with Elm's, while serving as a stable foundation for Guida-specific evolution.

---

## Strong and Static Typing

Guida is **statically typed**.

This means:
- Types are checked at compile time
- Many errors are caught before the program runs
- Well-typed programs do not encounter type errors at runtime

```guida
add a b =
    a + b
````

Here, the compiler infers the type:

```guida
add : number -> number -> number
```

You are not required to annotate types, but you can when clarity is useful.

---

## Type Inference

Guida uses **type inference** to reduce boilerplate.

The compiler automatically determines the most general type that satisfies the program.

```guida
identity x =
    x
```

Inferred type:

```guida
identity : a -> a
```

Type inference keeps code concise while preserving safety.

---

## Explicit Type Annotations

You can add type annotations to:

* Document intent
* Improve error messages
* Lock down public APIs

```guida
increment : Int -> Int
increment n =
    n + 1
```

Type annotations are especially recommended for:

* Public functions
* Module interfaces
* Library code

---

## No `null`, No Implicit Undefined Values

Guida does not have:

* `null`
* `undefined`
* Implicit missing values

Instead, absence is modeled explicitly using types such as `Maybe`.

```guida
findUser : Id -> Maybe User
```

This forces all cases to be handled, eliminating a large class of runtime errors.

---

## Algebraic Data Types

Guida supports **algebraic data types** (also called custom types).

```guida
type Status
    = Loading
    | Success Data
    | Failure Error
```

These types:

* Encode domain logic directly in the type system
* Make invalid states unrepresentable
* Work seamlessly with pattern matching

---

## Exhaustive Pattern Matching

When pattern matching on a type, Guida ensures **all cases are handled**.

```guida
view status =
    case status of
        Loading ->
            "Loading..."

        Success data ->
            "Done"

        Failure err ->
            "Something went wrong"
```

Missing cases result in compile-time errors.

---

## Parametric Polymorphism

Guida supports **parametric polymorphism**, allowing types to be generic.

```guida
type Box a =
    Box a
```

This enables reusable abstractions without sacrificing type safety.

---

## Type Safety as a Design Constraint

Guida treats type safety as a **non-negotiable constraint**, not an optional feature.

* Unsafe casts are not allowed
* Types cannot be bypassed
* Compiler guarantees are trusted and enforced

These constraints enable confident refactoring and large-scale codebases.

---

## Guida vs Elm

<info>
Guida's type system is intentionally aligned with Elm's.
New language features are designed to integrate with the type system, not weaken it.
</info>

---

## Summary

* Guida is strongly and statically typed
* Types are inferred automatically
* Explicit annotations improve clarity and stability
* Absence is modeled explicitly
* Custom types and pattern matching are central tools

The type system is the backbone of Guida's reliability and a key reason why programs remain correct as they evolve.
"""

                Route.ConcurrencyAndEffects ->
                    markdownRender """
# Concurrency and Effects

Guida supports concurrency while preserving the guarantees of immutability and purity.
Rather than relying on shared mutable state, Guida uses a **message-based model** where effects and concurrency are explicit and controlled.

This approach enables scalable applications without introducing race conditions or unpredictable behavior.

---

## No Shared Mutable State

In Guida, there is no shared mutable memory between concurrent parts of a program.

Because:
- All values are immutable
- Functions are pure
- State is replaced, not mutated

Concurrency does not require locks, mutexes, or synchronization primitives.

This eliminates an entire class of bugs common in traditional concurrent systems.

---

## Effects Are Explicit

Guida separates **pure logic** from **effects**.

Pure code:
- Computes values
- Transforms data
- Is easy to test and reason about

Effects:
- Interact with the outside world
- Are represented explicitly in program structure
- Are executed by the runtime, not by arbitrary functions

This separation ensures that concurrency does not compromise correctness.

---

## The Command and Message Model

Concurrency in Guida is expressed through **commands** and **messages**.

- **Commands** describe work to be done (such as HTTP requests or timers)
- **Messages** represent the results of that work

```guida
update msg model =
    case msg of
        FetchData ->
            ( model, fetchData )

        DataFetched result ->
            ( { model | data = result }, none )
````

The runtime:

* Executes commands concurrently when possible
* Delivers messages back to the program
* Ensures all updates remain pure and sequential

---

## Cooperative Concurrency

Guida's concurrency model is **cooperative**, not preemptive.

* Programs do not block threads
* Long-running work is expressed as effects
* The runtime schedules and coordinates execution

This keeps application logic simple while allowing the runtime to handle complexity efficiently.

---

## Tasks and Asynchronous Work

Asynchronous operations are modeled using **tasks**.

Tasks:

* Represent work that may succeed or fail
* Do not execute immediately
* Are converted into commands when needed

```guida
getTime : Task Error Time
```

Tasks make asynchrony explicit and composable.

---

## Error Handling in Concurrent Code

Errors from concurrent operations are represented as values.

```guida
Task Error Result
```

This means:

* Failures must be handled explicitly
* No uncaught exceptions
* Error handling is enforced by the type system

Concurrency does not introduce hidden failure modes.

---

## Deterministic Updates

Even when multiple commands run concurrently:

* Messages are processed one at a time
* State updates are deterministic
* The order of handling messages is well-defined

This ensures that the same sequence of messages always produces the same result.

---

## Guida vs Elm

<info>
Guida follows Elm's concurrency and effect model.
While Guida may introduce new effect capabilities over time, the core principles of explicit
effects and message-based concurrency remain unchanged.
</info>

---

## Summary

* Guida enables concurrency without shared mutable state
* Effects are explicit and controlled
* Asynchronous work is modeled with tasks and commands
* Errors are values, not exceptions
* Concurrent programs remain deterministic and predictable

This model allows Guida programs to scale in complexity while preserving reliability and clarity.
"""

                Route.StateAndArchitecture ->
                    markdownRender """
# State and Architecture

<todo />
"""

                Route.ApplicationStructure ->
                    markdownRender """
# Application Structure

<todo />
"""

                Route.TheGuidaArchitecture ->
                    markdownRender """
# The Guida Architecture

<todo />
"""

                Route.RoutingAndNavigation ->
                    markdownRender """
# Routing and Navigation

<todo />
"""

                Route.Interoperability ->
                    markdownRender """
# Interoperability

<todo />
"""

                Route.ContributingGettingStarted ->
                    markdownRender """
# Getting Started

<todo />
"""

                Route.ContributingWaysToContribute ->
                    markdownRender """
# Ways To Contribute

<todo />
"""

                Route.ContributingDevelopmentWorkflow ->
                    markdownRender """
# Development Workflow

<todo />
"""

                Route.ContributingReportingIssues ->
                    markdownRender """
# Reporting Issues

<todo />
"""

                Route.ContributingJoinTheCommunity ->
                    markdownRender """
# Join the Community

<todo />
"""

                Route.Commands command ->
                    commandView command

                Route.Hints hint ->
                    hintView hint
    }



-- 0. OVERVIEW


introductionView : List (Html msg)
introductionView =
    markdownRender """
# Introduction

Welcome to the **Guida Documentation** — your complete guide to understanding, using,
and contributing to the Guida programming language.

Guida builds upon the foundation of [Elm](https://elm-lang.org/), with a focus on
long-term stability, modern tooling, and an open ecosystem.

This documentation is designed to help everyone — from developers trying Guida for
the first time, to teams adopting it, to contributors improving the language itself.

## What You'll Find Here

This documentation is organized as a **book**, moving from high-level concepts to
practical guides and advanced topics.
Each section builds on the previous one, so you can read it in order or jump directly
to what you need.

### 1. Getting Started

Covers the basics of installing and running Guida, setting up your environment, and
compiling your first project.

If you're new to the language, this is the best place to start.

### 2. The Language

An introduction to the syntax, types, and semantics of Guida — for those familiar
with [Elm](https://elm-lang.org/), this section highlights what's identical and what's evolving.

It also includes deeper dives into functions, types, modules, and language features.

### 3. Core Concepts

Explore the key ideas that shape Guida's design — from its functional programming
foundations to its type system and immutability model.
This section explains how Guida relates to [Elm](https://elm-lang.org/), and what makes
its approach to clarity and composition distinct.

### 4. Building Applications

Understand how to organize Guida projects, structure modules, manage dependencies, and
build real-world applications.
Includes patterns for architecture, testing, and interop with JavaScript code.

### 5. Commands

A complete reference for the Guida CLI — including all supported commands, options,
and common workflows.

### 6. Contributing

Explains how to contribute to Guida itself: from working on the compiler, to testing,
documentation, and ecosystem packages.

It also describes the principles behind Guida's self-hosted development model.

### 7. Advanced Topics

For readers who want to dive deeper into how Guida works under the hood.

## How to Use This Documentation

You can approach this guide in two ways:

- **As a learner:** Read from start to finish to understand Guida's philosophy, syntax,
and tooling.  
- **As a reference:** Jump to sections using the sidebar or search to look up specific
commands, examples, or design details.

Every section includes links to related topics, examples, and source code, so you can
explore at your own pace.

## Staying Up to Date

Guida is an evolving project.

As the language, compiler, and ecosystem grow, this documentation will evolve too — with
notes marking version changes and upcoming features.

You can follow ongoing discussions and announcements on
the [Guida Discord server](https://discord.gg/Ur33engz).
  """


whatIsGuidaView : List (Html msg)
whatIsGuidaView =
    markdownRender
        """
# What is Guida?

**Guida** is a functional programming language that builds upon the foundation of [Elm](https://elm-lang.org/), offering **backward compatibility with all existing Elm 0.19.1 projects**.

Guida's main goal is to provide a language and toolchain that feel familiar to Elm developers while enabling broader adoption in professional and team environments.  
It aims to give companies confidence to use and invest in a language that is reliable, maintainable, and evolving in an open way.

Join the [Guida Discord server](https://discord.gg/Ur33engz) to connect with the community, ask questions, and share ideas.

## Vision

Guida builds on the foundations of [Elm](https://elm-lang.org/), aiming to advance the future of functional programming.
By translating Elm's compiler from Haskell to a self-hosted environment, Guida helps developers to
build reliable, maintainable, and performant applications without leaving the language they love.

**Continuity and Confidence (Version 0.x):**
Guida starts by ensuring full backward compatibility with Elm v0.19.1, allowing developers to migrate
effortlessly and explore Guida with complete confidence.

This commitment to continuity means that this version will faithfully replicate not only the
features and behaviors of Elm v0.19.1, but also any existing bugs and quirks.
By doing so, we provide a stable and predictable environment for developers, ensuring that their
existing Elm projects work exactly as expected when migrated to Guida.

**Evolution and Innovation (Version 1.x and Beyond):**
As Guida evolves, we will introduce new features and improvements.
This phase will foster a unified ecosystem that adapts to the needs of its users.

**Core Principles:**

- **Backward Compatibility:** Respect for existing Elm projects, ensuring a frictionless migration.
- **Accessibility:** Lowering barriers for developers by implementing Guida's core in its own syntax.

Our ultimate goal is to create a language that inherits the best aspects of Elm while adapting and
growing to meet the needs of its users.
"""


commandView : Route.Command -> List (Html msg)
commandView command =
    case command of
        Route.Repl ->
            markdownRender """
# guida repl

The REPL lets you interact with Guida values and functions in your terminal.

You can type in expressions, definitions, custom types, and module imports using normal Guida syntax.

```guida
> 1 + 1
2 : number

> "hello" ++ "world"
"helloworld" : String
```

The same can be done with definitions and custom types:

```guida
> fortyTwo = 42
42 : number

> increment n = n + 1
<function> : number -> number

> increment 41
42 : number

> factorial n =
|   if n < 1 then
|     1
|   else
|     n * factorial (n-1)
|
<function> : number -> number

> factorial 5
120 : number

> type User
|   = Regular String
|   | Visitor String
|

> case Regular "Tom" of
|   Regular name -> "Hey again!"
|   Visitor name -> "Nice to meet you!"
|
"Hey again!" : String
```

When you run `guida repl` in a project with a [`guida.json`](/docs/guida-json) file,
you can import any module available in the project. So if your project has an `guida-lang/project-metadata-utils`
dependency, you could say:

```guida
> import Guida.Version
> Guida.Version.one
Version 1 0 0 : Guida.Version.Version
```

When you run `guida repl` in a project with an `elm.json` file,
you can also import any module available in the project. So if your project has an `elm/html`
dependency, you could also say:

```guida
> import Html exposing (Html)
> Html.text "hello"
<internals> : Html msg
> Html.text
<function> : String -> Html msg
```

If you create a module in your project named `MyThing` in your project, you can say
`import MyThing` in the REPL as well. Any module that is accessible in your project
should be accessible in the REPL.

One thing to notice, is that the REPL will only accept Guida syntax if you are running
within a Guida project (i.e. a project with a `guida.json` file), or a folder without
an `elm.json` file. If you are in an Elm project, the REPL will only accept Elm syntax.

---

## Exit

To exit the REPL, you can type `:exit`.

You can also press `ctrl-d` or `ctrl-c` on some platforms.

---

## Flags

You can customize this command with the following flags:

<properties>
  <property name="--interpreter=<interpreter>">Path to a alternate JS interpreter, like node or nodejs.</property>
  <property name="--no-colors">Turn off the colors in the REPL. This can help if you are having trouble reading the values. Some terminals use a custom color scheme that diverges significantly from the standard ANSI colors, so another path may be to pick a more standard color scheme.</property>
</properties>

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/repl.md>
"""

        Route.Init ->
            markdownRender """
# guida init

<todo />

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/init.md>
"""

        Route.Make ->
            markdownRender """
# guida make

<todo />
"""

        Route.Install ->
            markdownRender """
# guida install

<todo />
"""

        Route.Uninstall ->
            markdownRender """
# guida uninstall

<todo />
"""

        Route.Bump ->
            markdownRender """
# guida bump

<todo />
"""

        Route.Diff ->
            markdownRender """
# guida diff

<todo />
"""

        Route.Publish ->
            markdownRender """
# guida publish

<todo />
"""

        Route.Format ->
            markdownRender """
# guida format

<todo />
"""

        Route.Test ->
            markdownRender """
# guida test

<todo />
"""


hintView : Route.Hint -> List (Html msg)
hintView hint =
    case hint of
        Route.BadRecursion ->
            markdownRender """
# Bad Recursion

There are two problems that will lead you here, both of them pretty tricky:

  1. [**No Mutation**](#no-mutation) - Defining values in Guida is slightly different than
  defining values in languages like JavaScript.
  2. [**Tricky Recursion**](#tricky-recursion) - Sometimes you need to define recursive values
  when creating generators, decoders, and parsers. A common case is a JSON decoder a discussion
  forums where a comment may have replies, which may have replies, which may have replies, etc.

## No Mutation

Languages like JavaScript let you "reassign" variables. When you say `x = x + 1` it means:
whatever `x` was pointing to, have it point to `x + 1` instead. This is called *mutating* a
variable. All values are immutable in Guida, so reassigning variables does not make any sense!
Okay, so what *should* `x = x + 1` mean in Guida?

Well, what does it mean with functions? In Guida, we write recursive functions like this:

```guida
factorial : Int -> Int
factorial n =
  if n <= 0 then 1 else n * factorial (n - 1)
```

One cool thing about Guida is that whenever you see `factorial 3`, you can always replace that
expression with `if 3 <= 0 then 1 else 3 * factorial (3 - 1)` and it will work exactly the same.
So when Guida code gets evaluated, we will keep expanding `factorial` until the `if` produces a 1.
At that point, we are done expanding and move on.

The thing that surprises newcomers is that recursion works the same way with values too. So
take the following definition:

```guida
x = x + 1
```

We are actually defining `x` in terms of itself. So it would expand out to `x = ... + 1 + 1 + 1 + 1`,
trying to add one to `x` an infinite number of times! This means your program would just
run forever, endlessly expanding `x`. In practice, this means the page freezes and the computer
starts to get kind of warm. No good! We can detect cases like this with the compiler, so we
give an error at compile time so this does not happen in the wild.

The fix is usually to just give the new value a new name. So you could rewrite it to:

```guida
x1 = x + 1
```

Now `x` is the old value and `x1` is the new value. Again, one cool thing about Guida is
that whenever you see a `factorial 3` you can safely replace it with its definition.
Well, the same is true of values. Wherever I see `x1`, I can replace it with `x + 1`.
Thanks to the way definitions work in Guida, this is always safe!

## Tricky Recursion

Now, there are some cases where you *do* want a recursive value. Say you are building a
website with comments and replies. You may define a comment like this:

```guida
type alias Comment =
  { message : String
  , upvotes : Int
  , downvotes : Int
  , responses : Responses
  }

type Responses =
  Responses (List Comment)
```

You may have run into this definition in the [hints for recursive aliases](/docs/1.0.0/hints/recursive-alias)!
Anyway, once you have comments, you may want to turn them into JSON to send back to your
server or to store in your database or whatever. So you will probably write some code like this:

```guida
import Json.Decode as Decode exposing (Decoder)

decodeComment : Decoder Comment
decodeComment =
  Decode.map4 Comment
    (Decode.field "message" Decode.string)
    (Decode.field "upvotes" Decode.int)
    (Decode.field "downvotes" Decode.int)
    (Decode.field "responses" decodeResponses)

-- PROBLEM
decodeResponses : Decoder Responses
decodeResponses =
  Decode.map Responses (Decode.list decodeComment)
```

The problem is that now `decodeComment` is defined in terms of itself! To know what
`decodeComment` is, I need to expand `decodeResponses`. To know what `decodeResponses` is,
I need to expand `decodeComment`. This loop will repeat endlessly!

In this case, the trick is to use `Json.Decode.lazy` which delays the evaluation of
a decoder until it is needed. So the valid definition would look like this:

```guida
import Json.Decode as Decode exposing (Decoder)

decodeComment : Decoder Comment
decodeComment =
  Decode.map4 Comment
    (Decode.field "message" Decode.string)
    (Decode.field "upvotes" Decode.int)
    (Decode.field "downvotes" Decode.int)
    (Decode.field "responses" decodeResponses)

-- SOLUTION

decodeResponses : Decoder Responses
decodeResponses =
  Decode.map Responses (Decode.list (Decode.lazy (\\_ -> decodeComment)))
```

Notice that in `decodeResponses`, we hide `decodeComment` behind an anonymous function.
Guida cannot evaluate an anonymous function until it is given arguments, so it allows us
to delay evaluation until it is needed. If there are no comments, we will not need to expand it!

This saves us from expanding the value infinitely. Instead we only expand the value if
we need to.

> **Note:** The same kind of logic can be applied to tasks, random value generators, and
parsers. Use `lazy` or `andThen` to make sure a recursive value is only expanded if needed.

## Understanding "Bad Recursion"

The compiler tries to detect bad recursion, but how does it know the difference between
good and bad situations? Writing `factorial` is fine, but writing `x = x + 1` is not. One version
of `decodeComment` was bad, but the other was fine. What is the rule?

**Guida will allow recursive definitions as long as there is at least one lambda before
you get back to yourself. **So if we write `factorial` without any pretty syntax, it looks
like this:

```guida
factorial =
  \\n -> if n <= 0 then 1 else n * factorial (n - 1)
```

There is technically a lambda between the definition and the use, so it is okay! The
same is true with the good version of `decodeComment`. There is a lambda between the
definition and the use. As long as there is a lambda before you get back to yourself,
the compiler will let it through.

**This rule is nice, but it does not catch everything.** It is pretty easy to write a
definition where the recursion is hidden behind a lambda, but it still immediately expands forever:

```guida
x =
  (\\_ -> x) () + 1
```

This follows the rules, but it immediately expands until our program runs out of stack
space. It leads to a runtime error as soon as you start your program. It is nice to fail fast,
but why not have the compiler detect this as well? It turns out this is much harder than it sounds!

This is called [the halting problem](https://en.wikipedia.org/wiki/Halting_problem) in
computer science. Computational theorists were asking:

> Can we determine if a program will finish running (i.e. halt) or if it will continue to
run forever?

It turns out that Alan Turing wrote a proof in 1936 showing that (1) in some cases you just
have to check by running the program and (2) this check will take forever for programs that
do not halt!

**So we cannot solve the halting problem *in general*, but our simple rule about lambdas
can detect the majority of bad cases *in practice*.**

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/bad-recursion.md>
"""

        Route.ComparingCustomTypes ->
            markdownRender """
# Comparing Custom Types

The built-in comparison operators work on a fixed set of types, like `Int` and `String`.
That covers a lot of cases, but what happens when you want to compare custom types?

This page aims to catalog these scenarios and offer alternative paths that can get you unstuck.

## Wrapped Types

It is common to try to get some extra type safety by creating really simple custom types:

```guida
type Id = Id Int
type Age = Age Int

type Comment = Comment String
type Description = Description String
```

By wrapping the primitive values like this, the type system can now help you make
sure that you never mix up a `Id` and an `Age`. Those are different types! This trick
is extra cool because it has no runtime cost in `--optimize` mode. The compiler can just
use an `Int` or `String` directly when you use that flag!

The problem arises when you want to use a `Id` as a key in a dictionary. This is a totally
reasonable thing to do, but the current version of Guida cannot handle this scenario.

Instead of creating a `Dict Id Info` type, one thing you can do is create a custom data
structure like this:

```guida
module User exposing (Id, Table, empty, get, add)

import Dict exposing (Dict)


-- USER

type Id = Id Int


-- TABLE

type Table info =
  Table Int (Dict Int info)

empty : Table info
empty =
  Table 0 Dict.empty

get : Id -> Table info -> Maybe info
get (Id id) (Table _ dict) =
  Dict.get id dict

add : info -> Table info -> (Table info, Id)
add info (Table nextId dict) =
  ( Table (nextId + 1) (Dict.insert nextId info dict)
  , Id nextId
  )
```

There are a couple nice things about this approach:

1. The only way to get a new `User.Id` is to `add` information to a `User.Table`.
2. All the operations on a `User.Table` are explicit. Does it make sense to remove users?
   To merge two tables together? Are there any special details to consider in those cases?
   This will always be captured explicitly in the interface of the `User` module.
3. If you ever want to switch the internal representation from `Dict` to `Array` or
   something else, it is no problem. All the changes will be within the `User` module.

So while this approach is not as convenient as using a `Dict` directly, it has some benefits
of its own that can be helpful in some cases.

## Enumerations to Ints

Say you need to define a `trafficLightToInt` function:

```guida
type TrafficLight = Green | Yellow | Red

trafficLightToInt : TrafficLight -> Int
trafficLightToInt trafficLight =
  ???
```

We have heard that some people would prefer to use a dictionary for this sort of thing.
That way you do not need to write the numbers yourself, they can be generated such that
you never have a typo.

I would recommend using a `case` expression though:

```guida
type TrafficLight = Green | Yellow | Red

trafficLightToInt : TrafficLight -> Int
trafficLightToInt trafficLight =
  case trafficLight of
    Green  -> 1
    Yellow -> 2
    Red    -> 3
```

This is really straight-forward while avoiding questions like “is `Green` less than or
greater than `Red`?”

## Something else?

If you have some other situation, please tell us about it [here](https://github.com/guida-lang/guida-lang.org/issues).
We can use the particulars of your scenario to add more advice on this page!

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/comparing-custom-types.md>
"""

        Route.ComparingRecords ->
            markdownRender """
# Comparing Records

The built-in comparison operators work on a fixed set of types, like `Int` and `String`.
That covers a lot of cases, but what happens when you want to compare records?

This page aims to catalog these scenarios and offer alternative paths that can get you unstuck.

## Sorting Records

Say we want a `view` function that can show a list of students sorted by different characteristics.

We could create something like this:

```guida
import Html exposing (..)

type alias Student =
  { name : String
  , age : Int
  , gpa : Float
  }

type Order = Name | Age | GPA

viewStudents : Order -> List Student -> Html msg
viewStudents order students =
  let
    orderlyStudents =
      case order of
        Name -> List.sortBy .name students
        Age -> List.sortBy .age students
        GPA -> List.sortBy .gpa students
  in
  ul [] (List.map viewStudent orderlyStudents)

viewStudent : Student -> Html msg
viewStudent student =
  li [] [ text student.name ]
```

If you are worried about the performance of changing the order or updating information
about particular students, you can start using the [`Html.Lazy`](https://package.guida-lang.org/packages/guida-lang/stdlib/latest/Html-Lazy)
and [`Html.Keyed`](https://package.guida-lang.org/packages/guida-lang/stdlib/latest/Html-Keyed) modules.
The updated code would look something like this:

```guida
import Html exposing (..)
import Html.Lazy exposing (lazy)
import Html.Keyed as Keyed

type Order = Name | Age | GPA

type alias Student =
  { name : String
  , age : Int
  , gpa : Float
  }

viewStudents : Order -> List Student -> Html msg
viewStudents order students =
  let
    orderlyStudents =
      case order of
        Name -> List.sortBy .name students
        Age -> List.sortBy .age students
        GPA -> List.sortBy .gpa students
  in
  Keyed.ul [] (List.map viewKeyedStudent orderlyStudents)

viewKeyedStudent : Student -> (String, Html msg)
viewKeyedStudent student =
  ( student.name, lazy viewStudent student )

viewStudent : Student -> Html msg
viewStudent student =
  li [] [ text student.name ]
```

By using `Keyed.ul` we help the renderer move the DOM nodes around based on their key.
This makes it much cheaper to reorder a bunch of students. And by using `lazy` we help
the renderer skip a bunch of work. If the `Student` is the same as last time, the render
can skip over it.

> **Note:** Some people are skeptical of having logic like this in `view` functions, but
> I think the alternative (maintaining sort order in your `Model`) has some serious downsides.
> Say a colleague is adding a message to `Add` students, but they do not know about the sort
> order rules needed for presentation. Bug! So in this alternate design, you must diligently
> test your `update` function to make sure that no message disturbs the sort order. This is bound
> to lead to bugs over time!
>
> With all the optimizations possible with `Html.Lazy` and `Html.Keyed`, I would always
> be inclined to work on optimizing my `view` functions rather than making my `update`
> functions more complicated and error prone.

## Something else?

If you have some other situation, please tell us about it [here](https://github.com/guida-lang/guida-lang.org/issues).
We can use the particulars of your scenario to add more advice on this page!

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/comparing-records.md>
"""

        Route.ImplicitCasts ->
            markdownRender """
# Implicit Casts

Many languages automatically convert from `Int` to `Float` when they think it is necessary.
This conversion is often called an [implicit cast](https://en.wikipedia.org/wiki/Type_conversion).

Languages that will add in implicit casts for addition include:

- JavaScript
- Python
- Ruby
- C
- C++
- C#
- Java
- Scala

These languages generally agree that an `Int` may be implicitly cast to a `Float` when necessary.
So everyone is doing it, why not Guida?!

## Type Inference + Implicit Casts

Guida comes from the ML-family of languages. Languages in the ML-family that **never** do
implicit casts include:

- Standard ML
- OCaml
- Elm
- F#
- Haskell

Why would so many languages from this lineage require explicit conversions though?

Well, we have to go back to the 1970s for some background. J. Roger Hindley and Robin Milner
independently discovered an algorithm that could _efficiently_ figure out the type of
everything in your program without any type annotations. Type Inference! Every ML-family
language has some variation of this algorithm at the center of its design.

For decades, the problem was that nobody could figure out how to combine type inference
with implicit casts AND make the resulting algorithm efficient enough for daily use.
As far as I know, Scala was the first widely known language to figure out how to combine
these two things! Its creator, Martin Odersky did a lot of work on combining type inference
and subtyping to make this possible.

So for any ML-family language designed before Scala, it is safe to assume that implicit
conversions just was not an option. Okay, but what about Guida?! It comes after Scala, so why
not do it like them?!

1. You pay performance cost to mix type inference and implicit conversions. At least as far
   as anyone knows, it defeats an optimization that is crucial to getting _reliably_ good
   performance. It is fine in most cases, but it can be a real issue in very large code bases.
2. Based on experience reports from Scala users, it seemed like the convenience was not worth
   the hidden cost. Yes, you can convert `n` in `(n + 1.5)` and everything is nice, but when you
   are in larger programs that are sparsely annotated, it can be quite difficult to figure out
   what is going on.

This user data may be confounded by the fact that Scala allows quite extensive conversions,
not just from `Int` to `Float`, but I think it is worth taking seriously nonetheless.
So it is _possible_, but it has tradeoffs.

## Conclusion

First, based on the landscape of design possibilities, it seems like requiring _explicit_
conversions is a pretty nice balance. We can have type inference, it can produce friendly
error messages, the algorithm is snappy, and an unintended implicit cast will not flow
hundreds of lines before manifesting to the user.

Second, Guida very much favors explicit code, so this also fits in with the overall spirit
of the language and libraries.

I hope that clarifies why you have to add those `toFloat` and `round` functions! It definitely
can take some getting used to, but there are tons of folks who get past that acclimation
period and really love the tradeoffs!

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/implicit-casts.md>
"""

        Route.ImportCycles ->
            markdownRender """
# Import Cycles

What is an import cycle? In practice you may see it if you create two modules with
interrelated `User` and `Comment` types like this:

```guida
module Comment exposing (..)

import User

type alias Comment =
  { comment : String
  , author : User.User
  }
```

```guida
module User exposing (..)

import Comment

type alias User =
  { name : String
  , comments : List Comment.Comment
  }
```

Notice that to compile `Comment` we need to `import User`. And notice that to compile `User`
we need to `import Comment`. We need both to compile either!

Now this is *possible* if the compiler figures out any module cycles and puts them all
in one big file to compile them together. That seems fine in our small example, but imagine we
have a cycle of 20 modules. If you change *one* of them, you must now recompile *all* of
them. In a large code base, this causes extremely long compile times. It is also very hard
to disentangle them in practice, so you just end up with slow builds. That is your life now.

The thing is that you can always write the code *without* cycles by shuffling declarations
around, and the resulting code is often much clearer.

## How to Break Cycles

There are quite a few ways to break our `Comment` and `User` cycle from above, so let's go
through four useful strategies. The first one is by far the most common solution!

### 1. Combine the Modules

One approach is to just combine the two modules. If we check out the resulting code,
we have actually revealed a problem in how we are representing our data:

```guida
module BadCombination1 exposing (..)

type alias Comment =
  { comment : String
  , author : User
  }

type alias User =
  { name : String
  , comments : List Comment
  }
```

Notice that the `Comment` type alias is defined in terms of the `User` type alias and vice versa.
Having recursive type aliases like this does not work! That problem is described in depth
[here](/docs/1.0.0/hints/recursive-alias), but the quick takeaway is that one `type alias`
needs to become a `type` to break the recursion. So let's try again:

```guida
module BadCombination2 exposing (..)

type alias Comment =
  { comment : String
  , author : User
  }

type alias User =
  { name : String
  , comments : AllUserComments
  }

type AllUserComments = AllUserComments (List Comment)
```

Okay, now we have broken the recursion, but we need to ask ourselves, how are we going to actually
instantiate these `Comment` and `User` types that we have described. A `Comment` will always
have an author, and that `User` will always refer back to the `Comment`. So we seem to want
cyclic data here. If we were in JavaScript we might instantiate all the comments in one pass,
and then go back through and mutate the users to point to all the relevant comments.
In other words, we need *mutation* to create this cyclic data!

All values are immutable in Guida, so we need to use a more functional strategy.
One common approach is to use unique identifiers. Instead of referring directly to "the user object"
we can refer to a user ID:

```guida
module GoodCombination exposing (..)

import Dict

type alias Comment =
  { comment : String
  , author : UserId
  }

type alias UserId = String

type alias AllComments =
  Dict.Dict UserId (List Comment)
```

Now in this world, we do not even have cycles in our types anymore! That means we can actually
break these out into separate modules again:

```guida
module Comment exposing (..)

import Dict
import User

type alias Comment =
  { comment : String
  , author : User.Id
  }

type alias AllComments =
  Dict.Dict User.Id (List Comment)
```

```guida
module User exposing (..)

type alias Id = String
```

So now we are back to the two modules we wanted, but we have data structures that are
going to work much better in a functional language like Guida! **This is the common approach,
and it is what you hope will happen!**

### 2. Make a New Module

Now say there are actually a ton of functions and values in the `Comment` and `User` modules.
Combining them into one does not seem like a good strategy. Instead you can create a *third*
module that just has the shared types and functions. Let's pretend we call that third
module `GoodCombination`. So rather than having `Comment` and `User` depend on each other,
they now both depend on `GoodCombination`. We broke our cycle!

**This strategy is less common.** You generally want to keep the core `type` of a module with
all the functions that act upon it directly, so separating a `type` from everything else is a
bad sign. So maybe there is a `User` module that contains a bunch of helper functions, but you
*use* all those helper functions in a bunch of other modules that interact with users in
various ways. In that scenario, it is still more sophisticated than "just throw the types in a
module together" and hope it turns out alright.

### 3. Use Type Variables

Another way to avoid module cycles is to be more generic in how you represent your data:

```guida
module Comment exposing (..)

type alias Comment author =
  { comment : String
  , author : author
  }
```

```guida
module User exposing (..)

type alias User comment =
  { name : String
  , comments : List comment
  }
```

Notice that `Comment` and `User` no longer need to import each other! Instead, whenever we use
these modules, we need to fill in the type variable. So we may import both `Comment` and `User`
and try to combine them into a `Comment (User (Comment (User ...)))`. Gah, we ran into the
recursive type alias thing again!

So this strategy fails pretty badly with our particular example. The code is more complicated
and it still does not work! So **this strategy is rarely useful**, but when it works, it can
simplify things quite a lot.

### 4. Hiding Implementation Details in Packages

This gets a little bit trickier when you are creating a package like `elm-lang/parser` which is
built around the `Parser` type.

That package has a couple exposed modules: `Parser`, `Parser.LanguageKit`, and `Parser.LowLevel`.
All of these modules want access to the internal details of the `Parser` type, but we do
not want to ever expose those internal details to the *users* of this package. So where should
the `Parser` type live?!

Usually you know which module should expose the type for the best public API. In this case,
it makes sense for it to live in the `Parser` module. The way to manage this is to create
a `Parser.Internal` module with a definition like:

```guida
module Parser.Internal exposing (..)

type Parser a =
  Parser ...
```

Now we can `import Parser.Internal` and use it in any of the modules in our package.
The trick is that we never expose the `Parser.Internal` module to the *users* of our package.
We can see what is inside, but they cannot! Then in the `Parser` module we can say:

```guida
module Parser exposing (..)

import Parser.Internal as Internal

type alias Parser a =
  Internal.Parser a
```

So now folks see a `Parser` type exposed by the `Parser` module, and it is the one that is
used throughout all the modules in the package. Do not screw up your data representation
to avoid this trick! I think we can improve how this appears in documentation, but overall
this is the best way to go.

Now again, this strategy is particularly useful in packages. It is not as worthwhile
in application code.

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/import-cycles.md>
"""

        Route.Imports ->
            markdownRender """
# Imports

When getting started with Guida, it is pretty common to have questions about how the `import`
declarations work exactly. These questions usually arise when you start playing with the `Html`
library so we will focus on that.

## `import`

A Guida file is called a **module**. To access code in other files, you need to `import` it!

So say you want to use the [`div`](https://package.guida-lang.org/packages/guida-lang/stdlib/latest/Html#div)
function from the [`elm/html`](https://package.guida-lang.org/packages/guida-lang/stdlib/latest/Html) package.
The simplest way is to import it like this:

```guida
import Html

main =
  Html.div [] []
```

After saying `import Html` we can refer to anything inside that module as long as it is *qualified*.
This works for:

- **Values** - we can refer to `Html.text`, `Html.h1`, etc.
- **Types** - We can refer to [`Attribute`](https://package.guida-lang.org/packages/guida-lang/stdlib/latest/Html#Attribute)
  as `Html.Attribute`.

So if we add a type annotation to `main` it would look like this:

```guida
import Html

main : Html.Html msg
main =
  Html.div [] []
```

We are referring to the [`Html`](https://package.guida-lang.org/packages/guida-lang/stdlib/latest/Html#Html)
type, using its *qualified* name `Html.Html`. This can feel weird at first, but it starts
feeling natural quite quickly!

> **Note:** Modules do not contain other modules. So the `Html` module *does not* contain
> the `Html.Attributes` module. Those are separate names that happen to have some overlap.
> So if you say `import Html` you *do not* get access to `Html.Attributes.style`.
> You must `import Html.Attributes` module separately.

## `as`

It is best practice to always use *qualified* names, but sometimes module names are so long
that it becomes unwieldy. This is common for the `Html.Attributes` module. We can use the `as`
keyword to help with this:

```guida
import Html
import Html.Attributes as A

main =
  Html.div [ A.style "color" "red" ] [ Html.text "Hello!" ]
```

Saying `import Html.Attributes as A` lets us refer to any value or type in `Html.Attributes`
as long as it is qualified with an `A`. So now we can refer to
[`style`](https://package.guida-lang.org/packages/guida-lang/stdlib/latest/Html-Attributes#style) as `A.style`.

## `exposing`

In quick drafts, maybe you want to use *unqualified* names. You can do that with the `exposing`
keyword like this:

```guida
import Html exposing (..)
import Html.Attributes exposing (style)

main : Html msg
main =
  div [ style "color" "red" ] [ text "Hello!" ]
```

Saying `import Html exposing (..)` means I can refer to any value or type from the `Html` module
without qualification. Notice that I use the `Html` type, the `div` function, and the `text`
function without qualification in the example above.

> **Note:** It seems neat to expose types and values directly, but it can get out of hand.
Say you `import` ten modules `exposing` all of their content. It quickly becomes difficult
to figure out what is going on in your code. "Wait, where is this function from?"
And then trying to sort through all the imports to find it. Point is, use `exposing (..)`
sparingly!

Saying `import Html.Attributes exposing (style)` is a bit more reasonable. It means I can refer
to the `style` function without qualification, but that is it. You are still importing the
`Html.Attributes` module like normal though, so you would say `Html.Attributes.class`
or `Html.Attributes.id` to refer to other values and types from that module.

## `as` and `exposing`

There is one last way to import a module. You can combine `as` and `exposing` to try to
get a nice balance of qualified names:

```guida
import Html exposing (Html, div, text)
import Html.Attributes as A exposing (style)

main : Html msg
main =
  div [ A.class "greeting", style "color" "red" ] [ text "Hello!" ]
```

Notice that I refer to `A.class` which is qualified and `style` which is unqualified.

## Default Imports

We just learned all the variations of the `import` syntax in Guida. You will use some
version of that syntax to `import` any module you ever write.

It would be the best policy to make it so every module in the whole ecosystem works this way.
We thought so in the past at least, but there are some modules that are so commonly used
that the Guida compiler automatically adds the imports to every file.
These default imports include:

```guida
import Basics exposing (..)
import List exposing (List, (::))
import Maybe exposing (Maybe(..))
import Result exposing (Result(..))
import String
import Tuple

import Debug

import Platform exposing (Program)
import Platform.Cmd as Cmd exposing (Cmd)
import Platform.Sub as Sub exposing (Sub)
```

You can think of these imports being at the top of any module you write.

One could argue that `Maybe` is so fundamental to how we handle errors in Guida code that
it is *basically* part of the language. One could also argue that it is extraordinarily
annoying to have to import `Maybe` once you get past your first couple weeks with Guida.
Either way, we know that default imports are not ideal in some sense, so we have tried to keep
the default imports as minimal as possible.

> **Note:** Guida performs dead code elimination, so if you do not use something from a module,
it is not included in the generated code. So if you `import` a module with hundreds of
functions, you do not need to worry about the size of your assets. You will only get what you use!

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/imports.md>
"""

        Route.InfiniteTypes ->
            markdownRender """
# Infinite Types

Infinite types are probably the trickiest kind of bugs to track down. **Writing down type
annotations is usually the fastest way to figure them out.** Let's work through an example
to get a feel for how these errors usually work though!

## Example

A common way to get an infinite type error is very small typos. For example, do you see the
problem in the following code?

```guida
incrementNumbers list =
  List.map incrementNumbers list

incrementNumber n =
  n + 1
```

The issue is that `incrementNumbers` calls itself, not the `incrementNumber` function
defined below. So there is an extra `s` in this program! Let's focus on that:

```guida
incrementNumbers list =
  List.map incrementNumbers list -- BUG extra `s` makes this self-recursive
```

Now the compiler does not know that anything is wrong yet. It just tries to figure out the
types like normal. It knows that `incrementNumbers` is a function. The definition uses
`List.map` so we can deduce that `list : List t1` and the result of this function call should
be some other `List t2`. This also means that `incrementNumbers : List t1 -> List t2`.

The issue is that `List.map` uses `incrementNumbers` on `list`! That means that each element of
`list` (which has type `t1`) must be fed into `incrementNumbers` (which takes `List t1`)

That means that `t1 = List t1`, which is an infinite type! If we start expanding this,
we get `List (List (List (List (List ...))))` out to infinity!

The point is mainly that we are in a confusing situation. The types are confusing.
This explanation is confusing. The compiler is confused. It is a bad time. But luckily,
the more type annotations you add, the better chance there is that you and the compiler
can figure things out! So say we change our definition to:

```guida
incrementNumbers : List Int -> List Int
incrementNumbers list =
  List.map incrementNumbers list -- STILL HAS BUG
```

Now we are going to get a pretty normal type error. Hey, you said that each element in the
`list` is an `Int` but I cannot feed that into a `List Int -> List Int` function!
Something like that.

In summary, the root issue is often some small typo, and the best way out is to start adding
type annotations on everything!

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/infinite-type.md>
"""

        Route.MissingPatterns ->
            markdownRender """
# Missing Patterns

Guida checks to make sure that all possible inputs to a function or `case` are handled.
This gives us the guarantee that no Guida code is ever going to crash because data had
an unexpected shape.

There are a couple of techniques for making this work for you in every scenario.

## The danger of wildcard patterns

A common scenario is that you want to add a tag to a custom type that is used in a bunch
of places. For example, maybe you are working different variations of users in a chat room:

```guida
type User
  = Regular String Int
  | Anonymous

toName : User -> String
toName user =
  case user of
    Regular name _ ->
      name

    _ ->
      "anonymous"
```

Notice the wildcard pattern in `toName`. This will hurt us! Say we add a `Visitor String`
variant to `User` at some point. Now we have a bug that visitor names are reported as `"anonymous"`,
and the compiler cannot help us!

So instead, it is better to explicitly list all possible variants, like this:

```guida
type User
  = Regular String Int
  | Visitor String
  | Anonymous

toName : User -> String
toName user =
  case user of
    Regular name _ ->
      name

    Anonymous ->
      "anonymous"
```

Now the compiler will say "hey, what should `toName` do when it sees a `Visitor`?"
This is a tiny bit of extra work, but it is very worth it!

## I want to go fast!

Imagine that the `User` type appears in 20 or 30 functions across your project. When we add
a `Visitor` variant, the compiler points out all the places that need to be updated.
That is very convenient, but in a big project, maybe you want to get through it extra quickly.

In that case, it can be helpful to use
[`Debug.todo`](https://package.guida-lang.org/packages/guida-lang/stdlib/latest/Debug#todo) to leave some
code incomplete:

```guida
type User
  = Regular String Int
  | Visitor String
  | Anonymous

toName : User -> String
toName user =
  case user of
    Regular name _ ->
      name

    Visitor _ ->
      Debug.todo "give the visitor name"

    Anonymous ->
      "anonymous"

-- and maybe a bunch of other things
```

In this case it is easier to just write the implementation, but the point is that on more
complex functions, you can put things off a bit.

The Guida compiler is actually aware of `Debug.todo` so when it sees it in a `case` like this,
it will crash with a bunch of helpful information. It will tell you:

1. The name of the module that contains the code.
2. The line numbers of the `case` containing the TODO.
3. The particular value that led to this TODO.

From that information you have a pretty good idea of what went wrong and can go fix it.

I tend to use `Debug.todo` as the message when my goal is to go quick because it makes
it easy to go and find all remaining todos in my code before a release.

## A list that definitely is not empty

This can come up from time to time, but Guida **will not** let you write code like this:

```guida
last : List a -> a
last list =
  case list of
    [x] ->
        x

    _ :: rest ->
        last rest
```

This is no good. It does not handle the empty list. There are two ways to handle this.
One is to make the function return a `Maybe` like this:

```guida
last : List a -> Maybe a
last list =
  case list of
    [] ->
        Nothing

    [x] ->
        Just x

    _ :: rest ->
        last rest
```

This is nice because it lets users know that there might be a failure, so they can recover
from it however they want.

The other option is to "unroll the list" one level to ensure that no one can ever provide
an empty list in the first place:

```guida
last : a -> List a -> a
last first rest =
  case rest of
    [] ->
      first

    newFirst :: newRest ->
      last newFirst newRest
```

By demanding the first element of the list as an argument, it becomes impossible to call
this function if you have an empty list!

This "unroll the list" trick is quite useful. I recommend using it directly, not through some
external library. It is nothing special. Just a useful idea!

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/missing-patterns.md>
"""

        Route.Optimize ->
            markdownRender """
# Optimize

When you are serving a website, there are two kinds of optimizations you want to do:

1. **Asset Size** - How can we send as few bits as possible?
2. **Performance** - How can those bits run as quickly as possible?

It turns out that Guida does really well on both! We have
[very small assets](https://elm-lang.org/news/small-assets-without-the-headache) and
[very fast code](https://elm-lang.org/news/blazing-fast-html-round-two) when compared to
the popular alternatives.

Okay, but how do we get those numbers?

## Instructions

Step one is to compile with the `--optimize` flag. This does things like shortening record
field names and unboxing values.

Step two is to call `uglifyjs` with a bunch of special flags. The flags unlock optimizations
that are unreliable in normal JS code, but because Guida does not have side-effects,
they work fine for us!

Putting those together, here is how I would optimize `src/Main.guida` with two terminal commands:

```bash
guida make src/Main.guida --optimize --output=guida.js
uglifyjs guida.js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output guida.min.js
```

After this you will have an `guida.js` and a significantly smaller `guida.min.js` file!

**Note 1:** `uglifyjs` is called twice there. First to `--compress` and second to `--mangle`.
This is necessary! Otherwise `uglifyjs` will ignore our `pure_funcs` flag.

**Note 2:** If the `uglifyjs` command is not available in your terminal, you can run the
command `npm install uglify-js --global` to download it. You probably already have `npm`
from getting `guida repl` working, but if not, it is bundled with [nodejs](https://nodejs.org/).

## Scripts

It is hard to remember all that, so it is probably a good idea to write a script that does it.

I would maybe want to run `./optimize.sh src/Main.guida` and get out `guida.js` and `guida.min.js`,
so on Mac or Linux, I would make a script called `optimize.sh` like this:

```bash
#!/bin/sh

set -e

js="guida.js"
min="guida.min.js"

guida make --optimize --output=$js $@

uglifyjs $js --compress "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe" | uglifyjs --mangle --output $min

echo "Initial size: $(cat $js | wc -c) bytes  ($js)"
echo "Minified size:$(cat $min | wc -c) bytes  ($min)"
echo "Gzipped size: $(cat $min | gzip -c | wc -c) bytes"
```

It also prints out all the asset sizes for you! Your server should be configured to gzip
the assets it sends, so the last line is telling you how many bytes would _actually_ get sent
to the user.

Again, the important commands are `guida` and `uglifyjs` which work on any platform, so it
should not be too tough to do something similar on Windows.

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/optimize.md>
"""

        Route.PortModules ->
            markdownRender """
# Port Modules

The package ecosystem is one of the most important parts of Guida. Right now, our ecosystem
has some compelling benefits:

- There are many obvious default packages that work well.
- Adding dependencies cannot introduce runtime exceptions.
- Patch changes cannot lead to surprise build failures.

These are really important factors if you want to *quickly* create *reliable* applications.
The Guida community thinks this is valuable.

Other communities think that the *number* of packages is a better measure of ecosystem health.
That is a fine metric to use, but it is not the one we use for Guida. We would rather have 50
great packages than 100k packages of wildly varying quality.

## So what about ports?

Imagine you install a new package that claims to support `localStorage`. You get it set up,
working through any compile errors. You run it, but it does not seem to work! After trying to
figure it out for hours, you realize there is some poorly documented `port` to hook up...

Okay, now you need to hook up some JavaScript code. Is that JS file in the Guida package?
Or is it on `npm`? Wait, what version on `npm` though? And is this patch version going
to work as well? Also, how does this file fit into my build process? And assuming we get
through all that, maybe the `port` has the same name as one of the ports in your project.
Or it clashes with a `port` name in another package.

**Suddenly adding dependencies is much more complicated and risky!** An experienced developer
would always check for ports up front, spending a bunch of time manually classifying unacceptable
packages. Most people would not know to do that and learn all the pitfalls through personal
experience, ultimately spending even *more* time than the person who defensively checks
to avoid these issues.

So "ports in packages" would impose an enormous cost on application developers, and in the end,
we would have a less reliable package ecosystem overall.

## Conclusion

Our wager with the Guida package ecosystem is that it is better to get a package *right*
than to get it *right now*. So while we could use "ports in packages" as a way to get twenty
`localStorage` packages of varying quality *right now*, we are choosing not to go that route.
Instead we ask that developers use ports directly in their application code, getting the same
result a different way.

Now this may not be the right choice for your particular project, and that is okay!
We will be expanding our core libraries over time, as explained [here](https://github.com/elm/projects/blob/master/roadmap.md#where-is-the-localstorage-package),
and we hope you will circle back later to see if Guida has grown into a better fit!

If you have more questions about this choice or what it means for your application,
please come ask in the [Guida Discord](https://discord.gg/B6WgPzf5Aa). Folks are friendly
and happy to help out! Chances are that a `port` in your application will work great for
your case once you learn more about how they are meant to be used.

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/port-modules.md>
"""

        Route.RecursiveAlias ->
            markdownRender """
# Recursive Type Aliases

At the root of this issue is the distinction between a `type` and a `type alias`.

## What is a type alias?

When you create a type alias, you are just creating a shorthand to refer to an existing type.
So when you say the following:

```guida
type alias Time = Float

type alias Degree = Float

type alias Weight = Float
```

You have not created any *new* types, you just made some alternate names for `Float`.
You can write down things like this and it'll work fine:

```guida
add : Time -> Degree -> Weight
add time degree =
  time + degree
```

This is kind of a weird way to use type aliases though. The typical usage would be for records,
where you do not want to write out the whole thing every time. Stuff like this:

```guida
type alias Person =
  { name : String
  , age : Int
  , height : Float
  }
```

It is much easier to write down `Person` in a type, and then it will just expand out to
the underlying type when the compiler checks the program.

## Recursive type aliases?

Okay, so let's say you have some type that may contain itself. In Guida, a common example
of this is a comment that might have subcomments:

```guida
type alias Comment =
  { message : String
  , upvotes : Int
  , downvotes : Int
  , responses : List Comment
  }
```

Now remember that type *aliases* are just alternate names for the real type. So to make `Comment`
into a concrete type, the compiler would start expanding it out.

```guida
  { message : String
  , upvotes : Int
  , downvotes : Int
  , responses :
      List
        { message : String
        , upvotes : Int
        , downvotes : Int
        , responses :
            List
              { message : String
              , upvotes : Int
              , downvotes : Int
              , responses : List ...
              }
        }
  }
```

The compiler cannot deal with values like this. It would just keep expanding forever.

## Recursive types!

In cases where you want a recursive type, you need to actually create a brand new type.
This is what the `type` keyword is for. A simple example of this can be seen when defining a
linked list:

```guida
type List
    = Empty
    | Node Int List
```

No matter what, the type of `Node n xs` is going to be `List`. There is no expansion to be done.
This means you can represent recursive structures with types that do not explode into infinity.

So let's return to wanting to represent a `Comment` that may have responses. There are a couple
ways to do this:

### Obvious, but kind of annoying

```guida
type Comment =
   Comment
      { message : String
      , upvotes : Int
      , downvotes : Int
      , responses : List Comment
      }
```

Now let's say you want to register an upvote on a comment:

```guida
upvote : Comment -> Comment
upvote (Comment comment) =
  Comment { comment | upvotes = 1 + comment.upvotes }
```

It is kind of annoying that we now have to unwrap and wrap the record to do anything with it.

### Less obvious, but nicer

```guida
type alias Comment =
  { message : String
  , upvotes : Int
  , downvotes : Int
  , responses : Responses
  }

type Responses = Responses (List Comment)
```

In this world, we introduce the `Responses` type to capture the recursion, but `Comment`
is still an alias for a record. This means the `upvote` function looks nice again:

```guida
upvote : Comment -> Comment
upvote comment =
  { comment | upvotes = 1 + comment.upvotes }
```

So rather than having to unwrap a `Comment` to do *anything* to it, you only have to do
some unwrapping in the cases where you are doing something recursive. In practice, this means
you will do less unwrapping which is nice.

## Mutually recursive type aliases

It is also possible to build type aliases that are *mutually* recursive. That might be
something like this:

```guida
type alias Comment =
  { message : String
  , upvotes : Int
  , downvotes : Int
  , responses : Responses
  }

type alias Responses =
  { sortBy : SortBy
  , responses : List Comment
  }

type SortBy = Time | Score | MostResponses
```

When you try to expand `Comment` you have to expand `Responses` which needs to expand `Comment`
which needs to expand `Responses`, etc.

So this is just a fancy case of a self-recursive type alias. The solution is the same.
Somewhere in that cycle, you need to define an actual `type` to end the infinite expansion.

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/recursive-alias.md>
"""

        Route.Shadowing ->
            markdownRender """
# Shadowing

Variable shadowing is when you define the same variable name twice in an ambiguous way.
Here is a pretty reasonable use of shadowing:

```guida
viewName : Maybe String -> Html msg
viewName name =
  case name of
    Nothing ->
      ...

    Just name ->
      ...
```

I define a `name` with type `Maybe String` and then in that second branch, I define a `name`
that is a `String`. Now that there are two `name` values, it is not 100% obvious which
one you want in that second branch.

Most linters produce warnings on variable shadowing, so Guida makes "best practices" the default.
Just rename the first one to `maybeName` and move on.

This choice is relatively uncommon in programming languages though, so I want to provide the
reasoning behind it.

## The Cost of Shadowing

The code snippet from above is the best case scenario for variable shadowing.
It is pretty clear really. But that is because it is a fake example. It does not even compile.

In a large module that is evolving over time, this is going to cause bugs in a very predictable way.
You will have two definitions, separated by hundreds of lines. For example:

```guida
name : String
name =
  "Tom"

-- hundreds of lines

viewName : String -> Html msg
viewName name =
  ... name ... name ... name ...
```

Okay, so the `viewName` function has an argument `name` and it uses it three times.
Maybe the `viewName` function is 50 lines long in total, so those uses are not totally easy to see.
This is fine so far, but say your colleague comes along five months later and wants to support
first and last names. They refactor the code like this:

```guida
viewName : String -> String -> Html msg
viewName firstName lastName =
  ... name ... name ... name ...
```

The code compiles, but it does not work as intended. They forgot to change all the uses of `name`,
and because it shadows the top-level `name` value, it always shows up as `"Tom"`.
It is a simple mistake, but it is always the last thing I think of.

> Is the data being fetched properly? Let me log all of the JSON requests. Maybe the JSON
> decoders are messed up? Hmm. Maybe someone is transforming the name in a bad way at some point?
> Let me check my `update` code.

Basically, a bunch of time gets wasted on something that could easily be detected by the compiler.
But this bug is rare, right?

## Aggregate Cost

Thinking of a unique and helpful name takes some extra time. Maybe 30 seconds. But it means that:

1. Your code is easier to read and understand later on. So you spend 30 seconds once `O(1)`
   rather than spending 10 seconds each time someone reads that code in the future `O(n)`.
2. The tricky shadowing bug described above is impossible. Say there is a 5% chance that
   any given edit produces a shadowing bug, and that resolving that shadowing bug takes one hour.
   That means the expected time for each edit increases by three minutes.

If you are still skeptical, I encourage you can play around with the number of edits,
time costs, and probabilities here. When shadowing is not allowed, the resulting overhead
for the entire lifetime of the code is the 30 seconds it takes to pick a better name,
so that is what you need to beat!

## Summary

Without shadowing, the code is easier to read and folks spend less time on pointless debugging.
The net outcome is that folks have more time to make something wonderful with Guida!

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/shadowing.md>
"""

        Route.TypeAnnotations ->
            markdownRender """
# Type Annotation Problems

At the root of this kind of issue is always the fact that a type annotation in your code does
not match the corresponding definition. Now that may mean that the type annotation is "wrong"
or it may mean that the definition is "wrong". The compiler cannot figure out your intent,
only that there is some mismatch.

This document is going to outline the various things that can go wrong and show some examples.

## Annotation vs. Definition

The most common issue is with user-defined type variables that are too general.
So lets say you have defined a function like this:

```guida
addPair : (a, a) -> a
addPair (x, y) =
  x + y
```

The issue is that the type annotation is saying "I will accept a tuple containing literally
*anything*" but the definition is using `(+)` which requires things to be numbers.
So the compiler is going to infer that the true type of the definition is this:

```guida
addPair : (number, number) -> number
```

So you will probably see an error saying "I cannot match `a` with `number`" which is
essentially saying, you are trying to provide a type annotation that is **too general**.
You are saying `addPair` accepts anything, but in fact, it can only handle numbers.

In cases like this, you want to go with whatever the compiler inferred. It is good at
figuring this kind of stuff out ;)

## Annotation vs. Itself

It is also possible to have a type annotation that clashes with itself. This is probably more rare,
but someone will run into it eventually. Let's use another version of `addPair` with problems:

```guida
addPair : (Int, Int) -> number
addPair (x, y) =
  x + y
```

In this case the annotation says we should get a `number` out, but because we were specific
about the inputs being `Int`, the output should also be an `Int`.

## Annotation vs. Internal Annotation

A quite tricky case is when an outer type annotation clashes with an inner type annotation.
Here is an example of this:

```guida
filter : (a -> Bool) -> List a -> List a
filter isOkay list =
  let
    keepIfOkay : a -> Maybe a
    keepIfOkay x =
      if isOkay x then Just x else Nothing
  in
    List.filterMap keepIfOkay list
```

This case is very unfortunate because all the type annotations are correct, but there is a detail
of how type inference works right now that **user-defined type variables are not shared
between annotations**. This can lead to probably the worst type error messages we have because
the problem here is that `a` in the outer annotation does not equal `a` in the inner annotation.

For now the best route is to leave off the inner annotation. It is unfortunate,
and hopefully we will be able to do a nicer thing in future releases.

---

## References

- <https://github.com/elm/compiler/blob/0.19.1/hints/type-annotations.md>
"""


sidebarNavigation : Navigation Route.DocumentationSection
sidebarNavigation =
    [ { title = "Overview"
      , links =
            [ { title = "Introduction", href = "/docs", route = Route.Introduction, sections = [] }
            , { title = "What is Guida?", href = "/docs/what-is-guida", route = Route.WhatIsGuida, sections = [] }
            ]
      }
    , { title = "Getting Started"
      , links =
            [ { title = "Installation", href = "/docs/installation", route = Route.Installation, sections = [] }
            , { title = "Your First Program", href = "/docs/your-first-program", route = Route.YourFirstProgram, sections = [] }
            , { title = "Project Setup", href = "/docs/project-setup", route = Route.ProjectSetup, sections = [] }
            , { title = "Migration from Elm", href = "/docs/migration-from-elm", route = Route.MigrationFromElm, sections = [] }
            ]
      }
    , { title = "The Language"
      , links =
            [ { title = "Syntax Overview", href = "/docs/syntax-overview", route = Route.SyntaxOverview, sections = [] }
            , { title = "Values and Types", href = "/docs/values-and-types", route = Route.ValuesAndTypes, sections = [] }
            , { title = "Functions and Expressions", href = "/docs/functions-and-expressions", route = Route.FunctionsAndExpressions, sections = [] }
            , { title = "Modules and Imports", href = "/docs/modules-and-imports", route = Route.ModulesAndImports, sections = [] }
            , { title = "Custom Types", href = "/docs/custom-types", route = Route.CustomTypes, sections = [] }
            , { title = "Pattern Matching", href = "/docs/pattern-matching", route = Route.PatternMatching, sections = [] }
            , { title = "Error Handling", href = "/docs/error-handling", route = Route.ErrorHandling, sections = [] }
            , { title = "guida.json", href = "/docs/guida-json", route = Route.GuidaJson, sections = [] }
            ]
      }
    , { title = "Core Concepts"
      , links =
            [ { title = "Immutability and Purity", href = "/docs/immutability-and-purity", route = Route.ImmutabilityAndPurity, sections = [] }
            , { title = "The Type System", href = "/docs/the-type-system", route = Route.TheTypeSystem, sections = [] }
            , { title = "Concurrency and Effects", href = "/docs/concurrency-and-effects", route = Route.ConcurrencyAndEffects, sections = [] }
            , { title = "State and Architecture", href = "/docs/state-and-architecture", route = Route.StateAndArchitecture, sections = [] }
            ]
      }
    , { title = "Building Applications"
      , links =
            [ { title = "Application Structure", href = "/docs/application-structure", route = Route.ApplicationStructure, sections = [] }
            , { title = "The Guida Architecture", href = "/docs/the-guida-architecture", route = Route.TheGuidaArchitecture, sections = [] }
            , { title = "Routing and Navigation", href = "/docs/routing-and-navigation", route = Route.RoutingAndNavigation, sections = [] }
            , { title = "Interoperability", href = "/docs/interoperability", route = Route.Interoperability, sections = [] }
            ]
      }
    , { title = "Commands"
      , links =
            [ { title = "repl", href = "/docs/1.0.0/commands/repl", route = Route.Commands Route.Repl, sections = [] }
            , { title = "init", href = "/docs/1.0.0/commands/init", route = Route.Commands Route.Init, sections = [] }
            , { title = "make", href = "/docs/1.0.0/commands/make", route = Route.Commands Route.Make, sections = [] }
            , { title = "install", href = "/docs/1.0.0/commands/install", route = Route.Commands Route.Install, sections = [] }
            , { title = "uninstall", href = "/docs/1.0.0/commands/uninstall", route = Route.Commands Route.Uninstall, sections = [] }
            , { title = "bump", href = "/docs/1.0.0/commands/bump", route = Route.Commands Route.Bump, sections = [] }
            , { title = "diff", href = "/docs/1.0.0/commands/diff", route = Route.Commands Route.Diff, sections = [] }
            , { title = "publish", href = "/docs/1.0.0/commands/publish", route = Route.Commands Route.Publish, sections = [] }
            , { title = "format", href = "/docs/1.0.0/commands/format", route = Route.Commands Route.Format, sections = [] }
            , { title = "test", href = "/docs/1.0.0/commands/test", route = Route.Commands Route.Test, sections = [] }
            ]
      }
    , { title = "Contributing"
      , links =
            [ { title = "Getting Started", href = "/docs/contributing/getting-started", route = Route.ContributingGettingStarted, sections = [] }
            , { title = "Ways to Contribute", href = "/docs/contributing/ways-to-contribute", route = Route.ContributingWaysToContribute, sections = [] }
            , { title = "Development Workflow", href = "/docs/contributing/development-workflow", route = Route.ContributingDevelopmentWorkflow, sections = [] }
            , { title = "Reporting Issues", href = "/docs/contributing/reporting-issues", route = Route.ContributingReportingIssues, sections = [] }
            , { title = "Join the Community", href = "/docs/contributing/join-the-community", route = Route.ContributingJoinTheCommunity, sections = [] }
            ]
      }
    , { title = "Advanced Topics"
      , links =
            [ { title = "Bad Recursion", href = "/docs/1.0.0/hints/bad-recursion", route = Route.Hints Route.BadRecursion, sections = [] }
            , { title = "Comparing Custom Types", href = "/docs/1.0.0/hints/comparing-custom-types", route = Route.Hints Route.ComparingCustomTypes, sections = [] }
            , { title = "Comparing Records", href = "/docs/1.0.0/hints/comparing-records", route = Route.Hints Route.ComparingRecords, sections = [] }
            , { title = "Implicit Casts", href = "/docs/1.0.0/hints/implicit-casts", route = Route.Hints Route.ImplicitCasts, sections = [] }
            , { title = "Import Cycles", href = "/docs/1.0.0/hints/import-cycles", route = Route.Hints Route.ImportCycles, sections = [] }
            , { title = "Imports", href = "/docs/1.0.0/hints/imports", route = Route.Hints Route.Imports, sections = [] }
            , { title = "Infinite Types", href = "/docs/1.0.0/hints/infinite-types", route = Route.Hints Route.InfiniteTypes, sections = [] }
            , { title = "Missing Patterns", href = "/docs/1.0.0/hints/missing-patterns", route = Route.Hints Route.MissingPatterns, sections = [] }
            , { title = "Optimize", href = "/docs/1.0.0/hints/optimize", route = Route.Hints Route.Optimize, sections = [] }
            , { title = "Port Modules", href = "/docs/1.0.0/hints/port-modules", route = Route.Hints Route.PortModules, sections = [] }
            , { title = "Recursive Type Aliases", href = "/docs/1.0.0/hints/recursive-alias", route = Route.Hints Route.RecursiveAlias, sections = [] }
            , { title = "Shadowing", href = "/docs/1.0.0/hints/shadowing", route = Route.Hints Route.Shadowing, sections = [] }
            , { title = "Type Annotation Problems", href = "/docs/1.0.0/hints/type-annotations", route = Route.Hints Route.TypeAnnotations, sections = [] }
            ]
      }
    ]
