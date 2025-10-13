module Layout.Main exposing
    ( Config
    , fullscreenView
    , view
    )

import Components.Link as Link
import Components.Logo as Logo
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Html.Events as Events
import Layout.Footer as Footer
import Layout.Header as Header
import Layout.Navigation as Navigation exposing (Navigation)
import Session exposing (Session)



-- CONFIGURATION


type alias Config route =
    { sidebarNavigation : Navigation route
    , currentRoute : route
    }



-- VIEW


sidebarView : Config route -> Session -> (Session.Msg -> msg) -> Html msg
sidebarView config session toSessionMsg =
    let
        header : Html msg
        header =
            Header.view
                { session = session
                , className = Nothing
                , hasSidebar = not (List.isEmpty config.sidebarNavigation)
                , isInsideMobileNavigation = False
                , setThemeMsg = toSessionMsg << Session.SetTheme
                , toggleNavigationMsg = toSessionMsg Session.ToggleMobileNavigation
                }
    in
    if List.isEmpty config.sidebarNavigation then
        Html.div [ Attr.class "contents lg:pointer-events-auto" ] [ header ]

    else
        Html.div [ Attr.class "contents lg:pointer-events-auto lg:block lg:w-72 lg:overflow-y-auto lg:border-r lg:border-zinc-900/10 lg:px-6 lg:pt-4 lg:pb-8 xl:w-80 lg:dark:border-white/10" ]
            [ Html.div [ Attr.class "hidden lg:flex" ]
                [ Link.view [ Attr.href "/", Aria.ariaLabel "Home" ]
                    [ Logo.view "h-6"
                    ]
                ]
            , header
            , Navigation.view [ Attr.class "hidden lg:mt-10 lg:block" ] config.currentRoute config.sidebarNavigation
            ]


dialogView : Config route -> Session -> (Session.Msg -> msg) -> Html msg
dialogView config session toSessionMsg =
    let
        openAttrs : List (Html.Attribute msg)
        openAttrs =
            if Session.isMobileNavigationOpen session then
                [ Attr.attribute "open" "true" ]

            else
                []
    in
    Html.node "dialog"
        (Attr.class "fixed inset-0 z-50 lg:hidden"
            :: openAttrs
        )
        [ Html.div
            [ Attr.class "fixed inset-0 top-14 bg-zinc-400/20 backdrop-blur-xs data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in dark:bg-black/40"
            , Events.onClick (toSessionMsg Session.ToggleMobileNavigation)
            ]
            []
        , Header.view
            { session = session
            , className = Just "data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in"
            , hasSidebar = not (List.isEmpty config.sidebarNavigation)
            , isInsideMobileNavigation = True
            , setThemeMsg = toSessionMsg << Session.SetTheme
            , toggleNavigationMsg = toSessionMsg Session.ToggleMobileNavigation
            }
        , Html.div [ Attr.class "fixed top-14 bottom-0 left-0 w-full overflow-y-auto bg-white px-4 pt-6 pb-4 ring-1 shadow-lg shadow-zinc-900/10 ring-zinc-900/7.5 duration-500 ease-in-out data-closed:-translate-x-full min-[416px]:max-w-sm sm:px-6 sm:pb-10 dark:bg-zinc-900 dark:ring-zinc-800" ]
            [ Navigation.view [] config.currentRoute config.sidebarNavigation
            ]
        ]


view : Config route -> Session -> (Session.Msg -> msg) -> List (Html msg) -> List (Html msg)
view config session toSessionMsg children =
    [ Html.div [ Attr.class "contents" ]
        [ Html.div [ Attr.class "w-full" ]
            [ Html.div
                [ Attr.classList
                    [ ( "h-full", True )
                    , ( "lg:ml-72 xl:ml-80", not (List.isEmpty config.sidebarNavigation) )
                    ]
                ]
                [ Html.header [ Attr.class "contents lg:pointer-events-none lg:fixed lg:inset-0 lg:z-40 lg:flex" ]
                    [ sidebarView config session toSessionMsg
                    ]
                , Html.div [ Attr.id "main", Attr.class "relative flex h-full flex-col px-4 pt-14 sm:px-6 lg:px-8" ]
                    [ Html.main_ [ Attr.class "flex-auto" ]
                        [ Html.article [ Attr.class "flex h-full flex-col pt-16 pb-10" ]
                            [ Html.div
                                [ Attr.classList
                                    [ ( "flex-auto", True )
                                    , ( "prose dark:prose-invert", True )

                                    -- `html :where(& > *)` is used to select all direct children without an increase in specificity like you'd get from just `& > *`
                                    , ( "[html_:where(&>*)]:mx-auto [html_:where(&>*)]:max-w-2xl lg:[html_:where(&>*)]:mx-[calc(50%-min(50%,var(--container-lg)))] lg:[html_:where(&>*)]:max-w-5xl", True )
                                    ]
                                ]
                                children
                            ]
                        ]
                    , Footer.view (Session.year session)
                    ]
                ]
            ]
        ]
    , dialogView config session toSessionMsg
    ]


fullscreenView : Session -> (Session.Msg -> msg) -> List (Html msg) -> List (Html msg)
fullscreenView session toSessionMsg children =
    let
        config : Config ()
        config =
            { sidebarNavigation = [], currentRoute = () }
    in
    [ Html.div [ Attr.class "contents" ]
        [ Html.div [ Attr.class "w-full" ]
            [ Html.div [ Attr.class "h-full" ]
                [ Html.header [ Attr.class "contents lg:pointer-events-none lg:fixed lg:inset-0 lg:z-40 lg:flex" ]
                    [ sidebarView config session toSessionMsg
                    ]
                , Html.div [ Attr.class "relative flex h-full flex-col pt-14" ]
                    [ Html.main_ [ Attr.class "flex-auto prose dark:prose-invert" ]
                        children
                    ]
                ]
            ]
        ]
    , dialogView config session toSessionMsg
    ]
