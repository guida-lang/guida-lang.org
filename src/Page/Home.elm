module Page.Home exposing (view)

import Browser
import Components.Button as Button
import Components.HeroPattern as HeroPattern
import Html
import Html.Attributes as Attr
import Layout.Main as Layout
import Session exposing (Session)



-- VIEW


view : Session -> (Session.Msg -> msg) -> Browser.Document msg
view session toSessionMsg =
    { title = "Guida: Home"
    , body =
        Layout.view { sidebarNavigation = [], currentRoute = () } session toSessionMsg <|
            [ HeroPattern.view
            , Html.h1 [] [ Html.text "What is Guida?" ]
            , Html.p [ Attr.class "lead" ]
                [ Html.text "Guida is a functional programming language that builds upon the solid foundation of "
                , Html.a [ Attr.href "https://elm-lang.org" ] [ Html.text "Elm" ]
                , Html.text ", offering backward compatibility with all existing "
                , Html.a [ Attr.href "https://github.com/elm/compiler/releases/tag/0.19.1" ] [ Html.text "Elm 0.19.1" ]
                , Html.text " projects."
                ]
            , Html.div [ Attr.class "not-prose mt-6 mb-16 flex gap-3" ]
                [ Button.view (Button.Link "/try") Button.Primary Nothing [] <|
                    [ Html.text "Try" ]
                , Button.view (Button.Link "/docs") Button.Outline (Just Button.RightArrow) [] <|
                    [ Html.text "Documentation" ]
                ]
            , Html.h2 [] [ Html.text "Vision" ]
            , Html.p []
                [ Html.text "Guida builds on the foundations of Elm, aiming to advance the future of functional programming. By translating Elm's compiler from Haskell to a self-hosted environment, Guida helps developers to build reliable, maintainable, and performant applications without leaving the language they love."
                ]
            , Html.p []
                [ Html.strong [] [ Html.text "Continuity and Confidence (Version 0.x):" ]
                , Html.text " Guida starts by ensuring full backward compatibility with Elm v0.19.1, allowing developers to migrate effortlessly and explore Guida with complete confidence."
                ]
            , Html.p []
                [ Html.text "This commitment to continuity means that this version will faithfully replicate not only the features and behaviors of Elm v0.19.1, but also any existing bugs and quirks. By doing so, we provide a stable and predictable environment for developers, ensuring that their existing Elm projects work exactly as expected when migrated to Guida."
                ]
            , Html.p []
                [ Html.strong [] [ Html.text "Evolution and Innovation (Version 1.x and Beyond):" ]
                , Html.text " As Guida evolves, we will introduce new features and improvements. This phase will foster a unified ecosystem that adapts to the needs of its users."
                ]
            , Html.p [] [ Html.strong [] [ Html.text "Core Principles:" ] ]
            , Html.ul []
                [ Html.li []
                    [ Html.strong [] [ Html.text "Backward Compatibility:" ]
                    , Html.text " Respect for existing Elm projects, ensuring a frictionless migration."
                    ]
                , Html.li []
                    [ Html.strong [] [ Html.text "Accessibility:" ]
                    , Html.text " Lowering barriers for developers by implementing Guida's core in its own syntax."
                    ]
                ]
            , Html.p []
                [ Html.text "Our ultimate goal is to create a language that inherits the best aspects of Elm while adapting and growing to meet the needs of its users."
                ]
            , Html.section []
                [ Html.h2 [] [ Html.text "Try It" ]
                , Html.p []
                    [ Html.text "Experiment with Guida in your browser. Write, run, and explore code instantly with the "
                    , Html.a [ Attr.href "/try" ] [ Html.text "online Guida playground" ]
                    , Html.text "."
                    ]
                , Html.p []
                    [ Html.text "This is the easiest way to experiment with Guida in your browser. "
                    , Html.a [ Attr.href "/try" ] [ Html.text "Try it" ]
                    , Html.text ", no installation required."
                    ]
                ]
            , Html.section []
                [ Html.h2 [] [ Html.text "Documentation" ]
                , Html.p []
                    [ Html.text "The "
                    , Html.a [ Attr.href "/docs" ] [ Html.text "documentation" ]
                    , Html.text " is the best place to start learning about Guida. It will give you a solid foundation for creating applications. Once you have worked through that, the next place to look for documentation is on the "
                    , Html.a [ Attr.href "https://package.guida-lang.org" ] [ Html.text "packages" ]
                    , Html.text " you are using."
                    ]
                ]
            , Html.section []
                [ Html.h2 [] [ Html.text "Community" ]
                , Html.p []
                    [ Html.text "Join us to shape the language together. See our "
                    , Html.a [ Attr.href "/community" ] [ Html.text "Community" ]
                    , Html.text " page for more details on how to get involved. Here is a list of some of the main resources:"
                    , Html.ul []
                        [ Html.li []
                            [ Html.a [ Attr.href "https://github.com/guida-lang" ]
                                [ Html.text "Guida source code"
                                ]
                            ]
                        , Html.li []
                            [ Html.a [ Attr.href "https://github.com/orgs/guida-lang/discussions" ]
                                [ Html.text "Collaborative communication forum"
                                ]
                            ]
                        , Html.li []
                            [ Html.a [ Attr.href "https://github.com/guida-lang/compiler/blob/master/CONTRIBUTING.md" ]
                                [ Html.text "Contributing Guide"
                                ]
                            ]
                        ]
                    , Html.h3 [] [ Html.text "Contribute" ]
                    , Html.p [] [ Html.text "Guida is open source and thrives with your help: report bugs, improve the compiler and tools, and share your projects." ]
                    , Html.ul []
                        [ Html.li []
                            [ Html.a [ Attr.href "https://github.com/guida-lang/compiler/issues" ] [ Html.text "File a bug or feature request" ]
                            ]
                        , Html.li []
                            [ Html.text "Help triage existing issues"
                            ]
                        , Html.li []
                            [ Html.text "Submit improvements to the "
                            , Html.a [ Attr.href "https://github.com/guida-lang/compiler" ] [ Html.text "compiler" ]
                            , Html.text ", "
                            , Html.a [ Attr.href "https://github.com/guida-lang/package-registry" ] [ Html.text "registry" ]
                            , Html.text ", or "
                            , Html.a [ Attr.href "https://github.com/guida-lang" ] [ Html.text "tooling" ]
                            ]
                        , Html.li []
                            [ Html.text "Improve documentation or examples"
                            ]
                        , Html.li []
                            [ Html.text "Try out Guida and give us feedback"
                            ]
                        , Html.li []
                            [ Html.text "Look for "
                            , Html.a [ Attr.href "https://github.com/guida-lang/compiler/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22" ] [ Html.text "good first issues" ]
                            , Html.text " if you're just getting started"
                            ]
                        , Html.li []
                            [ Html.text "Port known issues or improvements from the Elm ecosystem"
                            ]
                        ]
                    ]
                , Html.p []
                    [ Html.text "Guida builds on projects like "
                    , Html.a [ Attr.href "https://github.com/elm/compiler" ] [ Html.text "elm/compiler" ]
                    , Html.text ", "
                    , Html.a [ Attr.href "https://github.com/avh4/elm-format" ] [ Html.text "elm-format" ]
                    , Html.text ", "
                    , Html.a [ Attr.href "https://github.com/elm-explorations/test" ] [ Html.text "elm-test" ]
                    , Html.text ", and "
                    , Html.a [ Attr.href "https://github.com/zwilias/elm-json" ] [ Html.text "elm-json" ]
                    , Html.text ". If you've encountered issues or ideas in those tools that feel worth bringing into Guida, feel free to reference them in a new issue or PR."
                    ]
                ]
            , Html.section []
                [ Html.h2 [] [ Html.text "Packages" ]
                , Html.p []
                    [ Html.text "Explore and publish libraries with the "
                    , Html.a [ Attr.href "https://package.guida-lang.org" ] [ Html.text "Guida package registry" ]
                    , Html.text "."
                    ]
                ]
            ]
    }
