module Page.NotFound exposing (view)

import Browser
import Html
import Html.Attributes as Attr



-- VIEW


view : Browser.Document Never
view =
    { title = "Guida"
    , body =
        [ Html.main_ [ Attr.class "grid min-h-full place-items-center bg-white px-6 py-24 sm:py-32 lg:px-8" ]
            [ Html.div [ Attr.class "text-center" ]
                [ Html.p [ Attr.class "text-base font-semibold text-amber-600" ]
                    [ Html.text "404" ]
                , Html.h1 [ Attr.class "mt-4 text-5xl font-semibold tracking-tight text-balance text-gray-900 sm:text-7xl" ]
                    [ Html.text "Page not found" ]
                , Html.p [ Attr.class "mt-6 text-lg font-medium text-pretty text-gray-500 sm:text-xl/8" ]
                    [ Html.text "Sorry, we couldn't find the page you're looking for." ]
                , Html.div [ Attr.class "mt-10 flex items-center justify-center gap-x-6" ]
                    [ Html.a
                        [ Attr.href "/"
                        , Attr.class "rounded-md bg-amber-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-xs hover:bg-amber-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-amber-600"
                        ]
                        [ Html.text "Go back home" ]
                    , Html.a
                        [ Attr.href "/"
                        , Attr.class "text-sm font-semibold text-gray-900"
                        ]
                        [ Html.text "Contact support "
                        , Html.span [ Attr.attribute "aria-hidden" "true" ]
                            [ Html.text "→" ]
                        ]
                    ]
                ]
            ]
        ]
    }
