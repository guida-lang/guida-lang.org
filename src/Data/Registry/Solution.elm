module Data.Registry.Solution exposing (Solution, decoder, empty, encode, toSolution)

import Data.Registry.Defaults as Defaults
import Data.Registry.Package as Package
import Data.Registry.Status as Status
import Data.Version as V
import Dict exposing (Dict)
import Json.Decode as JD
import Json.Encode as JE


type alias Solution =
    { guida : V.Version
    , direct : Dict Package.Key V.Version
    , indirect : Dict Package.Key V.Version
    }


empty : Solution
empty =
    Solution (V.Version 0 19 1) Dict.empty Dict.empty



-- API


toSolution : List ( Package.Package, Status.Status ) -> Solution
toSolution packages =
    let
        addToSolution ( package, state ) solution =
            case state of
                Status.DirectDep version ->
                    { solution | direct = Dict.insert (Package.toKey package) version solution.direct }

                Status.IndirectDep version ->
                    { solution | indirect = Dict.insert (Package.toKey package) version solution.indirect }

                _ ->
                    solution
    in
    List.foldl addToSolution empty packages



-- DECODE / ENCODE


decoder : JD.Decoder Solution
decoder =
    JD.map3 Solution
        (JD.field "guida-version" V.decoder)
        (JD.at [ "dependencies", "direct" ] decodeDeps)
        (JD.at [ "dependencies", "indirect" ] decodeDeps)


decodeDeps : JD.Decoder (Dict Package.Key V.Version)
decodeDeps =
    let
        shape dict =
            Dict.toList dict
                |> List.filterMap onlyValid
                |> Dict.fromList

        onlyValid ( name, version ) =
            Package.keyFromName name
                |> Maybe.map (\key -> ( key, version ))
    in
    JD.map shape (JD.dict V.decoder)


encode : Solution -> JE.Value
encode solution =
    JE.object
        [ ( "guida-version", V.encode solution.guida )
        , ( "direct", JE.dict Package.nameFromKey V.encode solution.direct )
        , ( "indirect", JE.dict Package.nameFromKey V.encode solution.indirect )
        ]
