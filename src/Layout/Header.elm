module Layout.Header exposing
    ( Enabled(..)
    , Item(..)
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
    | Custom (Maybe (Item msg)) (List (Item msg)) (List (Html msg))


type Item msg
    = Button { label : List (Html msg), msg : Enabled msg }
    | Link { label : List (Html msg), href : String }


type Enabled msg
    = Enabled msg
    | Disabled


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
                    , Attr.class "inline-flex items-center gap-x-1.5 font-mono text-2xl -m-1.5 p-1.5 text-amber-500 hover:text-amber-400"
                    ]
                    [ Icon.logo [ SvgAttr.class "h-8 w-auto" ]
                    , Html.div [ Attr.class "" ]
                        [ Html.text "guida"
                        ]
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
                        [ Html.text "Open main menu"
                        ]
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

        Custom (Just highlightedItem) items _ ->
            List.map viewTopLevelItem (highlightedItem :: items)

        Custom Nothing items _ ->
            List.map viewTopLevelItem items


viewTopLevelItem : Item msg -> Html msg
viewTopLevelItem item =
    case item of
        Button button ->
            let
                eventAttrs : List (Html.Attribute msg)
                eventAttrs =
                    case button.msg of
                        Enabled msg ->
                            [ Events.onClick msg ]

                        Disabled ->
                            [ Attr.class "cursor-not-allowed"
                            , Attr.disabled True
                            ]
            in
            Html.button
                (Attr.class "inline-flex items-center gap-x-1.5 rounded-md bg-amber-600 px-2 py-1 text-sm font-semibold text-white shadow-xs hover:bg-amber-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-amber-600"
                    :: eventAttrs
                )
                button.label

        Link link ->
            Html.a
                [ Attr.class "flex gap-x-3 text-sm/6 font-semibold text-gray-900"
                , Attr.href link.href
                ]
                link.label


navigationMenu : Mode msg -> msg -> Bool -> List (Html msg)
navigationMenu mode toggleNavigation showNavigation =
    if showNavigation then
        let
            highlightedItem : List (Html msg)
            highlightedItem =
                case mode of
                    Custom (Just item) _ _ ->
                        [ viewTopLevelItem item ]

                    _ ->
                        []
        in
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
                                        [ Attr.class "flex items-start"
                                        , Attr.classList
                                            [ ( "justify-between", not (List.isEmpty highlightedItem) )
                                            , ( "justify-end", List.isEmpty highlightedItem )
                                            ]
                                        ]
                                        (highlightedItem
                                            ++ [ Html.div
                                                    [ Attr.class "flex h-7 items-center"
                                                    ]
                                                    [ Html.button
                                                        [ Attr.type_ "button"
                                                        , Attr.class "-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700"
                                                        , Events.onClick toggleNavigation
                                                        ]
                                                        [ Html.span
                                                            [ Attr.class "sr-only"
                                                            ]
                                                            [ Html.text "Close panel" ]
                                                        , Icon.cross [ SvgAttr.class "size-6" ]
                                                        ]
                                                    ]
                                               ]
                                        )
                                    ]
                                , Html.div
                                    [ Attr.class "relative mt-6 flex-1 px-6"
                                    ]
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

        Custom _ _ content ->
            content


viewSidebarItem : Item msg -> Html msg
viewSidebarItem item =
    case item of
        Button button ->
            let
                eventAttrs : List (Html.Attribute msg)
                eventAttrs =
                    case button.msg of
                        Enabled msg ->
                            [ Events.onClick msg ]

                        Disabled ->
                            [ Attr.class "cursor-not-allowed"
                            , Attr.disabled True
                            ]
            in
            Html.button
                (Attr.class "rounded-md bg-amber-600 px-3 py-2 text-sm font-semibold text-white shadow-xs hover:bg-amber-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-amber-600"
                    :: eventAttrs
                )
                button.label

        Link link ->
            Html.a
                [ Attr.class "-mx-3 block rounded-lg px-3 py-2 text-base/7 font-semibold text-gray-900 hover:bg-gray-50"
                , Attr.href link.href
                ]
                link.label
