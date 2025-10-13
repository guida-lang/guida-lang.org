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
import Components.Button as Button
import Components.ResourcePattern as ResourcePattern
import Components.ThemeToggle as ThemeToggle
import DOM
import Elm.Error
import Errors
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Layout.Main as Layout
import Route
import Session exposing (Session)


port setEditorContentAndRebuild : String -> Cmd msg


port rebuild : () -> Cmd msg


port rebuildResult : (Encode.Value -> msg) -> Sub msg



-- MODEL


type alias Model =
    { showPackages : Bool
    , status : Status
    , maybeResult : Maybe (Result Elm.Error.Error String)
    , example : Maybe Route.Example
    , mouseX : Int
    , mouseY : Int
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
      , mouseX = 0
      , mouseY = 0
      }
    , case maybeExample of
        Just example ->
            Http.get
                { url = "/example-files/" ++ Route.exampleSrc example ++ ".guida"
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
    | OnMouseOver DOM.Rectangle Int Int


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

        OnMouseOver { left, top } clientX clientY ->
            ( { model | mouseX = clientX - round left, mouseY = clientY - round top }, Cmd.none )


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


view : Session -> (Session.Msg -> msg) -> (Msg -> msg) -> Model -> Browser.Document msg
view session toSessionMsg toMsg model =
    { title =
        case model.example of
            Just Route.Animation ->
                "Try Guida - Animation"

            Just Route.Book ->
                "Try Guida - Book"

            Just Route.Buttons ->
                "Try Guida - Buttons"

            Just Route.Cards ->
                "Try Guida - Cards"

            Just Route.Clock ->
                "Try Guida - Clock"

            Just Route.Crate ->
                "Try Guida - Crate"

            Just Route.Cube ->
                "Try Guida - Cube"

            Just Route.DragAndDrop ->
                "Try Guida - Drag-and-drop"

            Just Route.FirstPerson ->
                "Try Guida - First person"

            Just Route.Forms ->
                "Try Guida - Forms"

            Just Route.Groceries ->
                "Try Guida - Groceries"

            Just Route.Hello ->
                "Try Guida - Hello World!"

            Just Route.ImagePreviews ->
                "Try Guida - Image previews"

            Just Route.Keyboard ->
                "Try Guida - Keyboard"

            Just Route.Mario ->
                "Try Guida - Mario"

            Just Route.Mouse ->
                "Try Guida - Mouse"

            Just Route.Numbers ->
                "Try Guida - Numbers"

            Just Route.Picture ->
                "Try Guida - Picture"

            Just Route.Positions ->
                "Try Guida - Positions"

            Just Route.Quotes ->
                "Try Guida - Quotes"

            Just Route.Shapes ->
                "Try Guida - Shapes"

            Just Route.TextFields ->
                "Try Guida - Text fields"

            Just Route.Thwomp ->
                "Try Guida - Thwomp"

            Just Route.Time ->
                "Try Guida - Time"

            Just Route.Triangle ->
                "Try Guida - Triangle"

            Just Route.Turtle ->
                "Try Guida - Turtle"

            Just Route.Upload ->
                "Try Guida - Upload"

            Nothing ->
                "Try Guida!"
    , body =
        Layout.fullscreenView session toSessionMsg <|
            [ Html.section [ Attr.class "h-full grid grid-cols-none grid-rows-2 sm:grid-cols-2 sm:grid-rows-none" ]
                [ Html.aside
                    [ Attr.class "grid grid-cols-none grid-rows-2 overflow-y-hidden border-b sm:border-b-0 sm:border-r border-gray-200"
                    ]
                    [ Html.node "wc-codemirror"
                        [ Attr.id "editor"
                        , Attr.class "h-full"
                        , Attr.attribute "mode" "guida"
                        , Attr.attribute "theme"
                            (case Session.theme session of
                                ThemeToggle.Dark ->
                                    "xq-dark"

                                ThemeToggle.Light ->
                                    "xq-light"
                            )
                        ]
                        [ Html.node "link" [ Attr.rel "stylesheet", Attr.href "/codemirror/theme/xq-dark.css" ] []
                        , Html.node "link" [ Attr.rel "stylesheet", Attr.href "/codemirror/theme/xq-light.css" ] []
                        ]
                    , Html.div []
                        [ Button.view Button.Button Button.Primary Nothing [ Events.onClick (toMsg Rebuild) ] [ Html.text "rebuild" ]
                        ]
                    ]
                , outputView toMsg model
                ]
            ]
    }


outputView : (Msg -> msg) -> Model -> Html msg
outputView toMsg model =
    case ( model.example, model.maybeResult ) of
        ( Nothing, Nothing ) ->
            Html.main_ [ Attr.class "overflow-y-auto" ]
                [ Html.div [ Attr.class "flex h-full" ]
                    [ Html.div [ Attr.class "m-auto w-sm items-center" ]
                        [ Html.div
                            [ Attr.class "my-4 group relative flex rounded-2xl bg-zinc-50 transition-shadow hover:shadow-md hover:shadow-zinc-900/5 dark:bg-white/2.5 dark:hover:shadow-black/5"
                            , Events.on "mouseover" (Decode.map3 (\rectangle clientX clientY -> toMsg (OnMouseOver rectangle clientX clientY)) (DOM.currentTarget DOM.boundingClientRect) (Decode.field "clientX" Decode.int) (Decode.field "clientY" Decode.int))
                            ]
                            [ ResourcePattern.view { mouseX = model.mouseX, mouseY = model.mouseY }
                            , Html.div [ Attr.class "absolute inset-0 rounded-2xl ring-1 ring-zinc-900/7.5 ring-inset group-hover:ring-zinc-900/10 dark:ring-white/10 dark:group-hover:ring-white/20" ] []
                            , Html.div [ Attr.class "relative rounded-2xl px-4 pt-8 pb-4" ]
                                [ Html.h2 [ Attr.class "mt-4 text-sm/7 font-semibold text-zinc-900 dark:text-white" ]
                                    [ Html.text "Online Editor" ]
                                , Html.p [ Attr.class "mt-1 text-sm text-zinc-600 dark:text-zinc-400" ]
                                    [ Html.text "Write and compile code online!" ]
                                , Html.ul []
                                    [ Html.li []
                                        [ Button.view (Button.Link "/examples/hello") Button.Text Nothing [] [ Html.text "Hello World!" ]
                                        ]
                                    , Html.li []
                                        [ Button.view (Button.Link "/examples/buttons") Button.Text Nothing [] [ Html.text "Buttons" ]
                                        ]
                                    , Html.li []
                                        [ Button.view (Button.Link "/examples/clock") Button.Text Nothing [] [ Html.text "Clock" ]
                                        ]
                                    , Html.li []
                                        [ Button.view (Button.Link "/examples/quotes") Button.Text Nothing [] [ Html.text "HTTP" ]
                                        ]
                                    , Html.li []
                                        [ Button.view (Button.Link "/examples/cards") Button.Text Nothing [] [ Html.text "Cards" ]
                                        ]
                                    , Html.li []
                                        [ Button.view (Button.Link "/examples") Button.Text Nothing [] [ Html.text "More!" ]
                                        ]
                                    ]
                                , Html.p [ Attr.class "mt-1 text-sm text-zinc-600 dark:text-zinc-400" ]
                                    [ Html.text "Explore the "
                                    , Button.view (Button.Link "/docs") Button.Text Nothing [] [ Html.text "official documentation" ]
                                    , Html.text " to learn how to get started with Guida."
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]

        ( Just _, Nothing ) ->
            Html.main_ [ Attr.class "overflow-y-auto" ] []

        ( _, Just (Ok output) ) ->
            Html.main_ [ Attr.class "overflow-y-auto bg-white" ]
                [ Html.iframe
                    [ Attr.class "h-full w-full"
                    , Attr.srcdoc output
                    ]
                    []
                ]

        ( _, Just (Err error) ) ->
            Html.main_ [ Attr.class "overflow-y-auto bg-white" ]
                [ Errors.viewError error
                ]



-- headerMode : Model -> Layout.Header.Mode Msg
-- headerMode model =
--     Layout.Header.Custom (Just (rebuildButton model)) [] []
-- rebuildButton : Model -> Layout.Header.Item Msg
-- rebuildButton model =
--     case model.status of
--         NotAsked ->
--             Layout.Header.Button
--                 { label =
--                     [ Icon.arrowPath [ SvgAttr.class "-ml-0.5 size-5" ]
--                     , Html.text "Rebuild"
--                     ]
--                 , msg = Layout.Header.Enabled Rebuild
--                 }
--         Compiling ->
--             Layout.Header.Button
--                 { label =
--                     [ Icon.arrowPath [ SvgAttr.class "-ml-0.5 size-5 animate-spin" ]
--                     , Html.text "Compiling..."
--                     ]
--                 , msg = Layout.Header.Disabled
--                 }
--         Success ->
--             Layout.Header.Button
--                 { label =
--                     [ Icon.check [ SvgAttr.class "-ml-0.5 size-5" ]
--                     , Html.text "Success"
--                     ]
--                 , msg = Layout.Header.Enabled Rebuild
--                 }
--         ProblemsFound ->
--             Layout.Header.Button
--                 { label =
--                     [ Icon.xMark [ SvgAttr.class "-ml-0.5 size-5" ]
--                     , Html.text "Problems found"
--                     ]
--                 , msg = Layout.Header.Enabled Rebuild
--                 }
