module Route exposing
    ( Example(..)
    , Route(..)
    , exampleSrc
    , fromUrl
    )

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | Try
    | Example Example


type Example
    = HelloWorld
    | Buttons


exampleSrc : Example -> String
exampleSrc example =
    case example of
        HelloWorld ->
            "hello"

        Buttons ->
            "buttons"


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Try (Parser.s "try")
        , Parser.map (Example HelloWorld) (Parser.s "examples" </> Parser.s "hello")
        , Parser.map (Example Buttons) (Parser.s "examples" </> Parser.s "buttons")
        ]


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser
