port module Page.Try exposing
    ( Model
    , Msg
    , Status
    , init
    , subscriptions
    , update
    , view
    )

import Browser
import Elm.Error
import Errors
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Icon
import Json.Decode as Decode
import Json.Encode as Encode
import Layout.Header
import Route
import Svg.Attributes as SvgAttr


port setEditorContentAndRebuild : String -> Cmd msg


port rebuild : () -> Cmd msg


port rebuildResult : (Encode.Value -> msg) -> Sub msg



-- MODEL


type alias Model =
    { showPackages : Bool
    , status : Status
    , maybeResult : Maybe (Result Elm.Error.Error String)
    , example : Maybe Route.Example
    }


type Status
    = NotAsked
    | Compiling
    | Success
    | ProblemsFound


init : Maybe Route.Example -> ( Model, Cmd Msg )
init maybeExample =
    ( { showPackages = False
      , status =
            case maybeExample of
                Just _ ->
                    Compiling

                Nothing ->
                    NotAsked
      , maybeResult = Nothing
      , example = maybeExample
      }
    , case maybeExample of
        Just example ->
            Http.get
                { url = "/examples/" ++ Route.exampleSrc example ++ ".guida"
                , expect = Http.expectString GotExampleContent
                }

        Nothing ->
            Cmd.none
    )



-- UPDATE


type Msg
    = TogglePackages
    | GotExampleContent (Result Http.Error String)
    | Rebuild
    | RebuildResult Encode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TogglePackages ->
            ( { model | showPackages = not model.showPackages }, Cmd.none )

        GotExampleContent (Ok content) ->
            ( { model | status = Success }, setEditorContentAndRebuild content )

        GotExampleContent (Err _) ->
            ( { model | status = ProblemsFound }, Cmd.none )

        Rebuild ->
            ( { model | status = Compiling }, rebuild () )

        RebuildResult value ->
            case Decode.decodeValue decodeResult value of
                Ok result ->
                    ( { model
                        | status =
                            Result.map (\_ -> Success) result
                                |> Result.withDefault ProblemsFound
                        , maybeResult = Just result
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | status = ProblemsFound, maybeResult = Nothing }, Cmd.none )


decodeResult : Decode.Decoder (Result Elm.Error.Error String)
decodeResult =
    Decode.oneOf
        [ Decode.map Ok (Decode.field "output" Decode.string)
        , Decode.map Err (Decode.field "error" Elm.Error.decoder)
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    rebuildResult RebuildResult



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title =
        case model.example of
            Just Route.HelloWorld ->
                "Try Guida - Hello World!"

            Just Route.Buttons ->
                "Try Guida - Buttons"

            Nothing ->
                "Try Guida!"
    , body =
        [ Layout.Header.view (headerMode model) TogglePackages model.showPackages
        , Html.section [ Attr.class "h-screen pt-20 grid grid-cols-none grid-rows-2 sm:grid-cols-2 sm:grid-rows-none" ]
            [ Html.aside
                [ Attr.class "overflow-y-auto border-b  sm:border-b-0 sm:border-r border-gray-200"
                ]
                [ Html.node "wc-codemirror"
                    [ Attr.id "editor"
                    , Attr.class "h-full"
                    , Attr.attribute "mode" "javascript"
                    ]
                    []
                ]
            , Html.main_ [ Attr.class "overflow-y-auto" ] (outputView model)
            ]
        ]
    }


outputView : Model -> List (Html Msg)
outputView model =
    case ( model.example, model.maybeResult ) of
        ( Nothing, Nothing ) ->
            [ Html.div [ Attr.class "flex h-full" ]
                [ Html.div [ Attr.class "m-auto w-sm items-center" ]
                    [ Html.div
                        [ Attr.class "relative rounded-3xl bg-white p-8 ring-1 shadow-2xl ring-gray-900/10 sm:p-10"
                        ]
                        [ Html.h3 [ Attr.class "text-base/7 font-semibold text-amber-600" ]
                            [ Html.text "Online Editor" ]
                        , Html.p
                            [ Attr.class "mt-6 text-base/7 text-gray-600"
                            ]
                            [ Html.text "Write and compile code online!" ]
                        , Html.ul
                            [ Attr.attribute "role" "list"
                            , Attr.class "mt-8 space-y-1"
                            ]
                            [ Html.li []
                                [ Html.a
                                    [ Attr.href "/examples/hello"
                                    , Attr.class "group w-full flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600"
                                    ]
                                    [ Icon.logo [ SvgAttr.class "size-6 shrink-0 text-gray-400 group-hover:text-amber-600" ]
                                    , Html.text "Hello World!"
                                    ]
                                ]
                            , Html.li []
                                [ Html.a
                                    [ Attr.href "/examples/buttons"
                                    , Attr.class "group w-full flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600"
                                    ]
                                    [ Icon.logo [ SvgAttr.class "size-6 shrink-0 text-gray-400 group-hover:text-amber-600" ]
                                    , Html.text "Buttons"
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]

        ( Just _, Nothing ) ->
            []

        ( _, Just (Ok output) ) ->
            [ Html.iframe
                [ Attr.class "h-full w-full"
                , Attr.srcdoc output
                ]
                []
            ]

        ( _, Just (Err error) ) ->
            [ Errors.viewError error
            ]


headerMode : Model -> Layout.Header.Mode Msg
headerMode model =
    Layout.Header.Custom (Just (rebuildButton model)) [] []


rebuildButton : Model -> Layout.Header.Item Msg
rebuildButton model =
    case model.status of
        NotAsked ->
            Layout.Header.Button
                { label =
                    [ Icon.arrowPath [ SvgAttr.class "-ml-0.5 size-5" ]
                    , Html.text "Rebuild"
                    ]
                , msg = Layout.Header.Enabled Rebuild
                }

        Compiling ->
            Layout.Header.Button
                { label =
                    [ Icon.arrowPath [ SvgAttr.class "-ml-0.5 size-5 animate-spin" ]
                    , Html.text "Compiling..."
                    ]
                , msg = Layout.Header.Disabled
                }

        Success ->
            Layout.Header.Button
                { label =
                    [ Icon.check [ SvgAttr.class "-ml-0.5 size-5" ]
                    , Html.text "Success"
                    ]
                , msg = Layout.Header.Enabled Rebuild
                }

        ProblemsFound ->
            Layout.Header.Button
                { label =
                    [ Icon.xMark [ SvgAttr.class "-ml-0.5 size-5" ]
                    , Html.text "Problems found"
                    ]
                , msg = Layout.Header.Enabled Rebuild
                }
