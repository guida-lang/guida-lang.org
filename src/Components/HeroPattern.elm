module Components.HeroPattern exposing (view)

import Components.GridPattern as GridPattern
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Svg
import Svg.Attributes as SvgAttr


view : Html msg
view =
    Html.div [ Attr.class "absolute inset-0 -z-10 mx-0 max-w-none overflow-hidden" ]
        [ Html.div [ Attr.class "absolute top-0 left-1/2 ml-[-38rem] h-[25rem] w-[81.25rem] dark:[mask-image:linear-gradient(white,transparent)]" ]
            [ Html.div [ Attr.class "absolute inset-0 bg-linear-to-r from-[#FD9A00] to-[#FEF3C6] opacity-40 [mask-image:radial-gradient(farthest-side_at_top,white,transparent)] dark:from-[#FD9A00]/30 dark:to-[#FEF3C6]/30 dark:opacity-100" ]
                [ GridPattern.view [ SvgAttr.class "absolute inset-x-0 h-[200%] w-full skew-y-[18deg] fill-black/40 stroke-black/50 mix-blend-overlay dark:fill-white/2.5 dark:stroke-white/5" ]
                    { width = 72
                    , height = 56
                    , x = -12
                    , y = 4
                    , squares = [ ( 4, 3 ), ( 2, 1 ), ( 7, 3 ), ( 10, 6 ) ]
                    }
                ]
            , Svg.svg
                [ SvgAttr.viewBox "0 0 1113 440"
                , Aria.ariaHidden True
                , SvgAttr.class "absolute top-0 left-1/2 ml-[-19rem] w-[69.5625rem] fill-white blur-[26px] dark:hidden"
                ]
                [ Svg.path [ SvgAttr.d "M.016 439.5s-9.5-300 434-300S882.516 20 882.516 20V0h230.004v439.5H.016Z" ] []
                ]
            ]
        ]
