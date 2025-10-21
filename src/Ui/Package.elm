module Ui.Package exposing
    ( Model
    , Msg
    , init
    , open
    , subscriptions
    , update
    , view
    )

import Components.Button as Button
import Data.Fetched as Fetched
import Data.Http
import Data.Problem as Problem
import Data.Registry as Registry
import Data.Registry.Defaults as Defaults
import Data.Registry.Package as Package
import Data.Registry.Solution as Solution exposing (Solution)
import Data.Registry.Status as Status
import Data.Version as V
import Dict
import Element exposing (Attr)
import Elm.Error as Error
import FeatherIcons
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Attributes.Aria as Aria
import Html.Events as Events
import Html.Keyed as HK
import Html.Lazy as HL
import Http
import Icon
import Json.Decode as Decode
import Json.Encode as E
import Process
import Svg exposing (Svg)
import Svg.Attributes as SvgAttr
import Task
import Ui.Icon
import Ui.Navigation


type alias Model =
    { query : String
    , registry : Fetched.Fetched Registry.Registry
    , hash : Maybe String
    , debounce : Int
    , defaultDirect : List Package.Package
    , defaultIndirect : List Package.Package
    , isOpen : Bool
    }


init : List Package.Package -> List Package.Package -> ( Model, Cmd Msg )
init direct indirect =
    ( { query = ""
      , registry = Fetched.Loading
      , hash = Nothing
      , debounce = 0
      , defaultDirect = direct
      , defaultIndirect = indirect
      , isOpen = False
      }
    , Registry.fetch GotRegistry
    )


width : Int
width =
    350


widthPx : String
widthPx =
    String.fromInt width ++ "px"


getRegistry : Model -> Registry.Registry
getRegistry model =
    case model.registry of
        Fetched.Loading ->
            Registry.initialWithDefaults model.defaultDirect model.defaultIndirect

        Fetched.Failed _ ->
            Registry.initialWithDefaults model.defaultDirect model.defaultIndirect

        Fetched.Success registry ->
            registry


getSolution : Model -> Solution.Solution
getSolution model =
    Solution.toSolution (Dict.values (getRegistry model))


getProblems : Model -> Maybe Problem.Problems
getProblems model =
    Registry.getErrors (getRegistry model)
        -- |> List.filterMap Data.Http.onlyDecodedErrors
        -- TODO
        |> Problem.toManyIndexedProblems
        |> Problem.init


dismissAll : Model -> Model
dismissAll model =
    (\( m, _, _ ) -> m) <|
        updateRegistry model False <|
            \registry ->
                ( model, Registry.dismissAll registry, Cmd.none )


open : Model -> Model
open model =
    { model | isOpen = True }



-- UPDATE


type Msg
    = GotRegistry (Result Http.Error (List Package.Package))
    | OnQuery String
    | OnDebounce
    | OnInstall Package.Package
    | OnUninstall Package.Package
    | OnDismiss Package.Package
    | OnEdited { packageString : String, versionString : String, result : E.Value }
    | OnReportResult (Result Http.Error String)
    | OnClose


