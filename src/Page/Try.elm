port module Page.Try exposing (..)

import Browser
import Elm.Error
import Errors
import Html exposing (Html)
import Html.Attributes as Attr
import Json.Decode as Decode
import Json.Encode as Encode
import Layout.Header


port rebuild : () -> Cmd msg


port rebuildResult : (Encode.Value -> msg) -> Sub msg



-- MODEL


type alias Model =
    { showPackages : Bool
    , rebuilding : Bool
    , maybeResult : Maybe (Result Elm.Error.Error String)
    }


init : ( Model, Cmd Msg )
init =
    ( { showPackages = False
      , rebuilding = False
      , maybeResult = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = TogglePackages
    | Rebuild
    | RebuildResult Encode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TogglePackages ->
            ( { model | showPackages = not model.showPackages }, Cmd.none )

        Rebuild ->
            ( { model | rebuilding = True }, rebuild () )

        RebuildResult value ->
            case Decode.decodeValue decodeResult value of
                Ok result ->
                    ( { model | rebuilding = False, maybeResult = Just result }, Cmd.none )

                Err err ->
                    let
                        _ =
                            Debug.log "error" (Decode.errorToString err)
                    in
                    ( { model | rebuilding = False, maybeResult = Nothing }, Cmd.none )


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
    { title = "Try Guida!"
    , body =
        [ Layout.Header.view headerMode TogglePackages model.showPackages
        , Html.section [ Attr.class "h-screen pt-20 grid grid-cols-none grid-rows-2 sm:grid-cols-2 sm:grid-rows-none" ]
            [ Html.aside
                [ Attr.class "overflow-y-auto border-b  sm:border-b-0 sm:border-r border-gray-200"
                ]
                [ Html.node "wc-codemirror" [ Attr.id "editor", Attr.attribute "mode" "javascript", Attr.src "examples/Buttons.elm" ] []
                ]
            , Html.main_ [ Attr.class "overflow-y-auto" ]
                (outputView model)
            ]
        ]
    }


outputView : Model -> List (Html Msg)
outputView model =
    case model.maybeResult of
        Nothing ->
            [ Html.text "Hi! \\o/"
            ]

        Just (Ok output) ->
            [ Html.iframe
                [ Attr.class "h-full w-full"
                , Attr.srcdoc output
                ]
                []
            ]

        Just (Err error) ->
            [ Errors.viewError error
            ]


headerMode : Layout.Header.Mode Msg
headerMode =
    Layout.Header.Custom
        [ Layout.Header.Button
            { label = [ Html.text "Rebuild" ]
            , msg = Rebuild
            }
        ]
        []
