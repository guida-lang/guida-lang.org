module Route exposing
    ( Route(..)
    , fromUrl
    )

import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type Route
    = Home
    | Try


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Try (Parser.s "try")
        ]


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser
