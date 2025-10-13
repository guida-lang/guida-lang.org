module Components.References exposing (view)

import Components.Button as Button
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria


view : List String -> Html msg
view links =
    Html.div [ Attr.class "my-6" ]
        [ Html.hr [] []
        , Html.h2 [] [ Html.text "References" ]
        , Html.ul [ Aria.role "list" ]
            (List.map linkView links)
        ]


linkView : String -> Html msg
linkView href =
    Html.li []
        [ Button.view (Button.Link href) Button.Text Nothing [] [ Html.text href ]
        ]
