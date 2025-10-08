module Layout.Header exposing
    ( Config
    , view
    )

import Components.Link as Link
import Components.Logo as Logo
import Components.MobileNavigation as MobileNavigation
import Components.ThemeToggle as ThemeToggle
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Icon
import Layout.Global as Global
import Session exposing (Session)
import Svg.Attributes as SvgAttr


type alias Config msg =
    { session : Session
    , className : Maybe String
    , hasSidebar : Bool
    , isInsideMobileNavigation : Bool
    , setThemeMsg : ThemeToggle.Theme -> msg
    , toggleNavigationMsg : msg
    }


topLevelNavItem : Global.NavItem msg -> Html msg
topLevelNavItem { href, children } =
    Html.li []
        [ Link.view
            [ Attr.href href
            , Attr.class "text-sm/5 text-zinc-600 transition hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white"
            ]
            children
        ]


socialLink : String -> (List (Html.Attribute msg) -> Html msg) -> List (Html msg) -> Html msg
socialLink href icon children =
    Link.view [ Attr.href href, Attr.class "flex h-6 w-6 items-center justify-center rounded-md transition hover:bg-zinc-900/5 dark:hover:bg-white/5" ]
        [ Html.span [ Attr.class "sr-only" ] children
        , icon [ SvgAttr.class "h-5 w-5 fill-zinc-900 dark:fill-white" ]
        ]


view : Config msg -> Html msg
view config =
    let
        isMobileNavigationOpen =
            Session.isMobileNavigationOpen config.session

        classNameAttrs =
            config.className
                |> Maybe.map (List.singleton << Attr.class)
                |> Maybe.withDefault []
    in
    Html.header
        (Aria.role "banner"
            :: Attr.classList
                [ ( "fixed inset-x-0 top-0 z-50 flex h-14 items-center justify-between gap-12 px-4 transition sm:px-6", True )
                , ( "lg:left-72 lg:z-30 lg:px-8 xl:left-80", config.hasSidebar )
                , ( "backdrop-blur-xs dark:backdrop-blur-sm", not config.isInsideMobileNavigation )
                , ( "bg-white dark:bg-zinc-900", config.isInsideMobileNavigation )
                , ( "bg-white/[var(--bg-opacity-light)] dark:bg-zinc-900/[var(--bg-opacity-dark)]", not config.isInsideMobileNavigation )
                , ( "lg:justify-end", config.hasSidebar )
                ]
            :: classNameAttrs
        )
        [ Html.div
            [ Attr.classList
                [ ( "absolute inset-x-0 top-full h-px transition", True )
                , ( "bg-zinc-900/7.5 dark:bg-white/7.5", config.isInsideMobileNavigation || not isMobileNavigationOpen )
                ]
            ]
            []
        , Html.div
            [ Attr.classList
                [ ( "flex items-center gap-4", True )
                , ( "lg:hidden", config.hasSidebar )
                ]
            ]
            [ MobileNavigation.view { hasSidebar = config.hasSidebar, isOpen = isMobileNavigationOpen, toggleMsg = config.toggleNavigationMsg }
            , Link.view [ Attr.href "/", Aria.ariaLabel "Home" ]
                [ Logo.view "h-6"
                ]
            ]
        , Html.div [ Attr.class "flex items-center gap-4" ]
            [ Html.nav [ Aria.role "navigation", Attr.class "hidden md:block" ]
                [ Html.ul [ Aria.role "list", Attr.class "flex items-center gap-6" ]
                    (List.map topLevelNavItem Global.topLevelNavItems)
                ]
            , Html.div [ Attr.class "hidden md:block md:h-5 md:w-px md:bg-zinc-900/10 md:dark:bg-white/15" ] []
            , Html.div [ Attr.class "flex gap-3" ]
                [ ThemeToggle.view (Session.theme config.session) config.setThemeMsg
                , socialLink Global.githubLink Icon.github [ Html.text "Follow us on GitHub" ]
                , socialLink Global.discordLink Icon.discord [ Html.text "Join our Discord server" ]
                ]
            ]
        ]
