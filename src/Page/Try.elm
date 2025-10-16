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
import Html.Attributes.Aria as Aria
import Html.Events as Events
import Http
import Icon
import Json.Decode as Decode
import Json.Encode as Encode
import Layout.Main as Layout
import Route
import Session exposing (Session)
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
    , Cmd.batch
        [ case maybeExample of
            Just example ->
                Http.get
                    { url = "/example-files/" ++ Route.exampleSrc example ++ ".guida"
                    , expect = Http.expectString GotExampleContent
                    }

            Nothing ->
                Cmd.none
        , registryFetch
        ]
    )



-- UPDATE


type Msg
    = TogglePackages
    | GotExampleContent (Result Http.Error String)
    | Rebuild
    | RebuildResult Encode.Value
    | OnMouseOver DOM.Rectangle Int Int
    | GotRegistry (Result Http.Error (List Package))


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

        GotRegistry (Ok news) ->
            ( { model
                | registry =
                    registryInitialWithDefaults model.defaultDirect model.defaultIndirect
                        |> registryFromNews news
                        |> Fetched.Success
              }
            , Cmd.none
            )

        GotRegistry (Err ((Http.BadBody errMsg) as err)) ->
            ( { model | registry = Fetched.Failed err }, Cmd.none )


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
        Layout.fullscreenView session toSessionMsg packagesDialogView <|
            [ Html.section [ Attr.class "flex flex-col h-min-full md:h-full md:grid md:grid-cols-2 md:grid-rows-[1fr_min-content]" ]
                [ Html.div
                    [ Attr.class "h-full overflow-auto border-b md:border-b-0 md:border-r border-gray-200"
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
                    ]
                , Html.div [ Attr.class "flex  justify-between col-start-1 row-start-2 border-gray-200 border-b md:border-b-0 md:border-r md:border-t" ]
                    [ Html.aside []
                        [ Html.ul [ Aria.role "list", Attr.class "flex items-center gap-6" ]
                            [ Html.li []
                                [ Html.button
                                    [ Attr.class "flex gap-0.5 items-center py-0.5 px-2 text-sm/7 text-zinc-600 transition hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white"
                                    , Events.onClick (toMsg Rebuild)
                                    ]
                                    [ Html.text "Packages"
                                    ]
                                ]
                            ]
                        ]
                    , Html.aside []
                        [ Html.ul [ Aria.role "list", Attr.class "flex items-center gap-6" ]
                            [ Html.li [] [ rebuildButton toMsg model ]
                            ]
                        ]
                    ]
                , outputView toMsg model
                ]
            ]
    }


