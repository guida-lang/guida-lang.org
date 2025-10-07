module Page.Community exposing (view)

import Browser
import Html
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Layout.Main as Layout
import Session exposing (Session)



-- VIEW


view : Session -> (Session.Msg -> msg) -> Browser.Document msg
view session toSessionMsg =
    { title = "Guida: Community"
    , body =
        Layout.view { sidebarNavigation = [] } session toSessionMsg <|
            [ Html.main_ [ Aria.role "main" ]
                [ Html.section []
                    [ Html.h2 [] [ Html.text "Community" ]
                    , Html.p []
                        [ Html.text "Guida is built in the open, and its future depends on the people who use it, contribute to it, and share ideas. Whether you're here to report a bug, propose a feature, improve the compiler, or just explore the language, you're very welcome to join the community."
                        ]
                    , Html.h3 [] [ Html.text "Where to Talk" ]
                    , Html.ul []
                        [ Html.li []
                            [ Html.strong [] [ Html.text "Discord:" ]
                            , Html.text " Join us in the "
                            , Html.a [ Attr.href "https://discord.gg/B6WgPzf5Aa" ] [ Html.text "Guida Discord" ]
                            , Html.text " to connect with other contributors and users, ask questions, and share ideas."
                            ]
                        , Html.li []
                            [ Html.strong [] [ Html.text "GitHub Discussions:" ]
                            , Html.text " On the "
                            , Html.a [ Attr.href "https://github.com/orgs/guida-lang/discussions" ] [ Html.text "Guida Discussions" ]
                            , Html.text " you can ask and answer questions, share updates, have open-ended conversations, and follow along on decisions affecting the community's way of working."
                            ]
                        , Html.li []
                            [ Html.strong [] [ Html.text "GitHub Issues:" ]
                            , Html.text " Found a bug or missing feature? Report it in the "
                            , Html.a [ Attr.href "https://github.com/guida-lang/compiler/issues" ] [ Html.text "Guida Compiler issue tracker" ]
                            , Html.text "."
                            ]
                        ]
                    , Html.h3 [] [ Html.text "How to Contribute" ]
                    , Html.ul []
                        [ Html.li []
                            [ Html.text "Read the "
                            , Html.a [ Attr.href "https://github.com/guida-lang/compiler/blob/master/CONTRIBUTING.md" ] [ Html.text "Contributing Guide" ]
                            , Html.text " to learn how to get started."
                            ]
                        , Html.li []
                            [ Html.text "Check out open issues labeled "
                            , Html.a [ Attr.href "https://github.com/guida-lang/compiler/issues?q=is%3Aissue%20state%3Aopen%20label%3A%22good%20first%20issue%22" ] [ Html.text "“good first issue”" ]
                            , Html.text "."
                            ]
                        , Html.li []
                            [ Html.text "Improvements to the "
                            , Html.strong [] [ Html.text "compiler" ]
                            , Html.text ", "
                            , Html.strong [] [ Html.text "package registry" ]
                            , Html.text ", and "
                            , Html.strong [] [ Html.text "tooling" ]
                            , Html.text " are always welcome."
                            ]
                        ]
                    , Html.h3 [] [ Html.text "Stay Up to Date" ]
                    , Html.ul []
                        [ Html.li []
                            [ Html.text "Follow ongoing work on "
                            , Html.a [ Attr.href "https://github.com/guida-lang" ] [ Html.text "GitHub" ]
                            , Html.text "."
                            ]
                        , Html.li []
                            [ Html.text "See the "
                            , Html.a [ Attr.href "https://github.com/orgs/guida-lang/discussions" ] [ Html.text "GitHub discussions" ]
                            , Html.text " for what's next."
                            ]
                        , Html.li []
                            [ Html.text "Keep an eye on the "
                            , Html.a [ Attr.href "https://github.com/orgs/guida-lang/discussions/112" ] [ Html.text "Interesting Projects & Tools" ]
                            , Html.text " list to discover related work in the ecosystem."
                            ]
                        ]
                    , Html.h3 [] [ Html.text "Guiding Principles" ]
                    , Html.p [] [ Html.strong [] [ Html.text "Guida thrives on:" ] ]
                    , Html.ul []
                        [ Html.li []
                            [ Html.strong [] [ Html.text "Backward Compatibility:" ]
                            , Html.text " Respecting existing code whenever possible."
                            ]
                        , Html.li []
                            [ Html.strong [] [ Html.text "Self-hosted development:" ]
                            , Html.text " Building the language in the language itself."
                            ]
                        , Html.li []
                            [ Html.strong [] [ Html.text "Community-driven innovation:" ]
                            , Html.text " Growing through shared ideas and contributions."
                            ]
                        ]
                    ]
                ]
            ]
    }
