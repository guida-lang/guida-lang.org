module Components.Table exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


view : List (List (Html msg)) -> List (List (List (Html msg))) -> Html msg
view headers rows =
    Html.div [ Attr.class "overflow-hidden shadow-sm outline-1 outline-black/5 sm:rounded-lg dark:shadow-none dark:-outline-offset-1 dark:outline-white/10" ]
        [ Html.table [ Attr.class "relative min-w-full divide-y divide-gray-300 dark:divide-white/15" ]
            [ Html.thead [ Attr.class "bg-gray-50 dark:bg-gray-800/75" ] [ Html.tr [] (List.indexedMap headerView headers) ]
            , Html.tbody [ Attr.class "divide-y divide-gray-200 bg-white dark:divide-white/10 dark:bg-gray-800/50" ]
                (List.map rowView rows)
            ]
        ]


headerView : Int -> List (Html msg) -> Html msg
headerView index children =
    Html.th
        [ Attr.scope "col"
        , Attr.class
            (if index == 0 then
                "px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-white"

             else
                "px-3 py-3.5 text-left text-sm font-semibold text-gray-900 dark:text-gray-200"
            )
        ]
        children


rowView : List (List (Html msg)) -> Html msg
rowView row =
    Html.tr [] (List.indexedMap cellView row)


cellView : Int -> List (Html msg) -> Html msg
cellView index children =
    Html.td
        [ Attr.class
            (if index == 0 then
                "py-4 pr-3 pl-4 text-sm whitespace-nowrap text-gray-500 sm:pl-6 dark:text-white"

             else
                "px-3 py-4 text-sm whitespace-nowrap text-gray-500 dark:text-gray-400"
            )
        ]
        children
