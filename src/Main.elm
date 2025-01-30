module Main exposing (main)

import Browser
import Html


main : Program () () ()
main =
    Browser.document
        { init = \_ -> ( (), Cmd.none )
        , view =
            \_ ->
                { title = "Guida"
                , body =
                    [ Html.h1 [] [ Html.text "Hello Guida!" ]
                    ]
                }
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
