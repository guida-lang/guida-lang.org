module Components.GridPattern exposing
    ( Config
    , view
    )

import Html exposing (Html)
import Html.Attributes.Aria as Aria
import Icon
import Svg
import Svg.Attributes as SvgAttr


type alias Config =
    { width : Int
    , height : Int
    , x : Int
    , y : Int
    , squares : List ( Int, Int )
    }


view : List (Html.Attribute msg) -> Config -> Html msg
view attrs config =
    let
        patternId : String
        patternId =
            "grid-pattern-id"

        squareElems : List (Html msg)
        squareElems =
            case config.squares of
                [] ->
                    []

                _ ->
                    [ Svg.svg
                        [ SvgAttr.x (String.fromInt config.x)
                        , SvgAttr.y (String.fromInt config.y)
                        , SvgAttr.class "overflow-visible"
                        ]
                        (List.map
                            (\( x, y ) ->
                                -- Svg.rect
                                --     [ SvgAttr.strokeWidth "0"
                                --     , SvgAttr.width (String.fromInt (config.width + 1))
                                --     , SvgAttr.height (String.fromInt (config.height + 1))
                                --     , SvgAttr.x (String.fromInt (x * config.width))
                                --     , SvgAttr.y (String.fromInt (y * config.height))
                                --     ]
                                --     []
                                Icon.logo
                                    [ SvgAttr.class "dark:text-amber-700/20"
                                    , SvgAttr.strokeWidth "0"

                                    --  , SvgAttr.fillOpacity "0.4"
                                    , SvgAttr.width (String.fromInt (config.width + 1))
                                    , SvgAttr.height (String.fromInt (config.height + 1))
                                    , SvgAttr.x (String.fromInt (x * config.width))
                                    , SvgAttr.y (String.fromInt (y * config.height))
                                    ]
                            )
                            config.squares
                        )
                    ]
    in
    Svg.svg (Aria.ariaHidden True :: attrs)
        (Svg.defs []
            [ Svg.pattern
                [ SvgAttr.id patternId
                , SvgAttr.width (String.fromInt config.width)
                , SvgAttr.height (String.fromInt config.height)
                , SvgAttr.patternUnits "userSpaceOnUse"
                , SvgAttr.x (String.fromInt config.x)
                , SvgAttr.y (String.fromInt config.y)
                ]
                [ Svg.path
                    [ SvgAttr.d ("M.5 " ++ String.fromInt config.height ++ "V.5H" ++ String.fromInt config.width)
                    , SvgAttr.fill "none"
                    ]
                    []
                ]
            ]
            :: Svg.rect
                [ SvgAttr.width "100%"
                , SvgAttr.height "100%"
                , SvgAttr.strokeWidth "0"
                , SvgAttr.fill ("url(#" ++ patternId ++ ")")
                ]
                []
            :: squareElems
        )
