module Components.CodeBlock exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


view : String -> Html msg
view content =
    Html.pre [ Attr.class "not-prose overflow-auto p-4 bg-neutral-100 dark:bg-white/2.5 dark:text-white" ]
        [ Html.code [ Attr.class "shadow-none p-0" ]
            [ Html.text content ]
        ]
