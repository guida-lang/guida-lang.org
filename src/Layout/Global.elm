module Layout.Global exposing
    ( NavItem
    , discordLink
    , githubLink
    , topLevelNavItems
    )

import Html exposing (Html)


type alias NavItem msg =
    { href : String
    , children : List (Html msg)
    }


topLevelNavItems : List (NavItem msg)
topLevelNavItems =
    [ { href = "/examples", children = [ Html.text "Examples" ] }
    , { href = "/try", children = [ Html.text "Try" ] }
    , { href = "/docs", children = [ Html.text "Docs" ] }
    , { href = "/community", children = [ Html.text "Community" ] }
    , { href = "https://package.guida-lang.org", children = [ Html.text "Packages" ] }
    ]


githubLink : String
githubLink =
    "https://github.com/guida-lang"


discordLink : String
discordLink =
    "https://discord.gg/B6WgPzf5Aa"
