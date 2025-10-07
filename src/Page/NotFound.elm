module Page.NotFound exposing (view)

import Browser
import Html
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria



-- VIEW


view : Browser.Document Never
view =
    { title = "Guida: Page not found"
    , body =
        [ Html.main_ [ Aria.role "main" ]
            [ Html.section []
                [ Html.h2 [] [ Html.text "Page not found" ]
                , Html.p [] [ Html.text "Sorry, we couldn't find the page you're looking for." ]
                , Html.ul []
                    [ Html.li [] [ Html.a [ Attr.href "/" ] [ Html.text "Go back home" ] ]
                    , Html.li [] [ Html.a [ Attr.href "https://github.com/guida-lang/guida-lang.org/issues" ] [ Html.text "File a bug" ] ]
                    ]
                ]
            ]
        ]
    }