packagesDialogView : Html msg
packagesDialogView =
    let
        openAttrs : List (Html.Attribute msg)
        openAttrs =
            if True then
                [ Attr.attribute "open" "true" ]

            else
                []
    in
    Html.node "dialog"
        (Attr.class "fixed inset-0 z-50"
            :: openAttrs
        )
        [ Html.div
            [ Attr.class "fixed inset-0 top-14 bg-zinc-400/20 backdrop-blur-xs data-closed:opacity-0 data-enter:duration-300 data-enter:ease-out data-leave:duration-200 data-leave:ease-in dark:bg-black/40"

            -- , Events.onClick (toSessionMsg Session.ToggleMobileNavigation)
            ]
            []
        , Html.div [ Attr.class "fixed top-0 bottom-0 left-0 w-full overflow-y-auto bg-white px-4 pt-6 pb-4 ring-1 shadow-lg shadow-zinc-900/10 ring-zinc-900/7.5 duration-500 ease-in-out data-closed:-translate-x-full min-[416px]:max-w-sm sm:px-6 sm:pb-10 dark:bg-zinc-900 dark:ring-zinc-800" ]
            [ Html.nav
                [ Attr.class "relative flex flex-1 flex-col"
                ]
                [ Html.ul [ Aria.role "list", Attr.class "flex flex-1 flex-col gap-y-4" ]
                    [ Html.li []
                        [ Html.div
                            [ Attr.class "text-xs/6 font-semibold text-gray-400"
                            ]
                            [ Html.text "Installed" ]
                        , Html.ul
                            [ Aria.role "list"
                            , Attr.class "mt-2 space-y-1"
                            ]
                            [ Html.li
                                [ Attr.class "group flex justify-between gap-x-3 rounded-md p-1 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white"
                                ]
                                [ Html.span
                                    [ Attr.class "truncate"
                                    ]
                                    [ Html.text "elm/random" ]
                                , Html.div [ Attr.class "flex gap-x-3" ]
                                    [ Html.span [ Attr.class "flex size-6 shrink-0 items-center text-[0.625rem] font-medium text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ]
                                        [ Html.text "2.0.1" ]
                                    , Button.view Button.Button Button.Text Nothing [] [ Icon.lockClosed [ SvgAttr.class "h-5 w-5 text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ] ]
                                    ]
                                ]
                            ]
                        ]
                    , Html.li []
                        [ Html.div
                            [ Attr.class "text-xs/6 font-semibold text-gray-400"
                            ]
                            [ Html.text "Registry" ]
                        , Html.input
                            [ Attr.class "mt-2 block w-full rounded-md bg-white px-3 py-1.5 text-gray-900 outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500"
                            , Attr.type_ "search"
                            , Attr.id "registry-search"
                            , Attr.placeholder "Search"
                            , Aria.ariaLabel "Search"
                            ]
                            []
                        , Html.ul
                            [ Aria.role "list"
                            , Attr.class "mt-2 space-y-1"
                            ]
                            [ Html.li
                                [ Attr.class "group flex justify-between gap-x-3 rounded-md p-1 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white"
                                ]
                                [ Html.span
                                    [ Attr.class "truncate"
                                    ]
                                    [ Html.text "elm/html" ]
                                , Html.div [ Attr.class "flex gap-x-3" ]
                                    [ Html.span [ Attr.class "flex size-6 shrink-0 items-center text-[0.625rem] font-medium text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ]
                                        [ Html.text "1.0.0" ]
                                    , Button.view Button.Button Button.Text Nothing [] [ Icon.plus [ SvgAttr.class "h-5 w-5 text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ] ]
                                    ]
                                ]
                            , Html.li
                                [ Attr.class "group flex justify-between gap-x-3 rounded-md p-1 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white"
                                ]
                                [ Html.span
                                    [ Attr.class "truncate"
                                    ]
                                    [ Html.text "elm/random" ]
                                , Html.div [ Attr.class "flex gap-x-3" ]
                                    [ Html.span [ Attr.class "flex size-6 shrink-0 items-center text-[0.625rem] font-medium text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ]
                                        [ Html.text "2.0.1" ]
                                    , Button.view Button.Button Button.Text Nothing [] [ Icon.trash [ SvgAttr.class "h-5 w-5 text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ] ]
                                    ]
                                ]
                            , Html.li
                                [ Attr.class "group flex justify-between gap-x-3 rounded-md p-1 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white"
                                ]
                                [ Html.span
                                    [ Attr.class "truncate"
                                    ]
                                    [ Html.text "elm/random" ]
                                , Html.div [ Attr.class "flex gap-x-3" ]
                                    [ Html.span [ Attr.class "flex size-6 shrink-0 items-center text-[0.625rem] font-medium text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ]
                                        [ Html.text "2.0.1" ]
                                    , Button.view Button.Button Button.Text Nothing [] [ Icon.lockClosed [ SvgAttr.class "h-5 w-5 text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ] ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        ]


rebuildButton : (Msg -> msg) -> Model -> Html msg
rebuildButton toMsg model =
    case model.status of
        NotAsked ->
            Html.button
                [ Attr.class "flex gap-0.5 items-center py-0.5 px-2 text-sm/7 text-zinc-600 transition hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white"
                , Events.onClick (toMsg Rebuild)
                ]
                [ Icon.arrowPath [ SvgAttr.class "h-5 w-5" ]
                , Html.text "Rebuild"
                ]

        Compiling ->
            Html.button
                [ Attr.class "flex gap-0.5 items-center py-0.5 px-2 text-sm/7 text-zinc-600 transition hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white"
                , Attr.disabled True
                ]
                [ Icon.arrowPath [ SvgAttr.class "h-5 w-5 animate-spin" ]
                , Html.text "Compiling..."
                ]

        Success ->
            Html.button
                [ Attr.class "flex gap-0.5 items-center py-0.5 px-2 text-sm/7 text-zinc-600 transition hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white"
                , Events.onClick (toMsg Rebuild)
                ]
                [ Icon.check [ SvgAttr.class "h-5 w-5 text-green-600" ]
                , Html.text "Success"
                ]

        ProblemsFound ->
            Html.button
                [ Attr.class "flex gap-0.5 items-center py-0.5 px-2 text-sm/7 text-zinc-600 transition hover:text-zinc-900 dark:text-zinc-400 dark:hover:text-white"
                , Events.onClick (toMsg Rebuild)
                ]
                [ Icon.xMark [ SvgAttr.class "h-5 w-5 text-red-600" ]
                , Html.text "Problems found"
                ]


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
            Html.main_ [ Attr.class "row-span-2 overflow-y-auto bg-white" ]
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
