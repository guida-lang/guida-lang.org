module Layout.Navigation exposing
    ( Navigation
    , NavigationGroup
    , NavigationLink
    , NavigationSection
    , view
    )

import Components.Link as Link
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Layout.Global as Global


type alias Navigation route =
    List (NavigationGroup route)


type alias NavigationGroup route =
    { title : String
    , links : List (NavigationLink route)
    }


type alias NavigationLink route =
    { title : String
    , href : String
    , route : route
    , sections : List (NavigationSection route)
    }


type alias NavigationSection route =
    { title : String
    , href : String
    , route : route
    }


view : List (Html.Attribute msg) -> route -> Navigation route -> Html msg
view attrs currentRoute navigation =
    Html.nav attrs
        [ Html.ul [ Aria.role "list" ]
            (List.map topLevelNavItem Global.topLevelNavItems
                ++ List.indexedMap (navigationGroupView currentRoute) navigation
            )
        ]


topLevelNavItem : Global.NavItem msg -> Html msg
topLevelNavItem { href, children } =
    Html.li [ Attr.class "md:hidden" ]
        [ Link.view
            [ Attr.href href
            , Attr.class "block py-1 text-sm text-zinc-600 transition hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white"
            ]
            children
        ]


navigationGroupView : route -> Int -> NavigationGroup route -> Html msg
navigationGroupView currentRoute groupIndex navigationGroup =
    Html.li
        [ Attr.classList
            [ ( "relative mt-6", True )
            , ( "md:mt-0", groupIndex == 0 )
            ]
        ]
        [ Html.h2 [ Attr.class "text-xs font-semibold text-zinc-900 dark:text-white" ]
            [ Html.text (String.fromInt groupIndex ++ ". " ++ navigationGroup.title)
            ]
        , Html.div [ Attr.class "relative mt-3 pl-2" ]
            (Html.div [ Attr.class "absolute inset-y-0 left-2 w-px bg-zinc-900/10 dark:bg-white/5" ] []
                :: activePageMarker currentRoute navigationGroup
                ++ [ Html.ul [ Aria.role "list", Attr.class "border-l border-transparent" ]
                        (List.map (navigationLinkView currentRoute) navigationGroup.links)
                   ]
            )
        ]


navigationLinkView : route -> NavigationLink route -> Html msg
navigationLinkView currentRoute navigationLink =
    let
        sections : List (Html msg)
        sections =
            case navigationLink.sections of
                [] ->
                    []

                _ ->
                    [ Html.ul [ Aria.role "list" ]
                        (List.map (navigationSectionView currentRoute) navigationLink.sections)
                    ]

        active : Bool
        active =
            navigationLink.route == currentRoute
    in
    Html.li [ Attr.class "relative" ]
        (Link.view
            [ Attr.href navigationLink.href
            , Attr.classList
                [ ( "flex justify-between gap-2 py-1 pr-3 text-sm transition pl-4", True )
                , ( "text-zinc-900 dark:text-white", active )
                , ( "text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white", not active )
                ]
            ]
            [ Html.text navigationLink.title
            ]
            :: sections
        )


navigationSectionView : route -> NavigationSection route -> Html msg
navigationSectionView currentRoute section =
    let
        active : Bool
        active =
            section.route == currentRoute
    in
    Html.li []
        [ Link.view
            [ Attr.href section.href
            , Attr.classList
                [ ( "flex justify-between gap-2 py-1 pr-3 text-sm transition pl-7", True )
                , ( "text-zinc-900 dark:text-white", active )
                , ( "text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white", not active )
                ]
            ]
            [ Html.text section.title
            ]
        ]


activePageMarker : route -> NavigationGroup route -> List (Html msg)
activePageMarker currentRoute group =
    let
        maybeActivePageIndex : Maybe Int
        maybeActivePageIndex =
            List.concatMap (\link -> link.route :: List.map .route link.sections) group.links
                |> List.indexedMap Tuple.pair
                |> List.filter (\( _, route ) -> route == currentRoute)
                |> List.head
                |> Maybe.map Tuple.first
    in
    case maybeActivePageIndex of
        Nothing ->
            []

        Just activePageIndex ->
            let
                itemHeight : Float
                itemHeight =
                    2.0

                offset : Float
                offset =
                    0.25

                top : Float
                top =
                    offset + (toFloat activePageIndex * itemHeight)
            in
            [ Html.div
                [ Attr.class "absolute left-2 h-6 w-px bg-amber-500"
                , Attr.style "top" (String.fromFloat top ++ "rem")
                ]
                []
            ]
