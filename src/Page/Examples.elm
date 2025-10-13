module Page.Examples exposing (view)

import Browser
import Components.Button as Button
import Html exposing (Html)
import Html.Attributes as Attr
import Layout.Main as Layout
import Session exposing (Session)


type alias Example =
    { title : String
    , links : List ExampleLink
    }


type alias ExampleLink =
    { title : String
    , href : String
    }


examples : List Example
examples =
    [ { title = "HTML"
      , links =
            [ { title = "Hello", href = "/examples/hello" }
            , { title = "Groceries", href = "/examples/groceries" }
            , { title = "Shapes", href = "/examples/shapes" }
            ]
      }
    , { title = "User Input"
      , links =
            [ { title = "Buttons", href = "/examples/buttons" }
            , { title = "Text Fields", href = "/examples/text-fields" }
            , { title = "Forms", href = "/examples/forms" }
            ]
      }
    , { title = "Random"
      , links =
            [ { title = "Numbers", href = "/examples/numbers" }
            , { title = "Cards", href = "/examples/cards" }
            , { title = "Positions", href = "/examples/positions" }
            ]
      }
    , { title = "HTTP"
      , links =
            [ { title = "Book", href = "/examples/book" }
            , { title = "Quotes", href = "/examples/quotes" }
            ]
      }
    , { title = "Time"
      , links =
            [ { title = "Time", href = "/examples/time" }
            , { title = "Clock", href = "/examples/clock" }
            ]
      }
    , { title = "Files"
      , links =
            [ { title = "Upload", href = "/examples/upload" }
            , { title = "Drag-and-Drop", href = "/examples/drag-and-drop" }
            , { title = "Image Previews", href = "/examples/image-previews" }
            ]
      }
    , { title = "WebGL"
      , links =
            [ { title = "Triangle", href = "/examples/triangle" }
            , { title = "Cube", href = "/examples/cube" }
            , { title = "Crate", href = "/examples/crate" }
            , { title = "Thwomp", href = "/examples/thwomp" }
            , { title = "First Person", href = "/examples/first-person" }
            ]
      }
    , { title = "Playground"
      , links =
            [ { title = "Picture", href = "/examples/picture" }
            , { title = "Animation", href = "/examples/animation" }
            , { title = "Mouse", href = "/examples/mouse" }
            , { title = "Keyboard", href = "/examples/keyboard" }
            , { title = "Turtle", href = "/examples/turtle" }
            , { title = "Mario", href = "/examples/mario" }
            ]
      }
    ]



-- VIEW


view : Session -> (Session.Msg -> msg) -> Browser.Document msg
view session toSessionMsg =
    { title = "Guida: Examples"
    , body =
        Layout.view { sidebarNavigation = [], currentRoute = [] } session toSessionMsg <|
            [ Html.h1 [] [ Html.text "Examples" ]
            , Html.div [ Attr.class "not-prose mt-4 grid grid-cols-1 gap-8 border-t border-zinc-900/5 pt-10 sm:grid-cols-2 lg:grid-cols-4 dark:border-white/5" ]
                (List.map exampleView examples)
            ]
    }


exampleView : Example -> Html msg
exampleView example =
    Html.div []
        [ Html.h2 [ Attr.class "text-sm font-semibold text-zinc-900 dark:text-white" ]
            [ Html.text example.title
            ]
        , Html.ul []
            (List.map exampleLinkView example.links)
        ]


exampleLinkView : ExampleLink -> Html msg
exampleLinkView link =
    Html.li []
        [ Button.view (Button.Link link.href) Button.Text Nothing [] [ Html.text link.title ]
        ]
