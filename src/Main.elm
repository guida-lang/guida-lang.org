module Main exposing (main)

import Browser
import Html


main : Program () {} ()
main =
    Browser.sandbox
        { init = {}
        , update = \_ _ -> {}
        , view = \_ -> Html.h1 [] [ Html.text "Hello Guida!" ]
        }
