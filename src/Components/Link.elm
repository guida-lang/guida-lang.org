module Components.Link exposing (view)

import Html exposing (Html)


view : List (Html.Attribute msg) -> List (Html msg) -> Html msg
view =
    Html.a
