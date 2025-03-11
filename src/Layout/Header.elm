module Layout.Header exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icon
import Svg
import Svg.Attributes as SvgAttr


view : msg -> Bool -> Html msg
view toggleNavigation showNavigation =
    Html.header
        [ Attr.class "absolute inset-x-0 top-0 z-50"
        ]
        (Html.nav
            [ Attr.class "flex items-center justify-between p-6 lg:px-8"
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
                    , Svg.svg
                        [ SvgAttr.class "size-6"
                        , SvgAttr.fill "none"
                        , SvgAttr.viewBox "0 0 24 24"
                        , SvgAttr.strokeWidth "1.5"
                        , SvgAttr.stroke "currentColor"
                        , Attr.attribute "aria-hidden" "true"
                        , Attr.attribute "data-slot" "icon"
                        ]
                        [ Svg.path
                            [ SvgAttr.strokeLinecap "round"
                            , SvgAttr.strokeLinejoin "round"
                            , SvgAttr.d "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                            ]
                            []
                        ]
                    ]
                ]
            , Html.div
                [ Attr.class "hidden lg:flex lg:gap-x-12"
                ]
                (List.map
                    (\link ->
                        Html.a
                            [ Attr.href link.href
                            , Attr.class "text-sm/6 font-semibold text-gray-900"
                            ]
                            [ Html.text link.label ]
                    )
                    links
                )
            ]
            :: navigationMenu toggleNavigation showNavigation
        )


navigationMenu : msg -> Bool -> List (Html msg)
navigationMenu toggleNavigation showNavigation =
    if showNavigation then
        [ Html.div
            [ Attr.class "lg:hidden"
            , Attr.attribute "role" "dialog"
            , Attr.attribute "aria-modal" "true"
            ]
            [ Html.div
                [ Attr.class "fixed inset-y-0 right-0 z-50 w-full overflow-y-auto bg-white px-6 py-6 sm:max-w-sm sm:ring-1 sm:ring-gray-900/10"
                ]
                [ Html.div
                    [ Attr.class "flex items-center justify-between"
                    ]
                    [ Html.a
                        [ Attr.href "/"
                        , Attr.class "-m-1.5 p-1.5"
                        ]
                        [ Html.span [ Attr.class "sr-only" ]
                            [ Html.text "Guida"
                            ]
                        , Icon.logo [ SvgAttr.class "h-8 w-auto" ]
                        ]
                    , Html.button
                        [ Attr.type_ "button"
                        , Attr.class "-m-2.5 rounded-md p-2.5 text-gray-700"
                        , Events.onClick toggleNavigation
                        ]
                        [ Html.span
                            [ Attr.class "sr-only"
                            ]
                            [ Html.text "Close menu" ]
                        , Svg.svg
                            [ SvgAttr.class "size-6"
                            , SvgAttr.fill "none"
                            , SvgAttr.viewBox "0 0 24 24"
                            , SvgAttr.strokeWidth "1.5"
                            , SvgAttr.stroke "currentColor"
                            , Attr.attribute "aria-hidden" "true"
                            , Attr.attribute "data-slot" "icon"
                            ]
                            [ Svg.path
                                [ SvgAttr.strokeLinecap "round"
                                , SvgAttr.strokeLinejoin "round"
                                , SvgAttr.d "M6 18 18 6M6 6l12 12"
                                ]
                                []
                            ]
                        ]
                    ]
                , Html.div
                    [ Attr.class "mt-6 flow-root"
                    ]
                    [ Html.div
                        [ Attr.class "-my-6 divide-y divide-gray-500/10"
                        ]
                        [ Html.div
                            [ Attr.class "space-y-2 py-6"
                            ]
                            (List.map
                                (\link ->
                                    Html.a
                                        [ Attr.href link.href
                                        , Attr.class "-mx-3 block rounded-lg px-3 py-2 text-base/7 font-semibold text-gray-900 hover:bg-gray-50"
                                        ]
                                        [ Html.text link.label ]
                                )
                                links
                            )
                        ]
                    ]
                ]
            ]
        ]

    else
        []


type alias Link =
    { href : String
    , label : String
    }


links : List Link
links =
    [ { href = "/try"
      , label = "Examples"
      }
    , { href = "/docs"
      , label = "Documentation"
      }
    , { href = "https://package.guida-lang.org"
      , label = "Packages"
      }
    ]
