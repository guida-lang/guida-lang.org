module Components.CodeBlock exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr


view : String -> Html msg
view content =
    Html.pre [ Attr.class "overflow-auto p-4 bg-neutral-100" ]
        [ Html.code [ Attr.class "shadow-none p-0" ]
            [ Html.text content ]
        ]
