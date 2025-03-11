module Layout.Footer exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Icon
import Svg.Attributes as SvgAttr


view : Int -> Html msg
view year =
    Html.footer
        [ Attr.class "mx-auto max-w-7xl px-6 py-12 md:flex md:items-center md:justify-between lg:px-8"
        ]
        [ Html.div
            [ Attr.class "flex justify-center gap-x-6 md:order-2"
            ]
            [ Html.a
                [ Attr.href "https://github.com/guida-lang"
                , Attr.class "text-gray-600 hover:text-gray-800"
                ]
                [ Html.span
                    [ Attr.class "sr-only"
                    ]
                    [ Html.text "GitHub" ]
                , Icon.github
                    [ SvgAttr.class "size-6"
                    , SvgAttr.fill "currentColor"
                    ]
                ]
            ]
        , Html.p
            [ Attr.class "mt-8 text-center text-sm/6 text-gray-600 md:order-1 md:mt-0"
            ]
            [ Html.text ("© " ++ String.fromInt year ++ " Décio Ferreira. All rights reserved.") ]
        ]
