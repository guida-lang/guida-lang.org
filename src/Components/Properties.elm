module Components.Properties exposing
    ( Property
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria


type alias Property msg =
    { name : String
    , type_ : Maybe String
    , children : List (Html msg)
    }


view : List (Property msg) -> Html msg
view properties =
    Html.div [ Attr.class "my-6" ]
        [ Html.ul
            [ Aria.role "list"
            , Attr.class "m-0 list-none divide-y divide-zinc-900/5 p-0 dark:divide-white/5"
            ]
            (List.map propertyView properties)
        ]


propertyView : Property msg -> Html msg
propertyView property =
    let
        typeDescriptionTerm : List (Html msg)
        typeDescriptionTerm =
            property.type_
                |> Maybe.map
                    (\type_ ->
                        [ Html.dt [ Attr.class "sr-only" ] [ Html.text "Type" ]
                        , Html.dd [ Attr.class "font-mono text-xs text-zinc-400 dark:text-zinc-500" ] [ Html.text type_ ]
                        ]
                    )
                |> Maybe.withDefault []
    in
    Html.li [ Attr.class "m-0 px-0 py-4 first:pt-0 last:pb-0" ]
        [ Html.dl [ Attr.class "m-0 flex flex-wrap items-center gap-x-3 gap-y-2" ]
            (Html.dt [ Attr.class "sr-only" ] [ Html.text "Name" ]
                :: Html.dd [] [ Html.code [] [ Html.text property.name ] ]
                :: typeDescriptionTerm
                ++ [ Html.dt [ Attr.class "sr-only" ] [ Html.text "Description" ]
                   , Html.dd [ Attr.class "w-full flex-none [&>:first-child]:mt-0 [&>:last-child]:mb-0" ]
                        property.children
                   ]
            )
        ]
