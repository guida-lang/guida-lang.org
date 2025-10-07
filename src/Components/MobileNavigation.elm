module Components.MobileNavigation exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Html.Events as Events
import Svg
import Svg.Attributes as SvgAttr


menuIcon : String -> Html msg
menuIcon className =
    Svg.svg
        [ SvgAttr.viewBox "0 0 10 9"
        , SvgAttr.fill "none"
        , SvgAttr.strokeLinecap "round"
        , Aria.ariaHidden True
        , SvgAttr.class className
        ]
        [ Svg.path [ SvgAttr.d "M.5 1h9M.5 8h9M.5 4.5h9" ] []
        ]


xIcon : String -> Html msg
xIcon className =
    Svg.svg
        [ SvgAttr.viewBox "0 0 10 9"
        , SvgAttr.fill "none"
        , SvgAttr.strokeLinecap "round"
        , Aria.ariaHidden True
        , SvgAttr.class className
        ]
        [ Svg.path [ SvgAttr.d "m1.5 1 7 7M8.5 1l-7 7" ] []
        ]


view : { hasSidebar : Bool, isOpen : Bool, toggleMsg : msg } -> Html msg
view { hasSidebar, isOpen, toggleMsg } =
    let
        toogleIcon =
            if isOpen then
                xIcon

            else
                menuIcon
    in
    Html.button
        [ Attr.type_ "button"
        , Attr.classList
            [ ( "flex h-6 w-6 items-center justify-center rounded-md transition lg:hidden hover:bg-zinc-900/5 dark:hover:bg-white/5", True )
            , ( "md:hidden", not hasSidebar )
            ]
        , Aria.ariaLabel "Toggle navigation"
        , Events.onClick toggleMsg
        ]
        [ toogleIcon "w-2.5 stroke-zinc-900 dark:stroke-white"
        ]