update : Msg -> Model -> ( Model, Bool, Cmd Msg )
update msg model =
    case msg of
        GotRegistry (Ok news) ->
            ( { model
                | registry =
                    Registry.initialWithDefaults model.defaultDirect model.defaultIndirect
                        |> Registry.fromNews news
                        |> Fetched.Success
              }
            , False
            , Cmd.none
            )

        GotRegistry (Err err) ->
            ( { model | registry = Fetched.Failed err }
            , False
            , Cmd.none
            )

        OnQuery query ->
            ( { model | query = query, debounce = model.debounce + 1 }
            , False
            , Task.perform (\_ -> OnDebounce) (Process.sleep 300)
            )

        OnDebounce ->
            ( { model | debounce = model.debounce - 1 }
            , False
            , Cmd.none
            )

        OnInstall package ->
            updateRegistry model False <|
                \registry ->
                    ( model
                    , Registry.setStatus package Status.Loading registry
                    , Registry.attemptEdit Registry.Install package
                    )

        OnUninstall package ->
            updateRegistry model False <|
                \registry ->
                    ( model
                    , Registry.setStatus package Status.Loading registry
                    , Registry.attemptEdit Registry.Uninstall package
                    )

        OnDismiss package ->
            updateRegistry model False <|
                \registry ->
                    ( model
                    , Registry.setStatus package Status.NotInstalled registry
                    , Cmd.none
                    )

        OnEdited { packageString, versionString, result } ->
            case ( String.split "/" packageString, List.map String.toInt (String.split "." versionString), Decode.decodeValue resultDecoder result ) of
                ( [ author, project ], [ Just major, Just minor, Just patch ], Ok (Ok solution) ) ->
                    let
                        package : Package.Package
                        package =
                            { author = author
                            , project = project
                            , version = V.Version major minor patch
                            }
                    in
                    updateRegistry model True <|
                        \registry ->
                            ( model
                            , registry
                                |> Registry.setStatus package Status.NotInstalled
                                |> Registry.fromSolution solution
                            , Cmd.none
                            )

                ( [ author, project ], [ Just major, Just minor, Just patch ], Ok (Err err) ) ->
                    let
                        package : Package.Package
                        package =
                            { author = author
                            , project = project
                            , version = V.Version major minor patch
                            }
                    in
                    updateRegistry model False <|
                        \registry ->
                            ( model
                            , Registry.setStatus package (Status.Failed err) registry
                            , Cmd.none
                            )

                _ ->
                    ( model, False, Cmd.none )

        OnReportResult _ ->
            ( model, False, Cmd.none )

        OnClose ->
            ( { model | isOpen = False }, False, Cmd.none )


resultDecoder : Decode.Decoder (Result Error.Error Solution)
resultDecoder =
    Decode.oneOf
        [ Decode.map Ok Solution.decoder
        , Decode.map Err Error.decoder
        ]


updateRegistry : Model -> Bool -> (Registry.Registry -> ( Model, Registry.Registry, Cmd Msg )) -> ( Model, Bool, Cmd Msg )
updateRegistry model shouldRebuild updater =
    case model.registry of
        Fetched.Loading ->
            ( model, shouldRebuild, Cmd.none )

        Fetched.Failed _ ->
            ( model, shouldRebuild, Cmd.none )

        Fetched.Success registry ->
            let
                ( newModel, newRegistry, cmd ) =
                    updater registry
            in
            ( { newModel | registry = Fetched.Success newRegistry }, shouldRebuild, cmd )



-- SUBSCRIPTIONS


subscriptions : Sub Msg
subscriptions =
    Sub.batch
        [ Registry.installResult OnEdited
        , Registry.uninstallResult OnEdited
        ]



-- VIEW


view : Model -> Html Msg
view model =
    let
        openAttrs : List (Html.Attribute msg)
        openAttrs =
            if model.isOpen then
                [ Attr.attribute "open" "true" ]

            else
                []
    in
    Html.node "dialog"
        (Attr.class "backdrop:bg-transparent z-50"
            :: openAttrs
        )
        [ Html.div [ Attr.class "fixed inset-0 bg-gray-900/80 transition-opacity duration-300 ease-linear data-closed:opacity-0" ] []
        , Html.div [ Attr.class "fixed inset-0 flex focus:outline-none" ]
            [ Html.div [ Attr.class "group/dialog-panel relative mr-16 flex w-full max-w-xs flex-1 transform transition duration-300 ease-in-out data-closed:-translate-x-full" ]
                [ Html.div [ Attr.class "absolute top-0 left-full flex w-16 justify-center pt-5 duration-300 ease-in-out group-data-closed/dialog-panel:opacity-0" ]
                    [ Html.button
                        [ Attr.type_ "button"
                        , Attr.class "-m-2.5 p-2.5"
                        , Events.onClick OnClose
                        ]
                        [ Html.span [ Attr.class "sr-only" ]
                            [ Html.text "Close sidebar"
                            ]
                        , Icon.xMark [ SvgAttr.class "size-6 text-white" ]
                        ]
                    ]
                , Html.div
                    [ Attr.class "fixed top-0 bottom-0 left-0 w-full overflow-y-auto bg-white px-4 pt-6 pb-4 ring-1 shadow-lg shadow-zinc-900/10 ring-zinc-900/7.5 duration-500 ease-in-out data-closed:-translate-x-full min-[416px]:max-w-sm sm:px-6 sm:pb-10 dark:bg-zinc-900 dark:ring-zinc-800" ]
                    [ Html.nav
                        [ Attr.class "relative flex flex-1 flex-col"
                        ]
                        [ viewRegistry model
                        ]
                    ]
                ]
            ]
        ]



