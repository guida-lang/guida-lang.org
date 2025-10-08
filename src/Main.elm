module Main exposing (main)

import Browser
import Browser.Events
import Browser.Navigation as Nav
import Components.ThemeToggle as ThemeToggle
import Html
import Page.Community as Community
import Page.Docs as Docs
import Page.Examples as Examples
import Page.Home as Home
import Page.NotFound as NotFound
import Page.Try as Try
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)



-- MODEL


type alias Model =
    { session : Session
    , currentPage : CurrentPage
    }


type CurrentPage
    = NotFound
    | Home
    | Docs Docs.Model
    | Community
    | Examples
    | Try Try.Model


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        theme : ThemeToggle.Theme
        theme =
            case flags.theme of
                Just "dark" ->
                    ThemeToggle.Dark

                _ ->
                    ThemeToggle.Light
    in
    changeRouteTo (Route.fromUrl url)
        { session = Session.init flags.year theme navKey
        , currentPage = NotFound
        }



-- UPDATE


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | currentPage = NotFound }, Cmd.none )

        Just Route.Home ->
            ( { model | currentPage = Home }, Cmd.none )

        Just (Route.Docs subRoute) ->
            Docs.init subRoute
                |> updateWith Docs identity model

        Just Route.Community ->
            ( { model | currentPage = Community }, Cmd.none )

        Just Route.Examples ->
            ( { model | currentPage = Examples }, Cmd.none )

        Just (Route.Example example) ->
            Try.init (Just example)
                |> updateWith Try TryMsg model

        Just Route.Try ->
            Try.init Nothing
                |> updateWith Try TryMsg model


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
      -- SESSION
    | SessionMsg Session.Msg
      -- PAGES
    | TryMsg Try.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.currentPage ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( { model | session = Session.closeMobileNavigation model.session }
                    , Nav.pushUrl (Session.navKey model.session) (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        -- SESSION
        ( SessionMsg subMsg, _ ) ->
            Session.update subMsg model.session
                |> Tuple.mapFirst (\session -> { model | session = session })

        -- PAGES
        ( TryMsg subMsg, Try subModel ) ->
            Try.update subMsg subModel
                |> updateWith Try TryMsg model

        _ ->
            ( model, Cmd.none )


updateWith : (subModel -> CurrentPage) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toCurrentPage toMsg model =
    Tuple.mapBoth (\subModel -> { model | currentPage = toCurrentPage subModel }) (Cmd.map toMsg)



-- SUBSCRIPTIONS


withSidebarBreakpoint : Int
withSidebarBreakpoint =
    1024


withoutSidebarBreakpoint : Int
withoutSidebarBreakpoint =
    768


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        breakpoint : Int
        breakpoint =
            case model.currentPage of
                Docs _ ->
                    withSidebarBreakpoint

                _ ->
                    withoutSidebarBreakpoint
    in
    Sub.batch
        [ Browser.Events.onResize (\w _ -> SessionMsg (Session.OnResize { breakpoint = breakpoint, width = w }))
        , case model.currentPage of
            Try subModel ->
                Try.subscriptions subModel
                    |> Sub.map TryMsg

            _ ->
                Sub.none
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.currentPage of
        NotFound ->
            viewPage never NotFound.view

        Home ->
            Home.view model.session SessionMsg

        Docs subModel ->
            Docs.view model.session SessionMsg subModel

        Community ->
            Community.view model.session SessionMsg

        Examples ->
            Examples.view model.session SessionMsg

        Try subModel ->
            Try.view model.session SessionMsg TryMsg subModel


viewPage : (msg -> Msg) -> Browser.Document msg -> Browser.Document Msg
viewPage toMsg { title, body } =
    { title = title
    , body = List.map (Html.map toMsg) body
    }



-- MAIN


type alias Flags =
    { theme : Maybe String
    , year : Int
    }


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
