module Data.Registry.Defaults exposing
    ( decode
    , direct
    , indirect
    , locked
    , popular
    )

import Data.Registry.Package as Package
import Data.Version as V
import Dict
import Json.Decode as D


direct : List Package.Package
direct =
    [ Package.Package "guida-lang" "stdlib" (V.Version 1 0 0)
    ]


indirect : List Package.Package
indirect =
    []


locked : List Package.Key
locked =
    [ ( "guida-lang", "stdlib" )
    ]


popular : List Package.Key
popular =
    [ ( "guida-lang", "project-metadata-utils" )
    , ( "evancz", "elm-playground" )
    , ( "w0rm", "elm-physics" )
    , ( "rtfeldman", "elm-css" )
    , ( "mdgriffith", "elm-ui" )
    ]


decode : D.Decoder (List Package.Package)
decode =
    let
        shape ( name, version ) =
            Package.keyFromName name
                |> Maybe.map (\( author, project ) -> Package.Package author project version)
    in
    D.dict V.decoder
        |> D.map (Dict.toList >> List.filterMap shape)
