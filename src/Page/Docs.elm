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

Then import it in your JavaScript or TypeScript code:

```js
// Node.js (CommonJS)
const guida = require('guida');

// or ES Modules
import guida from 'guida';

// Example: compile a file or run commands programmatically
guida.compile('src/Main.elm', { debug: true });
```

The same package entry can be imported in **browser environments**, where Guida runs entirely in JavaScript/WebAssembly.

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

> Guida follows the same project structure as Elm 0.19.1 — so existing Elm projects will work here too.

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

```js
import * as guida from "guida";

const source = `
module Main exposing (main)
import Html exposing (text)
main = text "Hello, from Node!"
`;

const output = await guida.compile(source);
console.log(output);
```

### Browser Example

If you include Guida via an ES module or a bundler:

```js
import * as guida from "guida";

const result = await guida.compile(sourceCode);
document.body.innerHTML = result.html;
```

This makes Guida useful not only as a CLI tool but also as a **programmable compiler** that can power editors, online sandboxes, and development tools.
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
  "elm-version": "1.0.0",
  "dependencies": {
    "direct": {
      "guida-lang/stdlib": "1.0.0"
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
module Main exposing (main)
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

This is useful when embedding Guida programs in other environments.

## Local Packages and Custom Registries

Guida supports **local registries**, allowing you to host your own package server for internal development.

To point Guida to a local or custom registry, configure your environment or command-line flags.
(Feature tracked in [compiler issue #74](https://github.com/guida-lang/compiler/issues/74))

> 💡 If you're using the [`guida-lang/package-registry`](https://github.com/guida-lang/package-registry), it will automatically cache Elm packages and serve them locally via `localhost:3000`.

## Project Commands Summary

| Command        | Description                              |
| -------------- | ---------------------------------------- |
| `guida init`   | Create a new project scaffold            |
| `guida make`   | Compile source files to HTML or JS       |
| `guida repl`   | Start an interactive REPL (if available) |
| `guida format` | Format source files                      |
| `guida test`   | Run project tests                        |
"""

                Route.MigrationFromElm ->
                    markdownRender """
# Migration from Elm

Guida is designed to be **fully backward compatible** with **Elm 0.19.1**.  
If you already have an existing Elm project, the goal is that you can start using Guida with **zero code changes**.

## Why Migration Matters

Elm has a strong foundation — Guida builds on that same foundation while expanding the ecosystem, tooling, and long-term maintainability.  

Guida's first priority is to give teams the confidence that **existing Elm projects continue to work exactly as before**, while opening the door to future improvements and a self-hosted compiler environment.

Think of it like this:

> 🧭 **Guida is to Elm what TypeScript is to JavaScript** — a natural evolution, not a fork in a different direction.

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

## Compatibility Notes

* **Elm 0.19.1 Compatibility:** Guida currently targets full behavioral compatibility with Elm 0.19.1, including its syntax, compiler rules, and even certain edge cases.
* **No Code Changes Required:** Your existing `elm.json`, imports, and module structure remain valid.
* **Dependencies:** Guida uses the same package ecosystem as Elm but can also connect to a **custom registry**, allowing private or local package development.

> 💡 If you use a local registry such as [`guida-lang/package-registry`](https://github.com/guida-lang/package-registry), you can mirror all Elm packages locally and work offline.

## Optional Adjustments

While not required, you can make small improvements once you're comfortable with Guida:

* Update `elm.json` dependencies to the latest compatible versions.
* Try compiling with Guida's experimental options as new versions evolve.
* Report any inconsistencies between Elm and Guida on the [issue tracker](https://github.com/guida-lang/compiler/issues).

## Future Evolution

Over time, Guida will introduce **new language features** and **developer tools** while maintaining migration paths for existing Elm code.

These may include:

* Improved compiler performance (including WebAssembly builds)
* Self-hosted compilation (written in Guida itself)
* Extended tooling (tests, formatter, linter, etc.)

The long-term goal is that you can migrate at your own pace — keeping the reliability of Elm while benefiting from Guida's progress.
"""

                Route.SyntaxOverview ->
                    markdownRender """
# Syntax Overview

<todo />
"""

                Route.ValuesAndTypes ->
                    markdownRender """
# Values and Types

<todo />
"""

                Route.FunctionsAndExpressions ->
                    markdownRender """
# Functions and Expressions

<todo />
"""

                Route.ModulesAndImports ->
                    markdownRender """
# Modules and Imports

<todo />
"""

                Route.CustomTypes ->
                    markdownRender """
# Custom Types

<todo />
"""

                Route.PatternMatching ->
                    markdownRender """
# Pattern Matching

<todo />
"""

                Route.ErrorHandling ->
                    markdownRender """
# Error Handling

<todo />
"""

                Route.ImmutabilityAndPurity ->
                    markdownRender """
# Immutability and Purity

<todo />
"""

                Route.TheTypeSystem ->
                    markdownRender """
# The Type System

<todo />
"""

                Route.ConcurrencyAndEffects ->
                    markdownRender """
# Concurrency and Effects

<todo />
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

When you run `guida repl` in a project with a [/docs/guida-json](guida.json) file, you can
import any module available in the project. So if your project has an `elm/html` dependency,
you could say:

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
about particular students, you can start using the [`Html.Lazy`](https://package.elm-lang.org/packages/elm/html/latest/Html-Lazy)
and [`Html.Keyed`](https://package.elm-lang.org/packages/elm/html/latest/Html-Keyed) modules.
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

So say you want to use the [`div`](htthttps://package.elm-lang.org/packages/elm/html/latest/Html#div)
function from the [`elm/html`](http://package.elm-lang.org/packages/elm/html/latest) package.
The simplest way is to import it like this:

```guida
import Html

main =
  Html.div [] []
```

After saying `import Html` we can refer to anything inside that module as long as it is *qualified*.
This works for:

- **Values** - we can refer to `Html.text`, `Html.h1`, etc.
- **Types** - We can refer to [`Attribute`](http://package.elm-lang.org/packages/elm/html/latest/Html#Attribute)
  as `Html.Attribute`.

So if we add a type annotation to `main` it would look like this:

```guida
import Html

main : Html.Html msg
main =
  Html.div [] []
```

We are referring to the [`Html`](http://package.elm-lang.org/packages/elm/html/latest/Html#Html)
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
[`style`](http://package.elm-lang.org/packages/elm/html/latest/Html-Attributes#style) as `A.style`.

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
[`Debug.todo`](https://package.elm-lang.org/packages/elm/core/latest/Debug#todo) to leave some
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

```elm
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
