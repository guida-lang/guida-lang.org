module Components.ResourcePattern exposing (view)

import Components.GridPattern as GridPattern
import Html exposing (Html)
import Html.Attributes as Attr
import Svg.Attributes as SvgAttr


view : { mouseX : Int, mouseY : Int } -> Html msg
view { mouseX, mouseY } =
    let
        styleAttrs : List (Html.Attribute msg)
        styleAttrs =
            [ Attr.style "mask-image" ("radial-gradient(180px at " ++ String.fromInt mouseX ++ "px " ++ String.fromInt mouseY ++ "px, white, transparent)")
            ]
    in
    Html.div [ Attr.class "pointer-events-none" ]
        [ Html.div [ Attr.class "absolute inset-0 rounded-2xl transition duration-300 [mask-image:linear-gradient(white,transparent)] group-hover:opacity-50" ]
            [ GridPattern.view [ SvgAttr.class "absolute inset-x-0 inset-y-[-30%] h-[160%] w-full skew-y-[-18deg] fill-black/[0.02] stroke-black/5 dark:fill-white/1 dark:stroke-white/2.5" ]
                { width = 72
                , height = 56
                , x = 28
                , y = 16
                , squares =
                    [ ( 0, 1 )
                    , ( 1, 3 )
                    ]
                }
            ]
        , Html.div
            (Attr.class "absolute inset-0 rounded-2xl bg-linear-to-r from-[#FFFBEB] to-[#FEE685] opacity-0 transition duration-300 group-hover:opacity-100 dark:from-[#202D2E] dark:to-[#303428]"
                :: styleAttrs
            )
            []
        , Html.div
            (Attr.class "absolute inset-0 rounded-2xl opacity-0 mix-blend-overlay transition duration-300 group-hover:opacity-100"
                :: styleAttrs
            )
            [ GridPattern.view [ SvgAttr.class "absolute inset-x-0 inset-y-[-30%] h-[160%] w-full skew-y-[-18deg] fill-black/50 stroke-black/70 dark:fill-white/2.5 dark:stroke-white/10" ]
                { width = 72
                , height = 56
                , x = 28
                , y = 16
                , squares =
                    [ ( 0, 1 )
                    , ( 1, 3 )
                    ]
                }
            ]
        ]
