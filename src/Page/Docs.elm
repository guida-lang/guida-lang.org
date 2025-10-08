module Page.Docs exposing
    ( Model
    , init
    , view
    )

import Browser
import Components.Button as Button exposing (Type(..))
import Components.CodeBlock as CodeBlock
import Components.Properties as Properties
import Components.References as References
import Html exposing (Html)
import Html.Attributes as Attr
import Layout.Main as Layout
import Layout.Navigation exposing (Navigation)
import Route
import Session exposing (Session)



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
        Layout.view { sidebarNavigation = sidebarNavigation model } session toSessionMsg <|
            case model.section of
                Route.Introduction ->
                    []

                Route.Elm ->
                    []

                Route.GuidaJson ->
                    [ Html.h1 [] [ Html.text "guida.json" ]
                    , Html.p []
                        [ Html.text "The "
                        , Html.code [] [ Html.text "guida.json" ]
                        , Html.text " describes your project."
                        ]
                    , Html.p [] [ Html.text "There are two different types of project: applications and packages." ]
                    , Html.p []
                        [ Html.text "Depending on the type of project, the "
                        , Html.code [] [ Html.text "guida.json" ]
                        , Html.text " looks slightly different."
                        ]
                    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Application" ]
                    , Html.p []
                        [ Html.text "When running "
                        , Html.code [] [ Html.text "guida init" ]
                        , Html.text " a "
                        , Html.code [] [ Html.text "guida.json" ]
                        , Html.text " file is generated with the following content:"
                        ]
                    , CodeBlock.view """{
    "type": "application",
    "source-directories": [
        "src"
    ],
    "guida-version": "1.0.0",
    "dependencies": {
        "direct": {
            "elm/browser": "1.0.2",
            "elm/core": "1.0.5",
            "elm/html": "1.0.0"
        },
        "indirect": {
            "elm/json": "1.1.4",
            "elm/time": "1.0.0",
            "elm/url": "1.0.0",
            "elm/virtual-dom": "1.0.4"
        }
    },
    "test-dependencies": {
        "direct": {
            "elm-explorations/test": "2.2.0"
        },
        "indirect": {
            "elm/bytes": "1.0.8",
            "elm/random": "1.0.0"
        }
    }
}"""
                    , Properties.view
                        [ { name = "\"type\""
                          , type_ = Nothing
                          , children =
                                [ Html.text "Either "
                                , Html.code [] [ Html.text "\"application\"" ]
                                , Html.text " or "
                                , Html.code [] [ Html.text "\"package\"" ]
                                , Html.text ". All the other fields are based on this choice!"
                                ]
                          }
                        , { name = "\"source-directories\""
                          , type_ = Nothing
                          , children =
                                [ Html.text "A list of directories where Guida code lives. Most projects just use "
                                , Html.code [] [ Html.text "\"src\"" ]
                                , Html.text " for everything."
                                ]
                          }
                        , { name = "\"guida-version\""
                          , type_ = Nothing
                          , children =
                                [ Html.text "The exact version of Guida this builds with. Should be "
                                , Html.code [] [ Html.text "\"1.0.0\"" ]
                                , Html.text " for most people!"
                                ]
                          }
                        , { name = "\"dependencies\""
                          , type_ = Nothing
                          , children =
                                [ Html.text "All the packages you depend upon. We use exact versions, so your "
                                , Html.code [] [ Html.text "guida.json" ]
                                , Html.text " file doubles as a \"lock file\" that ensures reliable builds."
                                , Html.br [] []
                                , Html.text "You can use modules from any `\"direct\"` dependency in your code. Some `\"direct\"` dependencies have their own dependencies that folks typically do not care about. These are the `\"indirect\"` dependencies. They are listed explicitly so that (1) builds are reproducible and (2) you can easily review the quantity and quality of dependencies."
                                , Html.br [] []
                                , Html.text "**Note:** We plan to eventually have a screen in `reactor` that helps add, remove, and upgrade packages. It can sometimes be tricky to keep all of the constraints happy, so we think having a UI will help a lot. If you get into trouble in the meantime, adding things back one-by-one often helps, and I hope you do not get into trouble!"
                                ]
                          }
                        , { name = "\"test-dependencies\""
                          , type_ = Nothing
                          , children =
                                [ Html.text "All the packages that you use in `tests/` with `guida test` but not in the application you actually want to ship. This also uses exact versions to make tests more reliable."
                                ]
                          }
                        ]
                    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Package" ]
                    , Html.p []
                        [ Html.text "When running "
                        , Html.code [] [ Html.text "guida init --package" ]
                        , Html.text " a "
                        , Html.code [] [ Html.text "guida.json" ]
                        , Html.text " file is generated with the following content:"
                        ]
                    , CodeBlock.view """{
    "type": "package",
    "name": "author/project",
    "summary": "helpful summary of your project, less than 80 characters",
    "license": "BSD-3-Clause",
    "version": "1.0.0",
    "exposed-modules": [],
    "guida-version": "1.0.0 <= v < 2.0.0",
    "dependencies": {
        "elm/core": "1.0.5 <= v < 2.0.0"
    },
    "test-dependencies": {
        "elm-explorations/test": "2.2.0 <= v < 3.0.0"
    }
}"""
                    , References.view
                        [ "https://github.com/elm/compiler/blob/0.19.1/docs/elm.json/application.md"
                        , "https://github.com/elm/compiler/blob/0.19.1/docs/elm.json/package.md"
                        , "https://gren-lang.org/book/appendix/gren_json/"
                        ]
                    ]

                Route.Commands command ->
                    commandView command

                Route.Hints hint ->
                    hintView hint
    }


