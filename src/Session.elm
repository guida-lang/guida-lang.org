module Session exposing
    ( Session
    , init
    , navKey
    , year
    )

import Browser.Navigation as Nav


type alias Session =
    { year : Int
    , navKey : Nav.Key
    }


init : Int -> Nav.Key -> Session
init =
    Session


year : Session -> Int
year =
    .year


navKey : Session -> Nav.Key
navKey =
    .navKey
