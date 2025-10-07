module Layout.Footer exposing (view)

import Components.Link as Link
import Html exposing (Html)
import Html.Attributes as Attr
import Icon
import Layout.Global as Global
import Svg.Attributes as SvgAttr


socialLink : String -> (List (Html.Attribute msg) -> Html msg) -> List (Html msg) -> Html msg
socialLink href icon children =
    Link.view [ Attr.href href, Attr.class "group" ]
        [ Html.span [ Attr.class "sr-only" ] children
        , icon [ SvgAttr.class "h-5 w-5 fill-zinc-700 transition group-hover:fill-zinc-900 dark:group-hover:fill-zinc-500" ]
        ]


smallPrint : Int -> Html msg
smallPrint year =
    Html.div [ Attr.class "flex flex-col items-center justify-between gap-5 border-t border-zinc-900/5 pt-8 sm:flex-row dark:border-white/5" ]
        [ Html.p [ Attr.class "text-xs text-zinc-600 dark:text-zinc-400" ]
            [ Html.text ("© " ++ String.fromInt year ++ " Décio Ferreira. All rights reserved.")
            ]
        , Html.div [ Attr.class "flex gap-3" ]
            [ socialLink Global.githubLink Icon.github [ Html.text "Follow us on GitHub" ]
            , socialLink Global.discordLink Icon.discord [ Html.text "Join our Discord server" ]
            ]
        ]


view : Int -> Html msg
view year =
    Html.footer [ Attr.class "mx-auto w-full max-w-2xl space-y-10 pb-16 lg:max-w-5xl" ]
        [ smallPrint year
        ]
