module Main exposing
    ( CurrentPage
    , Flags
    , Model
    , Msg
    , main
    )

import Browser
import Browser.Navigation as Nav
import Html
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
    | Home Home.Model
    | Try Try.Model


init : Int -> Url -> Nav.Key -> ( Model, Cmd Msg )
init year url navKey =
    changeRouteTo (Route.fromUrl url)
        { session = Session.init year navKey
        , currentPage = NotFound
        }



-- UPDATE


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    case maybeRoute of
        Nothing ->
            ( { model | currentPage = NotFound }, Cmd.none )

        Just Route.Home ->
            Home.init
                |> updateWith Home HomeMsg model

        Just Route.Try ->
            Try.init
                |> updateWith Try TryMsg model


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | HomeMsg Home.Msg
    | TryMsg Try.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.currentPage ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.navKey model.session) (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( HomeMsg subMsg, Home subModel ) ->
            Home.update subMsg subModel
                |> updateWith Home HomeMsg model

        ( TryMsg subMsg, Try subModel ) ->
            Try.update subMsg subModel
                |> updateWith Try TryMsg model

        _ ->
            ( model, Cmd.none )


updateWith : (subModel -> CurrentPage) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toCurrentPage toMsg model =
    Tuple.mapBoth (\subModel -> { model | currentPage = toCurrentPage subModel }) (Cmd.map toMsg)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.currentPage of
        Try subModel ->
            Try.subscriptions subModel
                |> Sub.map TryMsg

        _ ->
            Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.currentPage of
        NotFound ->
            viewPage never NotFound.view

        Home subModel ->
            viewPage HomeMsg (Home.view model.session subModel)

        Try subModel ->
            viewPage TryMsg (Try.view subModel)


viewPage : (msg -> Msg) -> Browser.Document msg -> Browser.Document Msg
viewPage toMsg { title, body } =
    { title = title
    , body = List.map (Html.map toMsg) body
    }



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
