module Layout.Navigation exposing
    ( Navigation
    , NavigationLink
    , view
    )

import Components.Link as Link
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Layout.Global as Global


type alias Navigation =
    List NavigationGroup


type alias NavigationGroup =
    { title : String
    , links : List NavigationLink
    }


type alias NavigationLink =
    { title : String
    , href : String
    , active : Bool
    }


view : List (Html.Attribute msg) -> Navigation -> Html msg
view attrs navigation =
    Html.nav attrs
        [ Html.ul [ Aria.role "list" ]
            (List.map topLevelNavItem Global.topLevelNavItems
                ++ List.indexedMap navigationGroupView navigation
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


navigationGroupView : Int -> NavigationGroup -> Html msg
navigationGroupView groupIndex navigationGroup =
    Html.li
        [ Attr.classList
            [ ( "relative mt-6", True )
            , ( "md:mt-0", groupIndex == 0 )
            ]
        ]
        [ Html.h2 [ Attr.class "text-xs font-semibold text-zinc-900 dark:text-white" ]
            [ Html.text navigationGroup.title
            ]
        , Html.div [ Attr.class "relative mt-3 pl-2" ]
            (Html.div [ Attr.class "absolute inset-y-0 left-2 w-px bg-zinc-900/10 dark:bg-white/5" ] []
                :: activePageMarker navigationGroup
                ++ [ Html.ul [ Aria.role "list", Attr.class "border-l border-transparent" ]
                        (List.map navigationLinkView navigationGroup.links)
                   ]
            )
        ]


navigationLinkView : NavigationLink -> Html msg
navigationLinkView navigationLink =
    Html.li [ Attr.class "relative" ]
        [ Link.view
            [ Attr.href navigationLink.href
            , Attr.classList
                [ ( "flex justify-between gap-2 py-1 pr-3 text-sm transition", True )
                , ( "pl-4", True )
                , ( "text-zinc-900 dark:text-white", navigationLink.active )
                , ( "text-zinc-600 hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white", not navigationLink.active )
                ]
            ]
            [ Html.text navigationLink.title
            ]
        ]


activePageMarker : NavigationGroup -> List (Html msg)
activePageMarker group =
    let
        maybeActivePageIndex =
            List.indexedMap Tuple.pair group.links
                |> List.filter (\( _, link ) -> link.active)
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
