port module Data.Registry exposing
    ( Action(..)
    , Registry
    , attemptEdit
    , dismissAll
    , fetch
    , filterKeys
    , filterStatus
    , fromNews
    , fromSolution
    , getErrors
    , getValues
    , initial
    , initialWithDefaults
    , insert
    , installResult
    , mapStatus
    , search
    , setStatus
    , uninstallResult
    , update
    )

import Constant
import Data.Http
import Data.Registry.Defaults as Defaults
import Data.Registry.Package as Package
import Data.Registry.Solution as Solution
import Data.Registry.Status as Status
import Data.Version as V
import Dict exposing (Dict)
import Elm.Error as Error
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Regex


type alias Registry =
    Dict Package.Key ( Package.Package, Status.Status )



-- INIT


initial : Registry
initial =
    Dict.empty
        |> insert (Status.DirectDep << .version) Defaults.direct
        |> insert (Status.IndirectDep << .version) Defaults.indirect


initialWithDefaults : List Package.Package -> List Package.Package -> Registry
initialWithDefaults direct indirect =
    Dict.empty
        |> insert (Status.DirectDep << .version) direct
        |> insert (Status.IndirectDep << .version) indirect


fetch : (Result Http.Error (List Package.Package) -> msg) -> Cmd msg
fetch onResult =
    Http.post
        { url = Constant.server ++ "/all-packages"
        , body = Http.emptyBody
        , expect = Http.expectJson onResult decoder
        }


fromNews : List Package.Package -> Registry -> Registry
fromNews news registry =
    let
        toStatus maybeStatus _ =
            case maybeStatus of
                Just state ->
                    state

                Nothing ->
                    Status.NotInstalled
    in
    update toStatus news registry



-- API


insert : (Package.Package -> Status.Status) -> List Package.Package -> Registry -> Registry
insert toStatus =
    update (always toStatus)


update : (Maybe Status.Status -> Package.Package -> Status.Status) -> List Package.Package -> Registry -> Registry
update toStatus packages registry =
    let
        fold package =
            Dict.update (Package.toKey package) (updateOne package)

        updateOne package maybeValue =
            Just ( package, toStatus (Maybe.map Tuple.second maybeValue) package )
    in
    List.foldl fold registry packages


mapStatus : (Package.Package -> Status.Status -> Status.Status) -> Registry -> Registry
mapStatus toStatus registry =
    let
        func key ( package, state ) =
            ( package, toStatus package state )
    in
    Dict.map func registry


setStatus : Package.Package -> Status.Status -> Registry -> Registry
setStatus pkg state =
    Dict.insert (Package.toKey pkg) ( pkg, state )


dismissAll : Registry -> Registry
dismissAll =
    Dict.map <|
        \_ ( pkg, state ) ->
            case state of
                Status.Failed _ ->
                    ( pkg, Status.NotInstalled )

                _ ->
                    ( pkg, state )


getValues : Registry -> List ( Package.Package, Status.Status )
getValues registry =
    Dict.values registry


getErrors : Registry -> List Error.Error
getErrors registry =
    List.filterMap (Status.getError << Tuple.second) (Dict.values registry)


filterStatus : (Status.Status -> Bool) -> Registry -> Registry
filterStatus inGroup =
    Dict.filter (\key ( pkg, state ) -> inGroup state)


filterKeys : List Package.Key -> Registry -> List ( Package.Package, Status.Status )
filterKeys searched registry =
    List.filterMap (\s -> Dict.get s registry) searched


fromSolution : Solution.Solution -> Registry -> Registry
fromSolution solution registry =
    let
        resetStatus state =
            case state of
                Status.Loading ->
                    state

                Status.NotInstalled ->
                    state

                Status.DirectDep _ ->
                    Status.NotInstalled

                Status.IndirectDep _ ->
                    Status.NotInstalled

                Status.Failed _ ->
                    state

        insertDeps toStatus deps reg =
            List.foldl (fold toStatus) reg (Dict.toList deps)

        fold toStatus ( key, version ) =
            Dict.update key <|
                Maybe.map (\( pkg, _ ) -> ( pkg, toStatus version ))
    in
    registry
        |> mapStatus (always resetStatus)
        |> insertDeps Status.DirectDep solution.direct
        |> insertDeps Status.IndirectDep solution.indirect


search : String -> List ( Package.Package, Status.Status ) -> List ( Package.Package, Status.Status )
search query packages =
    let
        regex =
            String.split "" query
                |> List.intersperse ".*"
                |> String.concat
                |> Regex.fromStringWith { caseInsensitive = True, multiline = False }
                |> Maybe.withDefault Regex.never

        match ( pkg, _ ) =
            Regex.contains regex (Package.toName pkg)

        queryLower =
            String.toLower query

        toNameLower pkg =
            String.toLower (Package.toName pkg)

        order ( pkg, _ ) =
            if queryLower == pkg.project then
                0

            else if queryLower == pkg.author then
                1

            else if String.contains queryLower (toNameLower pkg) then
                2

            else
                3
    in
    packages
        |> List.filter match
        |> List.sortBy order



-- EDIT


type Action
    = Install
    | Uninstall


attemptEdit : Action -> Package.Package -> Cmd msg
attemptEdit action package =
    case action of
        Install ->
            install { packageString = Package.toName package, versionString = V.toString package.version }

        Uninstall ->
            uninstall { packageString = Package.toName package, versionString = V.toString package.version }


port install : { packageString : String, versionString : String } -> Cmd msg


port installResult : ({ packageString : String, versionString : String, result : Encode.Value } -> msg) -> Sub msg


port uninstall : { packageString : String, versionString : String } -> Cmd msg


port uninstallResult : ({ packageString : String, versionString : String, result : Encode.Value } -> msg) -> Sub msg



-- DECODER / REGISTRY


decoder : Decode.Decoder (List Package.Package)
decoder =
    Decode.map
        (Dict.toList
            >> List.concatMap
                (\( name, versions ) ->
                    case String.split "/" name of
                        [ author, project ] ->
                            List.map (Package.Package author project) versions

                        _ ->
                            []
                )
        )
        (Decode.oneOf
            [ Decode.map2
                (Dict.foldl
                    (\k v ->
                        Dict.update k
                            (\maybeList ->
                                Just (Maybe.withDefault [] maybeList ++ v)
                            )
                    )
                )
                (Decode.field "guida" (Decode.dict decodeVersions))
                (Decode.field "elm" (Decode.dict decodeVersions))
            , Decode.dict decodeVersions
            ]
        )


decodeVersions : Decode.Decoder (List V.Version)
decodeVersions =
    Decode.list decodeVersion


decodeVersion : Decode.Decoder V.Version
decodeVersion =
    Decode.andThen
        (\version ->
            case List.map String.toInt (String.split "." version) of
                [ Just major, Just minor, Just patch ] ->
                    Decode.succeed (V.Version major minor patch)

                _ ->
                    Decode.fail ("Failed to parse version `" ++ version ++ "`")
        )
        Decode.string