-- VIEW REGISTRY


viewRegistry : Model -> Html Msg
viewRegistry model =
    let
        direct =
            getRegistry model
                |> Registry.filterStatus Status.isDirectDep
                |> Registry.getValues

        failed =
            getRegistry model
                |> Registry.filterStatus Status.isFailed
                |> Registry.getValues
    in
    case model.registry of
        Fetched.Loading ->
            Icon.arrowPath [ SvgAttr.class "h-5 w-5 text-gray-400 dark:text-gray-500 animate-spin" ]

        Fetched.Failed _ ->
            Html.div [ Attr.class "rounded-md bg-red-50 p-3 dark:bg-red-500/15 dark:outline dark:outline-red-500/25" ]
                [ Html.div [ Attr.class "flex" ]
                    [ Html.div [ Attr.class "shrink-0" ]
                        [ Icon.exclamationCircle [ SvgAttr.class "size-5 text-red-400" ]
                        ]
                    , Html.div
                        [ Attr.class "ml-2"
                        ]
                        [ Html.h3
                            [ Attr.class "text-sm text-red-800 dark:text-red-200"
                            ]
                            [ Html.text "Could not fetch packages! Please try again later." ]
                        ]
                    ]
                ]

        Fetched.Success registry ->
            Html.ul [ Aria.role "list", Attr.class "flex flex-1 flex-col gap-y-4" ]
                [ Html.li []
                    [ Html.div
                        [ Attr.class "text-xs/6 font-semibold text-gray-400"
                        ]
                        [ Html.text "Installed" ]
                    , HK.ul
                        [ Aria.role "list"
                        , Attr.class "mt-2 space-y-1"
                        ]
                        (List.map viewKeyedPackage direct)
                    , HK.ul
                        [ Aria.role "list"
                        , Attr.class "mt-2 space-y-1"
                        ]
                        (List.map viewKeyedPackage failed)
                    ]
                , Html.li []
                    [ Html.div
                        [ Attr.class "text-xs/6 font-semibold text-gray-400"
                        ]
                        [ Html.text "Registry" ]
                    , viewQuery model
                    , if String.isEmpty model.query then
                        HL.lazy viewPopular registry

                      else if model.debounce /= 0 then
                        Html.div [ Attr.class "mt-2" ]
                            [ Icon.arrowPath [ SvgAttr.class "h-5 w-5 text-gray-400 dark:text-gray-500 animate-spin" ] ]

                      else
                        viewSearchResults model registry
                    ]
                ]



-- VIEW POPULAR


viewPopular : Registry.Registry -> Html Msg
viewPopular registry =
    let
        popular =
            registry
                |> Registry.filterStatus Status.isSearchable
                |> Registry.filterKeys Defaults.popular
    in
    HK.ul
        [ Aria.role "list"
        , Attr.class "mt-2 space-y-1"
        ]
        (List.map viewKeyedPackage popular)



-- VIEW SEARCH RESULTS


