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
    | Docs
    | Community
    | Examples
    | Example Example
    | Try


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
        , Parser.map Docs (Parser.s "docs")
        , Parser.map Community (Parser.s "community")
        , Parser.map Examples (Parser.s "examples")
        , Parser.map (Example HelloWorld) (Parser.s "examples" </> Parser.s "hello")
        , Parser.map (Example Buttons) (Parser.s "examples" </> Parser.s "buttons")
        , Parser.map Try (Parser.s "try")
        ]


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser
