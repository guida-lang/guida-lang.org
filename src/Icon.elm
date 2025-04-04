module Icon exposing
    ( arrowPath
    , burger
    , check
    , cross
    , github
    , logo
    , xMark
    )

import Html
import Html.Attributes as Attr
import Svg exposing (Svg)
import Svg.Attributes as SvgAttr


arrowPath : List (Html.Attribute msg) -> Svg msg
arrowPath attrs =
    Svg.svg
        (SvgAttr.fill "none"
            :: SvgAttr.viewBox "0 0 24 24"
            :: SvgAttr.strokeWidth "1.5"
            :: SvgAttr.stroke "currentColor"
            :: Attr.attribute "aria-hidden" "true"
            :: attrs
        )
        [ Svg.path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.d "M16.023 9.348h4.992v-.001M2.985 19.644v-4.992m0 0h4.992m-4.993 0 3.181 3.183a8.25 8.25 0 0 0 13.803-3.7M4.031 9.865a8.25 8.25 0 0 1 13.803-3.7l3.181 3.182m0-4.991v4.99"
            ]
            []
        ]


burger : List (Html.Attribute msg) -> Svg msg
burger attrs =
    Svg.svg
        (SvgAttr.fill "none"
            :: SvgAttr.viewBox "0 0 24 24"
            :: SvgAttr.strokeWidth "1.5"
            :: SvgAttr.stroke "currentColor"
            :: Attr.attribute "aria-hidden" "true"
            :: attrs
        )
        [ Svg.path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.d "M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
            ]
            []
        ]


check : List (Html.Attribute msg) -> Svg msg
check attrs =
    Svg.svg
        (SvgAttr.fill "none"
            :: SvgAttr.viewBox "0 0 24 24"
            :: SvgAttr.strokeWidth "1.5"
            :: SvgAttr.stroke "currentColor"
            :: Attr.attribute "aria-hidden" "true"
            :: attrs
        )
        [ Svg.path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.d "m4.5 12.75 6 6 9-13.5"
            ]
            []
        ]


cross : List (Html.Attribute msg) -> Svg msg
cross attrs =
    Svg.svg
        (SvgAttr.fill "none"
            :: SvgAttr.viewBox "0 0 24 24"
            :: SvgAttr.strokeWidth "1.5"
            :: SvgAttr.stroke "currentColor"
            :: Attr.attribute "aria-hidden" "true"
            :: attrs
        )
        [ Svg.path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.d "M6 18 18 6M6 6l12 12"
            ]
            []
        ]


github : List (Html.Attribute msg) -> Html.Html msg
github attrs =
    Svg.svg
        (SvgAttr.viewBox "0 0 24 24"
            :: SvgAttr.stroke "currentColor"
            :: Attr.attribute "aria-hidden" "true"
            :: attrs
        )
        [ Svg.path
            [ SvgAttr.fillRule "evenodd"
            , SvgAttr.clipRule "evenodd"
            , SvgAttr.d "M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
            ]
            []
        ]


logo : List (Html.Attribute msg) -> Svg msg
logo attrs =
    Svg.svg
        (SvgAttr.viewBox "0 0 52.917 52.917"
            :: SvgAttr.fill "currentColor"
            :: Attr.attribute "aria-hidden" "true"
            :: attrs
        )
        [ Svg.path
            [ SvgAttr.d "M26.458 37.248c-52.644 0 24.646 37.221-8.178-3.938s-13.734 42.475-2.02-8.849-41.771 15.746 5.66-7.096-38.355-22.841 9.077 0-6.056-44.228 5.659 7.096 30.803-32.31-2.02 8.85c-32.823 41.158 44.466 3.937-8.178 3.937z"
            ]
            []
        ]


xMark : List (Html.Attribute msg) -> Svg msg
xMark attrs =
    Svg.svg
        (SvgAttr.fill "none"
            :: SvgAttr.viewBox "0 0 24 24"
            :: SvgAttr.strokeWidth "1.5"
            :: SvgAttr.stroke "currentColor"
            :: Attr.attribute "aria-hidden" "true"
            :: attrs
        )
        [ Svg.path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.d "M6 18 18 6M6 6l12 12"
            ]
            []
        ]