commandView : Route.Command -> List (Html msg)
commandView command =
    case command of
        Route.Repl ->
            [ Html.h1 [] [ Html.text "guida repl" ]
            , Html.p [] [ Html.text "The REPL lets you interact with Guida values and functions in your terminal." ]
            , Html.p [] [ Html.text "You can type in expressions, definitions, custom types, and module imports using normal Guida syntax." ]
            , CodeBlock.view """> 1 + 1
2 : number

> "hello" ++ "world"
"helloworld" : String"""
            , Html.p [] [ Html.text "The same can be done with definitions and custom types:" ]
            , CodeBlock.view """> fortyTwo = 42
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
"Hey again!" : String"""
            , Html.p []
                [ Html.text "When you run "
                , Html.code [] [ Html.text "guida repl" ]
                , Html.text " in a project with an "
                , Button.view (Button.Link "/docs/guida-json") Button.Text Nothing [] [ Html.text "guida.json" ]
                , Html.text " file, you can import any module available in the project. So if your project has an "
                , Html.code [] [ Html.text "elm/html" ]
                , Html.text " dependency, you could say:"
                ]
            , CodeBlock.view """> import Html exposing (Html)

> Html.text "hello"
<internals> : Html msg

> Html.text
<function> : String -> Html msg"""
            , Html.p []
                [ Html.text "If you create a module in your project named "
                , Html.code [] [ Html.text "MyThing" ]
                , Html.text " in your project, you can say "
                , Html.code [] [ Html.text "import MyThing" ]
                , Html.text " in the REPL as well. Any module that is accessible in your project should be accessible in the REPL."
                ]
            , Html.hr [] []
            , Html.h2 [ Attr.class "scroll-mt-24" ] [ Html.text "Exit" ]
            , Html.p []
                [ Html.text "To exit the REPL, you can type "
                , Html.code [] [ Html.text ":exit" ]
                , Html.text "."
                ]
            , Html.p []
                [ Html.text "You can also press "
                , Html.code [] [ Html.text "ctrl-d" ]
                , Html.text " or "
                , Html.code [] [ Html.text "ctrl-c" ]
                , Html.text " on some platforms."
                ]
            , Html.hr [] []
            , Html.h2 [ Attr.class "scroll-mt-24" ] [ Html.text "Flags" ]
            , Html.p [] [ Html.text "You can customize this command with the following flags:" ]
            , Properties.view
                [ { name = "--interpreter=<interpreter>"
                  , type_ = Nothing
                  , children = [ Html.text "Path to a alternate JS interpreter, like node or nodejs." ]
                  }
                , { name = "--no-colors"
                  , type_ = Nothing
                  , children = [ Html.text "Turn off the colors in the REPL. This can help if you are having trouble reading the values. Some terminals use a custom color scheme that diverges significantly from the standard ANSI colors, so another path may be to pick a more standard color scheme." ]
                  }
                ]
            , References.view
                [ "https://github.com/elm/compiler/blob/0.19.1/hints/repl.md"
                ]
            ]

        Route.Init ->
            [ Html.h1 [] [ Html.text "guida init" ]
            ]

        Route.Make ->
            [ Html.h1 [] [ Html.text "guida make" ]
            ]

        Route.Install ->
            [ Html.h1 [] [ Html.text "guida install" ]
            ]

        Route.Uninstall ->
            [ Html.h1 [] [ Html.text "guida uninstall" ]
            ]

        Route.Bump ->
            [ Html.h1 [] [ Html.text "guida bump" ]
            ]

        Route.Diff ->
            [ Html.h1 [] [ Html.text "guida diff" ]
            ]

        Route.Publish ->
            [ Html.h1 [] [ Html.text "guida publish" ]
            ]

        Route.Format ->
            [ Html.h1 [] [ Html.text "guida format" ]
            ]

        Route.Test ->
            [ Html.h1 [] [ Html.text "guida test" ]
            ]


