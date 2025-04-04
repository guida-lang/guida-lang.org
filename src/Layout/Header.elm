module Layout.Header exposing
    ( Item(..)
    , Mode(..)
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icon
import Svg.Attributes as SvgAttr


type Mode msg
    = Navigation (List (Item msg))
    | Custom (List (Item msg)) (List (Html msg))


type Item msg
    = Button { label : List (Html msg), msg : msg }
    | Link { label : List (Html msg), href : String }


view : Mode msg -> msg -> Bool -> Html msg
view mode toggleNavigation showNavigation =
    Html.header [ Attr.class "absolute inset-x-0 top-0 z-50 shadow-sm" ]
        (Html.nav
            [ Attr.class "flex items-center justify-between p-6"
            , Attr.attribute "aria-label" "Global"
            ]
            [ Html.div
                [ Attr.class "flex lg:flex-1"
                ]
                [ Html.a
                    [ Attr.href "/"
                    , Attr.class "-m-1.5 p-1.5"
                    ]
                    [ Html.span [ Attr.class "sr-only" ]
                        [ Html.text "Guida" ]
                    , Icon.logo [ SvgAttr.class "h-8 w-auto" ]
                    ]
                ]
            , Html.div
                [ Attr.class "flex lg:hidden"
                ]
                [ Html.button
                    [ Attr.type_ "button"
                    , Attr.class "-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700"
                    , Events.onClick toggleNavigation
                    ]
                    [ Html.span
                        [ Attr.class "sr-only"
                        ]
                        [ Html.text "Open main menu" ]
                    , Icon.burger [ SvgAttr.class "size-6" ]
                    ]
                ]
            , Html.div
                [ Attr.class "hidden lg:flex lg:gap-x-8 items-center"
                ]
                (viewTopLevelMode mode)
            ]
            :: navigationMenu mode toggleNavigation showNavigation
        )


viewTopLevelMode : Mode msg -> List (Html msg)
viewTopLevelMode mode =
    case mode of
        Navigation items ->
            List.map viewTopLevelItem items

        Custom items _ ->
            List.map viewTopLevelItem items


viewTopLevelItem : Item msg -> Html msg
viewTopLevelItem item =
    case item of
        Button button ->
            Html.button
                [ Attr.class "rounded-sm bg-amber-600 px-2 py-1 text-sm font-semibold text-white shadow-xs hover:bg-amber-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-amber-600"
                , Events.onClick button.msg
                ]
                button.label

        Link link ->
            Html.a
                [ Attr.class "text-sm/6 font-semibold text-gray-900"
                , Attr.href link.href
                ]
                link.label


navigationMenu : Mode msg -> msg -> Bool -> List (Html msg)
navigationMenu mode toggleNavigation showNavigation =
    if showNavigation then
        [ Html.div
            [ Attr.class "relative z-50 lg:hidden"
            , Attr.attribute "aria-labelledby" "slide-over-title"
            , Attr.attribute "role" "dialog"
            , Attr.attribute "aria-modal" "true"
            ]
            [ Html.div
                [ Attr.class "fixed inset-0 bg-gray-500/75"
                , Attr.attribute "aria-hidden" "true"
                ]
                []
            , Html.div
                [ Attr.class "fixed inset-0 overflow-hidden"
                ]
                [ Html.div
                    [ Attr.class "absolute inset-0 overflow-hidden"
                    ]
                    [ Html.div
                        [ Attr.class "pointer-events-none fixed inset-y-0 right-0 flex max-w-full pl-10"
                        ]
                        [ Html.div
                            [ Attr.class "pointer-events-auto w-screen max-w-sm"
                            ]
                            [ Html.div
                                [ Attr.class "flex h-full flex-col overflow-y-scroll bg-white py-6 shadow-xl"
                                ]
                                [ Html.div
                                    [ Attr.class "px-6"
                                    ]
                                    [ Html.div
                                        [ Attr.class "flex items-start justify-end"
                                        ]
                                        [ Html.div
                                            [ Attr.class "flex h-7 items-center"
                                            ]
                                            [ Html.button
                                                [ Attr.type_ "button"
                                                , Attr.class "-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700"
                                                , Events.onClick toggleNavigation
                                                ]
                                                [ Html.span
                                                    [ Attr.class "absolute -inset-2.5"
                                                    ]
                                                    []
                                                , Html.span
                                                    [ Attr.class "sr-only"
                                                    ]
                                                    [ Html.text "Close panel" ]
                                                , Icon.cross [ SvgAttr.class "size-6" ]
                                                ]
                                            ]
                                        ]
                                    ]
                                , Html.div
                                    [ Attr.class "relative mt-6 flex-1 px-6"
                                    ]
                                    -- (List.map
                                    --     (\link ->
                                    --         Html.a
                                    --             [ Attr.href link.href
                                    --             , Attr.class "-mx-3 block rounded-lg px-3 py-2 text-base/7 font-semibold text-gray-900 hover:bg-gray-50"
                                    --             ]
                                    --             [ Html.text link.label ]
                                    --     )
                                    --     links
                                    -- )
                                    (viewSidebarMode mode)
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]

    else
        []


viewSidebarMode : Mode msg -> List (Html msg)
viewSidebarMode mode =
    case mode of
        Navigation items ->
            List.map viewSidebarItem items

        Custom _ content ->
            content


viewSidebarItem : Item msg -> Html msg
viewSidebarItem item =
    case item of
        Button button ->
            Html.button
                [ Attr.class "rounded-md bg-amber-600 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-amber-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-amber-600"
                , Events.onClick button.msg
                ]
                button.label

        Link link ->
            Html.a
                [ Attr.class "-mx-3 block rounded-lg px-3 py-2 text-base/7 font-semibold text-gray-900 hover:bg-gray-50"
                , Attr.href link.href
                ]
                link.label
