module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Icon
import Layout.Footer
import Layout.Header
import Svg
import Svg.Attributes as SvgAttr
import Url exposing (Url)



-- MODEL


type alias Model =
    { key : Nav.Key
    , year : Int
    , showNavigation : Bool
    }


type Theme
    = Light
    | Dark


init : Int -> Url -> Nav.Key -> ( Model, Cmd Msg )
init year url navKey =
    ( { key = navKey
      , year = year
      , showNavigation = False
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Guida"
    , body =
        [ Layout.Header.view ToggleNavigation model.showNavigation
        , Html.main_
            [ Attr.class "relative isolate px-6 pt-14 lg:px-8"
            ]
            [ Html.div
                [ Attr.class "absolute inset-x-0 -top-10 -z-10 transform-gpu overflow-hidden blur-3xl sm:-top-20"
                , Attr.attribute "aria-hidden" "true"
                ]
                [ Html.div
                    [ Attr.class "relative left-[calc(50%-11rem)] aspect-[1155/678] w-[36.125rem] bg-gradient-to-tr from-[#f54a00] to-[#fcc800] opacity-30 sm:-left-5 sm:w-[72.1875rem]"
                    , Attr.style "clip-path" "polygon(25% 0%,70% 0%,40% 35%,95% 35%,20% 100%,40% 55%,0% 55%)"
                    ]
                    []
                ]
            , Html.div
                [ Attr.class "mx-auto max-w-4xl py-32 sm:py-48 lg:py-56"
                ]
                [ Html.div
                    [ Attr.class "hidden sm:mb-8 sm:flex sm:justify-center"
                    ]
                    [ Html.div
                        [ Attr.class "relative rounded-full px-3 py-1 text-sm/6 text-gray-600 ring-1 ring-gray-900/10 hover:ring-gray-900/20"
                        ]
                        [ Html.text "Install Guida locally via npm "
                        , Html.a
                            [ Attr.href "/docs/install"
                            , Attr.class "font-semibold text-amber-600"
                            ]
                            [ Html.span
                                [ Attr.class "absolute inset-0"
                                , Attr.attribute "aria-hidden" "true"
                                ]
                                []
                            , Html.text "Read more "
                            , Html.span
                                [ Attr.attribute "aria-hidden" "true"
                                ]
                                [ Html.text "→" ]
                            ]
                        ]
                    ]
                , Html.div
                    [ Attr.class "text-center"
                    ]
                    [ Html.h1
                        [ Attr.class "text-balance text-5xl font-semibold tracking-tight text-gray-900 sm:text-7xl"
                        ]
                        [ Html.text "Guida: functional programming, evolved!" ]
                    , Html.p
                        [ Attr.class "mt-8 text-pretty text-lg font-medium text-gray-500 sm:text-xl/8"
                        ]
                        [ Html.text "Guida is a functional programming language that builds upon the solid foundation of Elm, offering backward compatibility with all existing Elm 0.19.1 projects." ]
                    , Html.div
                        [ Attr.class "mt-10 flex items-center justify-center gap-x-6"
                        ]
                        [ Html.a
                            [ Attr.href "/try"
                            , Attr.class "rounded-md bg-amber-600 px-3.5 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-amber-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-amber-600"
                            ]
                            [ Html.text "Try Guida" ]
                        , Html.a
                            [ Attr.href "/docs"
                            , Attr.class "text-sm/6 font-semibold text-gray-900"
                            ]
                            [ Html.text "Documentation "
                            , Html.span
                                [ Attr.attribute "aria-hidden" "true"
                                ]
                                [ Html.text "→" ]
                            ]
                        ]
                    ]
                ]
            ]
        , Layout.Footer.view model.year
        ]
    }



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | ToggleNavigation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangedUrl _ ->
            ( model, Cmd.none )

        ClickedLink urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ToggleNavigation ->
            ( { model | showNavigation = not model.showNavigation }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


type alias Flags =
    Int


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
