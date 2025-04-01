port module Page.Try exposing (..)

import Browser
import Html
import Html.Attributes as Attr
import Json.Encode as Encode
import Layout.Header


port rebuild : () -> Cmd msg


port rebuildResult : (Encode.Value -> msg) -> Sub msg



-- MODEL


type alias Model =
    { showPackages : Bool
    , rebuilding : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { showPackages = False
      , rebuilding = False
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = TogglePackages
    | Rebuild
    | RebuildResult


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TogglePackages ->
            ( { model | showPackages = not model.showPackages }, Cmd.none )

        Rebuild ->
            ( { model | rebuilding = True }, rebuild () )

        RebuildResult ->
            ( { model | rebuilding = False }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    rebuildResult (\_ -> RebuildResult)



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Try Guida!"
    , body =
        [ Layout.Header.view headerMode TogglePackages model.showPackages
        , Html.section [ Attr.class "h-screen pt-20 grid grid-cols-none grid-rows-2 sm:grid-cols-2 sm:grid-rows-none " ]
            [ Html.aside
                [ Attr.class "overflow-y-auto border-r border-gray-200"
                ]
                [ Html.node "wc-codemirror" [ Attr.id "editor", Attr.attribute "mode" "javascript", Attr.src "examples/Buttons.elm" ] []
                ]
            , Html.main_ [ Attr.class "overflow-y-auto" ]
                [ Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                , Html.p [] [ Html.text "Hello world!" ]
                ]
            ]
        ]
    }


headerMode : Layout.Header.Mode Msg
headerMode =
    Layout.Header.Custom
        [ Layout.Header.Button
            { label = [ Html.text "Rebuild" ]
            , msg = Rebuild
            }
        ]
        []
