module Route exposing
    ( Command(..)
    , DocumentationSection(..)
    , Example(..)
    , Hint(..)
    , Route(..)
    , exampleSrc
    , fromUrl
    )

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Home
    | Docs DocumentationSection
    | Community
    | Examples
    | Example Example
    | Try


type DocumentationSection
    = Introduction
    | Elm
    | GuidaJson
    | Commands Command
    | Hints Hint


type Command
    = Repl
    | Init
    | Make
    | Install
    | Uninstall
    | Bump
    | Diff
    | Publish
    | Format
    | Test


type Hint
    = BadRecursion
    | ComparingCustomTypes
    | ComparingRecords
    | ImplicitCasts
    | ImportCycles
    | Imports
    | InfiniteType
    | MissingPatterns
    | Optimize
    | PortModules
    | RecursiveAlias
    | Shadowing
    | Tuples
    | TypeAnnotations


type Example
    = Animation
    | Book
    | Buttons
    | Cards
    | Clock
    | Crate
    | Cube
    | DragAndDrop
    | FirstPerson
    | Forms
    | Groceries
    | Hello
    | ImagePreviews
    | Keyboard
    | Mario
    | Mouse
    | Numbers
    | Picture
    | Positions
    | Quotes
    | Shapes
    | TextFields
    | Thwomp
    | Time
    | Triangle
    | Turtle
    | Upload


exampleSrc : Example -> String
exampleSrc example =
    case example of
        Animation ->
            "animation"

        Book ->
            "book"

        Buttons ->
            "buttons"

        Cards ->
            "cards"

        Clock ->
            "clock"

        Crate ->
            "crate"

        Cube ->
            "cube"

        DragAndDrop ->
            "drag-and-drop"

        FirstPerson ->
            "first-person"

        Forms ->
            "forms"

        Groceries ->
            "groceries"

        Hello ->
            "hello"

        ImagePreviews ->
            "image-previews"

        Keyboard ->
            "keyboard"

        Mario ->
            "mario"

        Mouse ->
            "mouse"

        Numbers ->
            "numbers"

        Picture ->
            "picture"

        Positions ->
            "positions"

        Quotes ->
            "quotes"

        Shapes ->
            "shapes"

        TextFields ->
            "text-fields"

        Thwomp ->
            "thwomp"

        Time ->
            "time"

        Triangle ->
            "triangle"

        Turtle ->
            "turtle"

        Upload ->
            "upload"


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map (Docs Introduction) (Parser.s "docs")
        , Parser.map (Docs Elm) (Parser.s "docs" </> Parser.s "elm")
        , Parser.map (Docs GuidaJson) (Parser.s "docs" </> Parser.s "guida-json")
        , Parser.map (Docs << Commands) (Parser.s "docs" </> Parser.s "1.0.0" </> Parser.s "commands" </> commandParser)
        , Parser.map (Docs << Hints) (Parser.s "docs" </> Parser.s "1.0.0" </> Parser.s "hints" </> hintParser)
        , Parser.map Community (Parser.s "community")
        , Parser.map Examples (Parser.s "examples")
        , Parser.map (Example Animation) (Parser.s "examples" </> Parser.s "animation")
        , Parser.map (Example Book) (Parser.s "examples" </> Parser.s "book")
        , Parser.map (Example Buttons) (Parser.s "examples" </> Parser.s "buttons")
        , Parser.map (Example Cards) (Parser.s "examples" </> Parser.s "cards")
        , Parser.map (Example Clock) (Parser.s "examples" </> Parser.s "clock")
        , Parser.map (Example Crate) (Parser.s "examples" </> Parser.s "crate")
        , Parser.map (Example Cube) (Parser.s "examples" </> Parser.s "cube")
        , Parser.map (Example DragAndDrop) (Parser.s "examples" </> Parser.s "drag-and-drop")
        , Parser.map (Example FirstPerson) (Parser.s "examples" </> Parser.s "first-person")
        , Parser.map (Example Forms) (Parser.s "examples" </> Parser.s "forms")
        , Parser.map (Example Groceries) (Parser.s "examples" </> Parser.s "groceries")
        , Parser.map (Example Hello) (Parser.s "examples" </> Parser.s "hello")
        , Parser.map (Example ImagePreviews) (Parser.s "examples" </> Parser.s "image-previews")
        , Parser.map (Example Keyboard) (Parser.s "examples" </> Parser.s "keyboard")
        , Parser.map (Example Mario) (Parser.s "examples" </> Parser.s "mario")
        , Parser.map (Example Mouse) (Parser.s "examples" </> Parser.s "mouse")
        , Parser.map (Example Numbers) (Parser.s "examples" </> Parser.s "numbers")
        , Parser.map (Example Picture) (Parser.s "examples" </> Parser.s "picture")
        , Parser.map (Example Positions) (Parser.s "examples" </> Parser.s "positions")
        , Parser.map (Example Quotes) (Parser.s "examples" </> Parser.s "quotes")
        , Parser.map (Example Shapes) (Parser.s "examples" </> Parser.s "shapes")
        , Parser.map (Example TextFields) (Parser.s "examples" </> Parser.s "text-fields")
        , Parser.map (Example Thwomp) (Parser.s "examples" </> Parser.s "thwomp")
        , Parser.map (Example Time) (Parser.s "examples" </> Parser.s "time")
        , Parser.map (Example Triangle) (Parser.s "examples" </> Parser.s "triangle")
        , Parser.map (Example Turtle) (Parser.s "examples" </> Parser.s "turtle")
        , Parser.map (Example Upload) (Parser.s "examples" </> Parser.s "upload")
        , Parser.map Try (Parser.s "try")
        ]


commandParser : Parser (Command -> a) a
commandParser =
    Parser.oneOf
        [ Parser.map Repl (Parser.s "repl")
        , Parser.map Init (Parser.s "init")
        , Parser.map Make (Parser.s "make")
        , Parser.map Install (Parser.s "install")
        , Parser.map Uninstall (Parser.s "uninstall")
        , Parser.map Bump (Parser.s "bump")
        , Parser.map Diff (Parser.s "diff")
        , Parser.map Publish (Parser.s "publish")
        , Parser.map Format (Parser.s "format")
        , Parser.map Test (Parser.s "test")
        ]


hintParser : Parser (Hint -> a) a
hintParser =
    Parser.oneOf
        [ Parser.map BadRecursion (Parser.s "bad-recursion")
        , Parser.map ComparingCustomTypes (Parser.s "comparing-custom-types")
        , Parser.map ComparingRecords (Parser.s "comparing-records")
        , Parser.map ImplicitCasts (Parser.s "implicit-casts")
        , Parser.map ImportCycles (Parser.s "import-cycles")
        , Parser.map Imports (Parser.s "imports")
        , Parser.map InfiniteType (Parser.s "infinite-type")
        , Parser.map MissingPatterns (Parser.s "missing-patterns")
        , Parser.map Optimize (Parser.s "optimize")
        , Parser.map PortModules (Parser.s "port-modules")
        , Parser.map RecursiveAlias (Parser.s "recursive-alias")
        , Parser.map Shadowing (Parser.s "shadowing")
        , Parser.map Tuples (Parser.s "tuples")
        , Parser.map TypeAnnotations (Parser.s "type-annotations")
        ]


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse parser
