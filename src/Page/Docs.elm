module Page.Docs exposing (view)

import Browser
import Html
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Layout.Main as Layout
import Layout.Navigation exposing (Navigation)
import Session exposing (Session)


sidebarNavigation : Navigation
sidebarNavigation =
    [ { title = "Commands"
      , links =
            [ { title = "repl", href = "/docs/1.0.0/commands/repl", active = False }
            , { title = "init", href = "/docs/1.0.0/commands/init", active = True }
            , { title = "make", href = "/docs/1.0.0/commands/make", active = False }
            , { title = "install", href = "/docs/1.0.0/commands/install", active = False }
            , { title = "uninstall", href = "/docs/1.0.0/commands/uninstall", active = False }
            , { title = "bump", href = "/docs/1.0.0/commands/bump", active = False }
            , { title = "diff", href = "/docs/1.0.0/commands/diff", active = False }
            , { title = "publish", href = "/docs/1.0.0/commands/publish", active = False }
            , { title = "format", href = "/docs/1.0.0/commands/format", active = False }
            , { title = "test", href = "/docs/1.0.0/commands/test", active = False }
            ]
      }
    , { title = "Hints"
      , links =
            [ { title = "Bad recursion", href = "/docs/1.0.0/hints/bad-recursion", active = False }
            , { title = "Comparing custom types", href = "/docs/1.0.0/hints/comparing-custom-types", active = False }
            , { title = "Comparing records", href = "/docs/1.0.0/hints/comparing-records", active = False }
            , { title = "Implicit casts", href = "/docs/1.0.0/hints/implicit-casts", active = False }
            , { title = "Import cycles", href = "/docs/1.0.0/hints/import-cycles", active = False }
            , { title = "Imports", href = "/docs/1.0.0/hints/imports", active = False }
            , { title = "Infinite type", href = "/docs/1.0.0/hints/infinite-type", active = False }
            , { title = "Missing patterns", href = "/docs/1.0.0/hints/missing-patterns", active = False }
            , { title = "Optimize", href = "/docs/1.0.0/hints/optimize", active = False }
            , { title = "Port modules", href = "/docs/1.0.0/hints/port-modules", active = False }
            , { title = "Recursive alias", href = "/docs/1.0.0/hints/recursive-alias", active = False }
            , { title = "Shadowing", href = "/docs/1.0.0/hints/shadowing", active = False }
            , { title = "Tuples", href = "/docs/1.0.0/hints/tuples", active = False }
            , { title = "Type annotations", href = "/docs/1.0.0/hints/type-annotations", active = False }
            ]
      }
    ]



-- VIEW


view : Session -> (Session.Msg -> msg) -> Browser.Document msg
view session toSessionMsg =
    { title = "Guida: Documentation"
    , body =
        Layout.view { sidebarNavigation = sidebarNavigation } session toSessionMsg <|
            [ Html.section []
                [ Html.h2 [] [ Html.text "Documentation" ]
                , Html.h3 [] [ Html.text "Guida REPL" ]
                , Html.p [] [ Html.text "The `repl` command opens up an interactive programming session, sometimes called a **Read-Eval-Print Loop**." ]
                , Html.p [] [ Html.text "It lets you try out Guida expressions, explore functions, and learn the language in a quick and interactive way." ]
                , Html.code [] [ Html.text "guida repl" ]
                , Html.p [] [ Html.text "Once inside the REPL, you can type in Guida expressions and immediately see the results:" ]
                , Html.code []
                    [ Html.text "> 1 + 2"
                    , Html.text "3"
                    , Html.text "> String.toUpper \"hello\""
                    , Html.text "\"HELLO\""
                    , Html.text "> List.map (\\n -> n * 2) [1, 2, 3]"
                    , Html.text "[2,4,6]"
                    ]
                ]
            ]
    }



-- # Guida REPL
-- The `repl` command opens up an interactive programming session, sometimes called a **Read-Eval-Print Loop**.
-- It lets you try out Guida expressions, explore functions, and learn the language in a quick and interactive way.
-- ```bash
-- guida repl
-- ````
-- Once inside the REPL, you can type in Guida expressions and immediately see the results:
-- ```elm
-- > 1 + 2
-- 3
-- > String.toUpper "hello"
-- "HELLO"
-- > List.map (\n -> n * 2) [1, 2, 3]
-- [2,4,6]
-- ```
-- ---
-- ## Learning with the REPL
-- A great way to get started with Guida is by experimenting in the REPL.
-- Follow along with the [official Guida Guide](https://guida-lang.org/docs) — it includes examples and exercises that you can try directly in the REPL.
-- Exploring small snippets of code interactively can be much faster than editing a file, compiling, and running a project.
-- ---
-- ## Customizing the REPL
-- You can configure how the REPL runs using these flags:
-- ### `--interpreter=<interpreter>`
-- Specify an alternate JavaScript runtime to evaluate Guida code.
-- By default, Guida uses your system’s `node` installation, but you may override it:
-- ```bash
-- guida repl --interpreter=nodejs
-- ```
-- This can be useful if your system differentiates between `node` and `nodejs` binaries, or if you want to run Guida with a custom JS runtime.
-- ---
-- ### `--no-colors`
-- Disable ANSI colors in the REPL output:
-- ```bash
-- guida repl --no-colors
-- ```
-- This can help if your terminal’s color scheme makes output hard to read, or if you prefer plain text.
-- ---
-- ## Example Session
-- Here’s a quick demonstration:
-- ```bash
-- $ guida repl
-- ----
-- Guida REPL 0.19.1
-- Type :help for available commands. Press Ctrl+D to exit.
-- > 5 * 5
-- 25
-- > (\\x -> x + 1) 41
-- 42
-- > String.length "Guida"
-- 5
-- ```
-- ---
-- ## Tips
-- * Use the REPL for **experimentation and learning** — it’s not meant to replace writing modules and building projects.
-- * REPL does not persist your definitions between sessions. If you discover something useful, copy it into a `.guida` file in your project.
-- * Use `:exit` or press `Ctrl+D` to quit.
-- ---
-- ## Related Topics
-- * [Getting Started with Guida](https://guida-lang.org/docs/getting-started)
-- * [Guida Guide](https://guida-lang.org/docs)
-- * [Community](https://guida-lang.org/community)