viewQuery : Model -> Html Msg
viewQuery model =
    Html.input
        [ Attr.class "mt-2 block w-full rounded-md bg-white px-3 py-1.5 text-gray-900 outline-1 -outline-offset-1 outline-gray-300 placeholder:text-gray-400 focus:outline-2 focus:-outline-offset-2 focus:outline-indigo-600 sm:text-sm/6 dark:bg-white/5 dark:text-white dark:outline-white/10 dark:placeholder:text-gray-500 dark:focus:outline-indigo-500"
        , Attr.type_ "search"
        , Attr.id "registry-search"
        , Attr.placeholder "Search"
        , Attr.value model.query
        , Aria.ariaLabel "Search"
        , Events.onInput OnQuery
        ]
        []


viewSearchResults : Model -> Registry.Registry -> Html Msg
viewSearchResults model registry =
    let
        results =
            registry
                |> Registry.filterStatus Status.isSearchable
                |> Registry.getValues
                |> Registry.search model.query
    in
    HK.ul
        [ Aria.role "list"
        , Attr.class "mt-2 space-y-1"
        ]
        (List.map viewKeyedPackage results)



-- KEYED CONTAINER


viewKeyedContainer : List (Html.Attribute msg) -> List ( String, Html msg ) -> Html msg
viewKeyedContainer attrs =
    HK.node "div" (attrs ++ [ Attr.id "package-options" ])


viewKeyedPackage : ( Package.Package, Status.Status ) -> ( String, Html Msg )
viewKeyedPackage ( package, state ) =
    ( Package.toName package
    , HL.lazy viewPackage ( package, state )
    )



-- VIEW PACKAGE


