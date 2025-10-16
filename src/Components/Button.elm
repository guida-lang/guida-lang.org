module Components.Button exposing
    ( Arrow(..)
    , Type(..)
    , Variant(..)
    , view
    )

import Components.Link as Link
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Svg
import Svg.Attributes as SvgAttr


arrowIcon : List (Html.Attribute msg) -> Html msg
arrowIcon attrs =
    Svg.svg
        (SvgAttr.viewBox "0 0 20 20"
            :: SvgAttr.fill "none"
            :: Aria.ariaHidden True
            :: attrs
        )
        [ Svg.path
            [ SvgAttr.stroke "currentColor"
            , SvgAttr.strokeLinecap "round"
            , SvgAttr.strokeLinejoin "round"
            , SvgAttr.d "m11.5 6.5 3 3.5m0 0-3 3.5m3-3.5h-9"
            ]
            []
        ]


type Type
    = Button
    | Link String


type Variant
    = Primary
    | Secondary
    | Filled
    | Outline
    | Text


variantStyles : Variant -> String
variantStyles variant =
    case variant of
        Primary ->
            "rounded-full bg-zinc-900 py-1 px-3 text-white hover:bg-zinc-700 dark:bg-amber-400/10 dark:text-amber-400 dark:ring-1 dark:ring-inset dark:ring-amber-400/20 dark:hover:bg-amber-400/10 dark:hover:text-amber-300 dark:hover:ring-amber-300"

        Secondary ->
            "rounded-full bg-zinc-100 py-1 px-3 text-zinc-900 hover:bg-zinc-200 dark:bg-zinc-800/40 dark:text-zinc-400 dark:ring-1 dark:ring-inset dark:ring-zinc-800 dark:hover:bg-zinc-800 dark:hover:text-zinc-300"

        Filled ->
            "rounded-full bg-zinc-900 py-1 px-3 text-white hover:bg-zinc-700 dark:bg-amber-500 dark:text-white dark:hover:bg-amber-400"

        Outline ->
            "rounded-full py-1 px-3 text-zinc-700 ring-1 ring-inset ring-zinc-900/10 hover:bg-zinc-900/2.5 hover:text-zinc-900 dark:text-zinc-400 dark:ring-white/10 dark:hover:bg-white/5 dark:hover:text-white"

        Text ->
            "text-amber-500 hover:text-amber-600 dark:text-amber-400 dark:hover:text-amber-500"


type Arrow
    = LeftArrow
    | RightArrow


view : Type -> Variant -> Maybe Arrow -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
view type_ variant maybeArrow attrs children =
    let
        classAttrs : List (Html.Attribute msg)
        classAttrs =
            [ Attr.classList
                [ ( "inline-flex gap-0.5 items-center justify-center overflow-hidden text-sm font-medium transition", True )
                , ( variantStyles variant, True )
                ]
            ]

        arrowIconElem : Html msg
        arrowIconElem =
            let
                variantAttrs : List (Svg.Attribute msg)
                variantAttrs =
                    case variant of
                        Text ->
                            [ SvgAttr.class "relative top-px" ]

                        _ ->
                            []

                arrowAttrs : List (Svg.Attribute msg)
                arrowAttrs =
                    case maybeArrow of
                        Just LeftArrow ->
                            [ SvgAttr.class "-ml-1 rotate-180" ]

                        Just RightArrow ->
                            [ SvgAttr.class "-mr-1" ]

                        Nothing ->
                            []
            in
            arrowIcon
                (SvgAttr.class "mt-0.5 h-5 w-5"
                    :: variantAttrs
                    ++ arrowAttrs
                )

        inner : List (Html msg)
        inner =
            case maybeArrow of
                Just LeftArrow ->
                    arrowIconElem :: children

                Just RightArrow ->
                    children ++ [ arrowIconElem ]

                Nothing ->
                    children
    in
    case type_ of
        Button ->
            Html.button (classAttrs ++ attrs)
                inner

        Link href ->
            Link.view (Attr.href href :: classAttrs ++ attrs)
                inner
