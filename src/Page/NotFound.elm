module Page.NotFound exposing (view)

import Browser
import Components.Button as Button
import Components.HeroPattern as HeroPattern
import Html
import Html.Attributes as Attr
import Layout.Main as Layout
import Session exposing (Session)



-- VIEW


view : Session -> (Session.Msg -> msg) -> Browser.Document msg
view session toSessionMsg =
    { title = "Guida: Page not found"
    , body =
        Layout.view { sidebarNavigation = [], currentRoute = () } session toSessionMsg <|
            [ HeroPattern.view
            , Html.div [ Attr.class "mx-auto flex h-full max-w-xl flex-col items-center justify-center py-16 text-center" ]
                [ Html.p [ Attr.class "text-sm font-semibold text-zinc-900 dark:text-white" ] [ Html.text "404" ]
                , Html.h1 [ Attr.class "mt-2 text-2xl font-bold text-zinc-900 dark:text-white" ] [ Html.text "Page not found" ]
                , Html.p [ Attr.class "mt-2 text-base text-zinc-600 dark:text-zinc-400" ] [ Html.text "Sorry, we couldn't find the page you're looking for." ]
                , Html.div [ Attr.class "not-prose mb-16 flex gap-3" ]
                    [ Button.view (Button.Link "/") Button.Primary Nothing [ Attr.class "mt-8" ] [ Html.text "Go back home" ]
                    , Button.view (Button.Link "https://github.com/guida-lang/guida-lang.org/issues") Button.Outline (Just Button.RightArrow) [ Attr.class "mt-8" ] [ Html.text "File a bug" ]
                    ]
                ]
            ]
    }