viewPackage : ( Package.Package, Status.Status ) -> Html Msg
viewPackage ( package, state ) =
    --                         [ Html.li
    --                             [ Attr.class "group flex justify-between gap-x-3 rounded-md p-1 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white"
    --                             ]
    --                             [ Html.span
    --                                 [ Attr.class "truncate"
    --                                 ]
    --                                 [ Html.text "elm/html" ]
    --                             , Html.div [ Attr.class "flex gap-x-3" ]
    --                                 [ Html.span [ Attr.class "flex size-6 shrink-0 items-center text-[0.625rem] font-medium text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ]
    --                                     [ Html.text "1.0.0" ]
    --                                 , Button.view Button.Button Button.Text Nothing [] [ Icon.plus [ SvgAttr.class "h-5 w-5 text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ] ]
    --                                 ]
    --                             ]
    --                         , Html.li
    --                             [ Attr.class "group flex justify-between gap-x-3 rounded-md p-1 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white"
    --                             ]
    --                             [ Html.span
    --                                 [ Attr.class "truncate"
    --                                 ]
    --                                 [ Html.text "elm/random" ]
    --                             , Html.div [ Attr.class "flex gap-x-3" ]
    --                                 [ Html.span [ Attr.class "flex size-6 shrink-0 items-center text-[0.625rem] font-medium text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ]
    --                                     [ Html.text "2.0.1" ]
    --                                 , Button.view Button.Button Button.Text Nothing [] [ Icon.trash [ SvgAttr.class "h-5 w-5 text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ] ]
    --                                 ]
    --                             ]
    --                         , Html.li
    --                             [ Attr.class "group flex justify-between gap-x-3 rounded-md p-1 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white"
    --                             ]
    --                             [ Html.span
    --                                 [ Attr.class "truncate"
    --                                 ]
    --                                 [ Html.text "elm/random" ]
    --                             , Html.div [ Attr.class "flex gap-x-3" ]
    --                                 [ Html.span [ Attr.class "flex size-6 shrink-0 items-center text-[0.625rem] font-medium text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ]
    --                                     [ Html.text "2.0.1" ]
    --                                 , Button.view Button.Button Button.Text Nothing [] [ Icon.lockClosed [ SvgAttr.class "h-5 w-5 text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ] ]
    --                                 ]
    --                             ]
    --                         ]
    Html.li [ Attr.class "group flex justify-between gap-x-3 rounded-md p-1 text-sm/6 font-semibold text-gray-700 hover:bg-gray-50 hover:text-amber-600 dark:text-gray-400 dark:hover:bg-white/5 dark:hover:text-white" ] <|
        case state of
            Status.NotInstalled ->
                viewOkPackage package
                    [ viewPackageVersion package.version
                    , viewButtonIcon "Install" Icon.plus (OnInstall package)
                    ]

            Status.IndirectDep version ->
                viewOkPackage package
                    [ viewPackageVersion version
                    , viewButtonIcon "Install" Icon.plus (OnInstall package)
                    ]

            Status.Loading ->
                viewOkPackage package
                    [ viewPackageVersion package.version
                    , viewSimpleIcon [ SvgAttr.class "animate-spin" ] Icon.arrowPath
                    ]

            Status.DirectDep version ->
                viewOkPackage package
                    [ viewPackageVersion version
                    , if List.member (Package.toKey package) Defaults.locked then
                        viewSimpleIcon [] Icon.lockClosed

                      else
                        viewButtonIcon "Uninstall" Icon.trash (OnUninstall package)
                    ]

            Status.Failed err ->
                viewErrorPackage package err


viewOkPackage : Package.Package -> List (Html Msg) -> List (Html Msg)
viewOkPackage pkg actions =
    [ Html.span [ Attr.class "truncate" ] [ viewPackageName pkg ]
    , Html.div [ Attr.class "flex gap-x-3 items-center" ] actions
    ]


viewErrorPackage : Package.Package -> Error.Error -> List (Html Msg)
viewErrorPackage package error =
    let
        viewErrorIcon =
            Ui.Icon.simpleIcon
                [ Attr.style "padding-right" "5px"
                , Attr.style "top" "1px"
                , Attr.style "width" "20px"
                ]
                (Just "red")
                FeatherIcons.alertCircle
    in
    [ Html.div
        [ Attr.class "package-option__left"
        , Attr.style "display" "flex"
        , Attr.style "font-size" "12px"
        ]
        [ viewErrorIcon
        , Html.div
            [ Attr.class "package-option__error" ]
            [ Html.text "Could not install "
            , Html.span
                [ Attr.style "font-weight" "bold" ]
                [ viewPackageDocsLink package <|
                    Package.toName package
                        ++ " "
                        ++ V.toString package.version
                ]
            , Html.text "."
            ]
        ]
    , Html.div
        [ Attr.class "package-option__right" ]
        [ viewButtonIcon "Dismiss" Icon.xMark (OnDismiss package) ]
    ]


viewPackageName : Package.Package -> Html Msg
viewPackageName pkg =
    viewPackageDocsLink pkg (Package.toName pkg)


viewPackageDocsLink : Package.Package -> String -> Html Msg
viewPackageDocsLink pkg str =
    Html.a
        [ Attr.target "_blank"
        , Attr.href (Package.toDocsLink pkg)
        ]
        [ Html.text str ]


viewPackageVersion : V.Version -> Html Msg
viewPackageVersion version =
    Html.span [ Attr.class "flex size-6 shrink-0 items-center text-[0.625rem] font-medium text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ]
        [ Html.text (V.toString version) ]



-- HELPERS


viewSimpleIcon : List (Svg.Attribute msg) -> (List (Svg.Attribute msg) -> Svg msg) -> Html msg
viewSimpleIcon extraAttrs icon =
    icon ([ SvgAttr.class "h-5 w-5 text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ] ++ extraAttrs)


viewButtonIcon : String -> (List (Svg.Attribute msg) -> Svg msg) -> msg -> Html msg
viewButtonIcon alt icon onClick =
    Button.view (Button.Button onClick) Button.Text Nothing [ Aria.ariaLabel alt ] <|
        [ icon [ SvgAttr.class "h-5 w-5 text-gray-400 group-hover:text-amber-600 dark:group-hover:text-white" ] ]
