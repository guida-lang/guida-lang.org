module Components.Note exposing (..)

import Html exposing (Html)
import Html.Attributes as Attr
import Icon
import Svg.Attributes as SvgAttr


view : List (Html msg) -> Html msg
view children =
    Html.div [ Attr.class "my-6 flex gap-2.5 rounded-2xl border border-amber-500/20 bg-amber-50/50 p-4 text-sm/6 text-amber-900 dark:border-amber-500/30 dark:bg-amber-500/5 dark:text-amber-200 dark:[--tw-prose-links-hover:var(--color-amber-300)] dark:[--tw-prose-links:var(--color-white)]" ]
        [ Icon.info [ SvgAttr.class "mt-1 h-4 w-4 flex-none fill-amber-500 stroke-white dark:fill-amber-200/20 dark:stroke-amber-200" ]
        , Html.div [ Attr.class "[&>:first-child]:mt-0 [&>:last-child]:mb-0" ]
            children
        ]