hintView : Route.Hint -> List (Html msg)
hintView hint =
    case hint of
        _ ->
            []


sidebarNavigation : Model -> Navigation
sidebarNavigation model =
    let
        activeCommand cmd =
            model.section == Route.Commands cmd

        activeHint hint =
            model.section == Route.Hints hint
    in
    [ { title = "Guide"
      , links =
            [ { title = "Introduction", href = "/docs", active = model.section == Route.Introduction }
            , { title = "Elm", href = "/docs/elm", active = model.section == Route.Elm }
            , { title = "guida.json", href = "/docs/guida-json", active = model.section == Route.GuidaJson }
            ]
      }
    , { title = "Commands"
      , links =
            [ { title = "repl", href = "/docs/1.0.0/commands/repl", active = activeCommand Route.Repl }
            , { title = "init", href = "/docs/1.0.0/commands/init", active = activeCommand Route.Init }
            , { title = "make", href = "/docs/1.0.0/commands/make", active = activeCommand Route.Make }
            , { title = "install", href = "/docs/1.0.0/commands/install", active = activeCommand Route.Install }
            , { title = "uninstall", href = "/docs/1.0.0/commands/uninstall", active = activeCommand Route.Uninstall }
            , { title = "bump", href = "/docs/1.0.0/commands/bump", active = activeCommand Route.Bump }
            , { title = "diff", href = "/docs/1.0.0/commands/diff", active = activeCommand Route.Diff }
            , { title = "publish", href = "/docs/1.0.0/commands/publish", active = activeCommand Route.Publish }
            , { title = "format", href = "/docs/1.0.0/commands/format", active = activeCommand Route.Format }
            , { title = "test", href = "/docs/1.0.0/commands/test", active = activeCommand Route.Test }
            ]
      }
    , { title = "Hints"
      , links =
            [ { title = "Bad recursion", href = "/docs/1.0.0/hints/bad-recursion", active = activeHint Route.BadRecursion }
            , { title = "Comparing custom types", href = "/docs/1.0.0/hints/comparing-custom-types", active = activeHint Route.ComparingCustomTypes }
            , { title = "Comparing records", href = "/docs/1.0.0/hints/comparing-records", active = activeHint Route.ComparingRecords }
            , { title = "Implicit casts", href = "/docs/1.0.0/hints/implicit-casts", active = activeHint Route.ImplicitCasts }
            , { title = "Import cycles", href = "/docs/1.0.0/hints/import-cycles", active = activeHint Route.ImportCycles }
            , { title = "Imports", href = "/docs/1.0.0/hints/imports", active = activeHint Route.Imports }
            , { title = "Infinite type", href = "/docs/1.0.0/hints/infinite-type", active = activeHint Route.InfiniteType }
            , { title = "Missing patterns", href = "/docs/1.0.0/hints/missing-patterns", active = activeHint Route.MissingPatterns }
            , { title = "Optimize", href = "/docs/1.0.0/hints/optimize", active = activeHint Route.Optimize }
            , { title = "Port modules", href = "/docs/1.0.0/hints/port-modules", active = activeHint Route.PortModules }
            , { title = "Recursive alias", href = "/docs/1.0.0/hints/recursive-alias", active = activeHint Route.RecursiveAlias }
            , { title = "Shadowing", href = "/docs/1.0.0/hints/shadowing", active = activeHint Route.Shadowing }
            , { title = "Tuples", href = "/docs/1.0.0/hints/tuples", active = activeHint Route.Tuples }
            , { title = "Type annotations", href = "/docs/1.0.0/hints/type-annotations", active = activeHint Route.TypeAnnotations }
            ]
      }
    ]
