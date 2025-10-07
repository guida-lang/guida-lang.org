module Components.ThemeToggle exposing
    ( Theme(..)
    , themeToString
    , view
    )

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Html.Events as Events
import Svg
import Svg.Attributes as SvgAttr


sunIcon : String -> Html msg
sunIcon className =
    Svg.svg
        [ SvgAttr.viewBox "0 0 20 20"
        , SvgAttr.fill "none"
        , Aria.ariaHidden True
        , SvgAttr.class className
        ]
        [ Svg.path [ SvgAttr.d "M12.5 10a2.5 2.5 0 1 1-5 0 2.5 2.5 0 0 1 5 0Z" ] []
        , Svg.path
            [ SvgAttr.strokeLinecap "round"
            , SvgAttr.d "M10 5.5v-1M13.182 6.818l.707-.707M14.5 10h1M13.182 13.182l.707.707M10 15.5v-1M6.11 13.889l.708-.707M4.5 10h1M6.11 6.111l.708.707"
            ]
            []
        ]


moonIcon : String -> Html msg
moonIcon className =
    Svg.svg
        [ SvgAttr.viewBox "0 0 20 20"
        , SvgAttr.fill "none"
        , Aria.ariaHidden True
        , SvgAttr.class className
        ]
        [ Svg.path [ SvgAttr.d "M15.224 11.724a5.5 5.5 0 0 1-6.949-6.949 5.5 5.5 0 1 0 6.949 6.949Z" ] []
        ]


type Theme
    = Light
    | Dark


themeToString : Theme -> String
themeToString theme =
    case theme of
        Light ->
            "light"

        Dark ->
            "dark"


view : Theme -> (Theme -> msg) -> Html msg
view resolvedTheme setTheme =
    let
        ( otherTheme, otherThemeLabel ) =
            case resolvedTheme of
                Dark ->
                    ( Light, "light" )

                Light ->
                    ( Dark, "dark" )
    in
    Html.button
        [ Attr.type_ "button"
        , Attr.class "flex h-6 w-6 items-center justify-center rounded-md transition hover:bg-zinc-900/5 dark:hover:bg-white/5"
        , Aria.ariaLabel ("Switch to " ++ otherThemeLabel ++ " theme")
        , Events.onClick (setTheme otherTheme)
        ]
        [ sunIcon "h-5 w-5 stroke-zinc-900 dark:hidden"
        , moonIcon "hidden h-5 w-5 stroke-white dark:block"
        ]
