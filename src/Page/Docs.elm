module Page.Docs exposing
    ( Model
    , init
    , view
    )

import Browser
import Components.Button as Button exposing (Type(..))
import Components.CodeBlock as CodeBlock
import Components.Note as Note
import Components.Properties as Properties
import Components.References as References
import Components.Table as Table
import Html exposing (Html)
import Html.Attributes as Attr
import Layout.Main as Layout
import Layout.Navigation exposing (Navigation)
import Route
import Session exposing (Session)



-- MODEL


type alias Model =
    { section : Route.DocumentationSection
    }


init : Route.DocumentationSection -> ( Model, Cmd msg )
init section =
    ( { section = section }, Cmd.none )



-- VIEW


view : Session -> (Session.Msg -> msg) -> Model -> Browser.Document msg
view session toSessionMsg model =
    { title = "Guida: Documentation"
    , body =
        Layout.view { sidebarNavigation = sidebarNavigation model } session toSessionMsg <|
            case model.section of
                Route.Introduction ->
                    introductionView

                Route.Syntax ->
                    syntaxView

                Route.FromJavaScriptOrElm ->
                    fromJavaScriptOrElmView

                Route.GuidaJson ->
                    guidaJsonView

                Route.Records ->
                    recordsView

                Route.Commands command ->
                    commandView command

                Route.Hints hint ->
                    hintView hint
    }


introductionView : List (Html msg)
introductionView =
    [ Html.h1 [] [ Html.text "An Introduction to Guida" ]
    , Html.p []
        [ Html.strong [] [ Html.text "Guida is a functional language that compiles to JavaScript." ]
        , Html.text " It helps you make websites and web apps. It has a strong emphasis on simplicity and quality tooling."
        ]
    , Html.p [] [ Html.text "This guide will:" ]
    , Html.ul []
        [ Html.li [] [ Html.text "Teach you the fundamentals of programming in Guida." ]
        , Html.li []
            [ Html.text "Show you how to make interactive apps with "
            , Html.strong [] [ Button.view (Button.Link "https://guide.elm-lang.org/architecture") Button.Text Nothing [] [ Html.text "The Elm Architecture" ] ]
            , Html.text "."
            ]
        , Html.li [] [ Html.text "Emphasize principles and patterns that generalize to programming in any language." ]
        ]
    , Html.p []
        [ Html.text "By the end we hope you will not only be able to create great web apps in Guida, but also understand the core ideas and patterns that make Guida nice to use."
        ]
    , Html.p []
        [ Html.text "If you are on the fence, we can safely guarantee that if you give Guida a shot and actually make a project in it, you will end up writing better JavaScript code. The ideas transfer pretty easily!"
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "A Quick Sample" ]
    , Html.p []
        [ Html.text "Here is a little program that lets you increment and decrement a number:"
        ]
    , CodeBlock.view """module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


main =
    Browser.sandbox { init = init, update = update, view = view }


type alias Model =
    Int


init : Model
init =
    0


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (String.fromInt model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]"""
    , Html.p []
        [ Html.text "Try it out in the online editor "
        , Button.view (Button.Link "/examples/buttons") Button.Text Nothing [] [ Html.text "here" ]
        , Html.text "."
        ]
    , Html.p []
        [ Html.text "The code can definitely look unfamiliar at first, so we will get into how this example works soon!"
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ]
        [ Html.text "Why a functional "
        , Html.em [] [ Html.text "language" ]
        , Html.text "?"
        ]
    , Html.p []
        [ Html.text "You can get some benefits from programming in a functional style, but there are some things you can only get from a functional language like Guida:"
        ]
    , Html.ul []
        [ Html.li [] [ Html.text "No runtime errors in practice." ]
        , Html.li [] [ Html.text "Friendly error messages." ]
        , Html.li [] [ Html.text "Reliable refactoring." ]
        , Html.li [] [ Html.text "Automatically enforced semantic versioning for all Guida packages." ]
        ]
    , Html.p []
        [ Html.text "No combination of JS libraries can give you all of these guarantees. They come from the design of the language itself! And thanks to these guarantees, it is quite common for Guida programmers to say they never felt so "
        , Html.strong [] [ Html.text "confident" ]
        , Html.text " while programming. Confident to add features quickly. Confident to refactor thousands of lines. But without the background anxiety that you missed something important!"
        ]
    , Html.p []
        [ Html.text "Guida has a huge emphasis on making it easy to learn and use, so give Guida a shot and see what you think. We hope you will be pleasantly surprised!"
        ]
    , References.view
        [ "https://guide.elm-lang.org"
        ]
    ]


syntaxView : List (Html msg)
syntaxView =
    [ Html.h1 [] [ Html.text "Syntax" ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Comments" ]
    , CodeBlock.view """-- a single line comment

{- a multiline comment
   {- can be nested -}
-}"""
    , Html.p [] [ Html.text "Here's a handy trick that every Guida programmer should know:" ]
    , CodeBlock.view """{--}
add x y = x + y
--}"""
    , Html.p []
        [ Html.text "Just add or remove the "
        , Html.code [] [ Html.text "}" ]
        , Html.text " on the first line and you'll toggle between commented and uncommented!"
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Literals" ]
    , CodeBlock.view """-- Boolean
True  : Bool
False : Bool

42    : number  -- Int or Float depending on usage
3.14  : Float

'a'   : Char
"abc" : String

-- multi-line String
\"\"\"
This is useful for holding JSON or other
content that has "quotation marks".
\"\"\""""
    , Html.p [] [ Html.text "Typical manipulation of literals:" ]
    , CodeBlock.view """True && not (True || False)
(2 + 4) * (4^2 - 9)
"abc" ++ "def\""""
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Lists" ]
    , Html.p [] [ Html.text "Here are three things that are equivalent:" ]
    , CodeBlock.view """[ 1, 2, 3, 4 ]
1 :: [ 2, 3, 4 ]
1 :: 2 :: 3 :: 4 :: []"""
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Conditionals" ]
    , CodeBlock.view "if powerLevel > 9000 then \"OVER 9000!!!\" else \"meh\""
    , Html.p [] [ Html.text "If you need to branch on many different conditions, you just chain this construct together." ]
    , CodeBlock.view """if key == 40 then
      n + 1

  else if key == 38 then
      n - 1

  else
      n"""
    , Html.p [] [ Html.text "You can also have conditional behavior based on the structure of custom types and literals:" ]
    , CodeBlock.view """  case maybeList of
    Just xs -> xs
    Nothing -> []

  case xs of
    [] ->
      Nothing
    first :: rest ->
      Just (first, rest)

  case n of
    0 -> 1
    1 -> 1
    _ -> fib (n-1) + fib (n-2)"""
    , Html.p [] [ Html.text "Each pattern is indentation sensitive, meaning that you have to align all of your patterns." ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Records" ]
    , Html.p []
        [ Html.text "For more explanation of Guida's record system, see "
        , Button.view (Button.Link "/docs/records") Button.Text Nothing [] [ Html.text "this overview" ]
        , Html.text ", or "
        , Button.view (Button.Link "https://elm-lang.org/news/0.7") Button.Text Nothing [] [ Html.text "Elm's initial announcement." ]
        ]
    , CodeBlock.view """-- create records
origin = { x = 0, y = 0 }
point = { x = 3, y = 4 }

-- access fields
origin.x == 0
point.x == 3

-- field access function
List.map .x [ origin, point ] == [ 0, 3 ]

-- update a field
{ point | x = 6 } == { x = 6, y = 4 }

-- update many fields
{ point | x = point.x + 1, y = point.y + 1 }"""
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Functions" ]
    , CodeBlock.view """square n =
  n^2

hypotenuse a b =
  sqrt (square a + square b)

distance (a,b) (x,y) =
  hypotenuse (a - x) (b - y)"""
    , Html.p [] [ Html.text "Anonymous functions:" ]
    , CodeBlock.view """square =
  \\n -> n^2

squares =
  List.map (\\n -> n^2) (List.range 1 100)"""
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Operators" ]
    , Html.p []
        [ Html.text "In addition to the normal math operations for addition and subtraction, we have the "
        , Button.view (Button.Link "https://package.elm-lang.org/packages/elm/core/latest/Basics#(%3C|)") Button.Text Nothing [] [ Html.text "(<|)" ]
        , Html.text " and "
        , Button.view (Button.Link "https://package.elm-lang.org/packages/elm/core/latest/Basics#(|%3E)") Button.Text Nothing [] [ Html.text "(|>)" ]
        , Html.text " operators. They are aliases for function application, allowing you to write fewer parentheses."
        ]
    , CodeBlock.view """viewNames1 names =
  String.join ", " (List.sort names)

viewNames2 names =
  names
    |> List.sort
    |> String.join ", "

-- (arg |> func) is the same as (func arg)
-- Just keep repeating that transformation!"""
    , Html.p [] [ Html.text "Historical note: this is borrowed from F#, inspired by Unix pipes." ]
    , Html.p []
        [ Html.text "Relatedly, "
        , Button.view (Button.Link "https://package.elm-lang.org/packages/elm/core/latest/Basics#(%3C%3C)") Button.Text Nothing [] [ Html.text "(<<)" ]
        , Html.text " and "
        , Button.view (Button.Link "https://package.elm-lang.org/packages/elm/core/latest/Basics#(%3E%3E)") Button.Text Nothing [] [ Html.text "(>>)" ]
        , Html.text " are function composition operators."
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Let Expressions" ]
    , Html.p []
        [ Html.code [] [ Html.text "let" ]
        , Html.text " these values be defined "
        , Html.code [] [ Html.text "in" ]
        , Html.text " this specific expression."
        ]
    , CodeBlock.view """  let
    twentyFour =
      3 * 8

    sixteen =
      4 ^ 2
  in
  twentyFour + sixteen"""
    , Html.p []
        [ Html.text "This is useful when an expression is getting large. You can make a "
        , Html.code [] [ Html.text "let" ]
        , Html.text " to break it into smaller definitions and put them all together "
        , Html.code [] [ Html.text "in" ]
        , Html.text " a smaller expression."
        ]
    , Html.p [] [ Html.text "You can define functions and use \"destructuring assignment\" in let expressions too." ]
    , CodeBlock.view """  let
    ( three, four ) =
      ( 3, 4 )

    hypotenuse a b =
      sqrt (a^2 + b^2)
  in
  hypotenuse three four"""
    , Html.p [] [ Html.text "Let-expressions are indentation sensitive, so each definition must align with the one above it." ]
    , Html.p [] [ Html.text "Finally, you can add type annotations in let-expressions." ]
    , CodeBlock.view """  let
    name : String
    name =
      "Hermann"

    increment : Int -> Int
    increment n =
      n + 1
  in
  increment 10"""
    , Html.p [] [ Html.text "It is best to only do this on concrete types. Break generic functions into their own top-level definitions." ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Applying Functions" ]
    , CodeBlock.view """-- alias for appending lists and two lists
append xs ys = xs ++ ys
xs = [1,2,3]
ys = [4,5,6]

-- All of the following expressions are equivalent:
a1 = append xs ys
a2 = xs ++ ys

b2 = (++) xs ys

c1 = (append xs) ys
c2 = ((++) xs) ys"""
    , Html.p [] [ Html.text "The basic arithmetic infix operators all figure out what type they should have automatically." ]
    , CodeBlock.view """23 + 19   : number
2.0 + 1   : Float

6 * 7     : number
10 * 4.2  : Float

100 // 2  : Int
1 / 2     : Float"""
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Modules" ]
    , CodeBlock.view """module MyModule exposing (..)

-- qualified imports
import List                            -- List.map, List.foldl
import List as L                       -- L.map, L.foldl

-- open imports
import List exposing (..)              -- map, foldl, concat, ...
import List exposing ( map, foldl )    -- map, foldl

import Maybe exposing ( Maybe )        -- Maybe
import Maybe exposing ( Maybe(..) )    -- Maybe, Just, Nothing"""
    , Html.p []
        [ Html.text "Qualified imports are preferred. Module names must match their file name, so module "
        , Html.code [] [ Html.text "Parser.Utils" ]
        , Html.text " needs to be in file "
        , Html.code [] [ Html.text "Parser/Utils.guida" ]
        , Html.text "."
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Type Annotations" ]
    , CodeBlock.view """answer : Int
answer =
  42

factorial : Int -> Int
factorial n =
  List.product (List.range 1 n)

distance : { x : Float, y : Float } -> Float
distance {x,y} =
  sqrt (x^2 + y^2)"""
    , Html.p []
        [ Html.text "Learn how to read types and use type annotations "
        , Button.view (Button.Link "/docs/types/reading-types") Button.Text Nothing [] [ Html.text "here" ]
        , Html.text "."
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Type Aliases" ]
    , CodeBlock.view """type alias Name = String
type alias Age = Int

info : (Name,Age)
info =
  ("Steve", 28)

type alias Point = { x:Float, y:Float }

origin : Point
origin =
  { x = 0, y = 0 }"""
    , Html.p []
        [ Html.text "Learn more about type aliases "
        , Button.view (Button.Link "/docs/types/type-aliases") Button.Text Nothing [] [ Html.text "here" ]
        , Html.text "."
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Custom Types" ]
    , CodeBlock.view """type User
  = Regular String Int
  | Visitor String"""
    , Html.p []
        [ Html.text "Not sure what this means? Read "
        , Button.view (Button.Link "/docs/types/custom-types") Button.Text Nothing [] [ Html.text "this" ]
        , Html.text "!"
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "JavaScript Interop" ]
    , CodeBlock.view """-- incoming values
port prices : (Float -> msg) -> Sub msg

-- outgoing values
port time : Float -> Cmd msg"""
    , Html.p [] [ Html.text "From JS, you talk to these ports like this:" ]
    , CodeBlock.view """var app = Elm.Example.init();

app.ports.prices.send(42);
app.ports.prices.send(13);

app.ports.time.subscribe(callback);
app.ports.time.unsubscribe(callback);"""
    , Html.p []
        [ Html.text "Read more about JavaScript interop "
        , Button.view (Button.Link "/docs/interop") Button.Text Nothing [] [ Html.text "here" ]
        , Html.text "."
        ]
    , References.view
        [ "https://elm-lang.org/docs/syntax"
        , "https://guide.elm-lang.org/core_language"
        ]
    ]


fromJavaScriptOrElmView : List (Html msg)
fromJavaScriptOrElmView =
    [ Html.h1 [] [ Html.text "From JavaScript or Elm?" ]
    , Html.p [] [ Html.text "The following tables show side-by-side mappings between JavaScript, Elm and Guida. A lot of things are very similar, especially once you get used to the relatively minor syntactic difference." ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Literals" ]
    , Table.view
        [ [ Html.text "JavaScript" ]
        , [ Html.text "Elm" ]
        , [ Html.text "Guida" ]
        ]
        [ [ [ Html.code [] [ Html.text "3" ] ]
          , [ Html.code [] [ Html.text "3" ] ]
          , [ Html.code [] [ Html.text "3" ] ]
          ]
        , [ [ Html.code [] [ Html.text "3.1415" ] ]
          , [ Html.code [] [ Html.text "3.1415" ] ]
          , [ Html.code [] [ Html.text "3.1415" ] ]
          ]
        , [ [ Html.code [] [ Html.text "\"Hello world!\"" ] ]
          , [ Html.code [] [ Html.text "\"Hello world!\"" ] ]
          , [ Html.code [] [ Html.text "\"Hello world!\"" ] ]
          ]
        , [ [ Html.code [] [ Html.text "`multiline string`" ] ]
          , [ Html.code [] [ Html.text "\"\"\"multiline string\"\"\"" ] ]
          , [ Html.code [] [ Html.text "\"\"\"multiline string\"\"\"" ] ]
          ]
        , [ [ Html.code [] [ Html.text "'Hello world!'" ] ]
          , [ Html.text "Cannot use single quotes for strings" ]
          , [ Html.text "Cannot use single quotes for strings" ]
          ]
        , [ [ Html.text "No distinction between characters and strings" ]
          , [ Html.code [] [ Html.text "'a'" ] ]
          , [ Html.code [] [ Html.text "'a'" ] ]
          ]
        , [ [ Html.code [] [ Html.text "true" ] ]
          , [ Html.code [] [ Html.text "True" ] ]
          , [ Html.code [] [ Html.text "True" ] ]
          ]
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Objects / Records" ]
    , Table.view
        [ [ Html.text "JavaScript" ]
        , [ Html.text "Elm" ]
        , [ Html.text "Guida" ]
        ]
        [ [ [ Html.code [] [ Html.text "{ x: 3, y: 4 }" ] ]
          , [ Html.code [] [ Html.text "{ x = 3, y = 4 }" ] ]
          , [ Html.code [] [ Html.text "{ x = 3, y = 4 }" ] ]
          ]
        , [ [ Html.code [] [ Html.text "point.x" ] ]
          , [ Html.code [] [ Html.text "point.x" ] ]
          , [ Html.code [] [ Html.text "point.x" ] ]
          ]
        , [ [ Html.code [] [ Html.text "point.x = 42" ] ]
          , [ Html.code [] [ Html.text "{ point | x = 42 }" ] ]
          , [ Html.code [] [ Html.text "{ point | x = 42 }" ] ]
          ]
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Functions" ]
    , Table.view
        [ [ Html.text "JavaScript" ]
        , [ Html.text "Elm" ]
        , [ Html.text "Guida" ]
        ]
        [ [ [ Html.code [] [ Html.text "function(x, y) { return x + y; }" ] ]
          , [ Html.code [] [ Html.text "\\x y -> x + y" ] ]
          , [ Html.code [] [ Html.text "\\x y -> x + y" ] ]
          ]
        , [ [ Html.code [] [ Html.text "Math.max(3, 4)" ] ]
          , [ Html.code [] [ Html.text "max 3 4" ] ]
          , [ Html.code [] [ Html.text "max 3 4" ] ]
          ]
        , [ [ Html.code [] [ Html.text "Math.min(1, Math.pow(2, 4))" ] ]
          , [ Html.code [] [ Html.text "min 1 (2^4)" ] ]
          , [ Html.code [] [ Html.text "min 1 (2^4)" ] ]
          ]
        , [ [ Html.code [] [ Html.text "numbers.map(Math.sqrt)" ] ]
          , [ Html.code [] [ Html.text "List.map sqrt numbers" ] ]
          , [ Html.code [] [ Html.text "List.map sqrt numbers" ] ]
          ]
        , [ [ Html.code [] [ Html.text "points.map(function(p) { return p.x })" ] ]
          , [ Html.code [] [ Html.text "List.map .x points" ] ]
          , [ Html.code [] [ Html.text "List.map .x points" ] ]
          ]
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Control Flow" ]
    , Table.view
        [ [ Html.text "JavaScript" ]
        , [ Html.text "Elm" ]
        , [ Html.text "Guida" ]
        ]
        [ [ [ Html.code [] [ Html.text "3 > 2 ? 'cat' : 'dog'" ] ]
          , [ Html.code [] [ Html.text "if 3 > 2 then \"cat\" else \"dog\"" ] ]
          , [ Html.code [] [ Html.text "if 3 > 2 then \"cat\" else \"dog\"" ] ]
          ]
        , [ [ Html.code [] [ Html.text "var x = 42; ..." ] ]
          , [ Html.code [] [ Html.text "let x = 42 in ..." ] ]
          , [ Html.code [] [ Html.text "let x = 42 in ..." ] ]
          ]
        , [ [ Html.code [] [ Html.text "return 42" ] ]
          , [ Html.text "Everything is an expression, no need for return" ]
          , [ Html.text "Everything is an expression, no need for return" ]
          ]
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Strings" ]
    , Table.view
        [ [ Html.text "JavaScript" ]
        , [ Html.text "Elm" ]
        , [ Html.text "Guida" ]
        ]
        [ [ [ Html.code [] [ Html.text "'abc' + '123'" ] ]
          , [ Html.code [] [ Html.text "\"abc\" ++ \"123\"" ] ]
          , [ Html.code [] [ Html.text "\"abc\" ++ \"123\"" ] ]
          ]
        , [ [ Html.code [] [ Html.text "'abc'.length" ] ]
          , [ Html.code [] [ Html.text "String.length \"abc\"" ] ]
          , [ Html.code [] [ Html.text "String.length \"abc\"" ] ]
          ]
        , [ [ Html.code [] [ Html.text "'abc'.toUpperCase()" ] ]
          , [ Html.code [] [ Html.text "String.toUpper \"abc\"" ] ]
          , [ Html.code [] [ Html.text "String.toUpper \"abc\"" ] ]
          ]
        , [ [ Html.code [] [ Html.text "'abc' + 123" ] ]
          , [ Html.code [] [ Html.text "\"abc\" ++ String.fromInt 123" ] ]
          , [ Html.code [] [ Html.text "\"abc\" ++ String.fromInt 123" ] ]
          ]
        ]
    , References.view
        [ "https://elm-lang.org/docs/from-javascript"
        ]
    ]


guidaJsonView : List (Html msg)
guidaJsonView =
    [ Html.h1 [] [ Html.text "guida.json" ]
    , Html.p []
        [ Html.text "The "
        , Html.code [] [ Html.text "guida.json" ]
        , Html.text " describes your project. There are two different types of project: applications and packages."
        ]
    , Html.p []
        [ Html.text "This file is generated by the "
        , Button.view (Button.Link "/docs/1.0.0/commands/init") Button.Text Nothing [] [ Html.text "guida init" ]
        , Html.text " command, to simplify setup. To generate an application, run "
        , Html.code [] [ Html.text "guida init" ]
        , Html.text ". To generate a package, run "
        , Html.code [] [ Html.text "guida init --package" ]
        , Html.text "."
        ]
    , Html.p []
        [ Html.text "Depending on the type of project, the "
        , Html.code [] [ Html.text "guida.json" ]
        , Html.text " looks slightly different."
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Application" ]
    , Html.p []
        [ Html.text "When running "
        , Html.code [] [ Html.text "guida init" ]
        , Html.text " a "
        , Html.code [] [ Html.text "guida.json" ]
        , Html.text " file is generated with the following content:"
        ]
    , CodeBlock.view """{
    "type": "application",
    "source-directories": [
        "src"
    ],
    "guida-version": "1.0.0",
    "dependencies": {
        "direct": {
            "elm/browser": "1.0.2",
            "elm/core": "1.0.5",
            "elm/html": "1.0.0"
        },
        "indirect": {
            "elm/json": "1.1.4",
            "elm/time": "1.0.0",
            "elm/url": "1.0.0",
            "elm/virtual-dom": "1.0.4"
        }
    },
    "test-dependencies": {
        "direct": {
            "elm-explorations/test": "2.2.0"
        },
        "indirect": {
            "elm/bytes": "1.0.8",
            "elm/random": "1.0.0"
        }
    }
}"""
    , Properties.view
        [ { name = "\"type\""
          , type_ = Nothing
          , children =
                [ Html.text "Either "
                , Html.code [] [ Html.text "\"application\"" ]
                , Html.text " or "
                , Html.code [] [ Html.text "\"package\"" ]
                , Html.text ". All the other fields are based on this choice."
                ]
          }
        , { name = "\"source-directories\""
          , type_ = Nothing
          , children =
                [ Html.text "A list of directories where Guida code lives. Most projects just use "
                , Html.code [] [ Html.text "\"src\"" ]
                , Html.text " for everything."
                ]
          }
        , { name = "\"guida-version\""
          , type_ = Nothing
          , children =
                [ Html.text "The exact version of Guida this builds with. Should be "
                , Html.code [] [ Html.text "\"1.0.0\"" ]
                , Html.text " for most people!"
                ]
          }
        , { name = "\"dependencies\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "All the packages you depend upon. We use exact versions, so your "
                    , Html.code [] [ Html.text "guida.json" ]
                    , Html.text " file doubles as a \"lock file\" that ensures reliable builds."
                    ]
                , Html.p []
                    [ Html.text "You can use modules from any "
                    , Html.code [] [ Html.text "\"direct\"" ]
                    , Html.text " dependency in your code. Some "
                    , Html.code [] [ Html.text "\"direct\"" ]
                    , Html.text " dependencies have their own dependencies that folks typically do not care about. These are the "
                    , Html.code [] [ Html.text "\"indirect\"" ]
                    , Html.text " dependencies. They are listed explicitly so that (1) builds are reproducible and (2) you can easily review the quantity and quality of dependencies."
                    ]
                ]
          }
        , { name = "\"test-dependencies\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "All the packages that you use in "
                    , Html.code [] [ Html.text "tests/" ]
                    , Html.text " with "
                    , Html.code [] [ Html.text "guida test" ]
                    , Html.text " but not in the application you actually want to ship. This also uses exact versions to make tests more reliable."
                    ]
                ]
          }
        ]
    , Html.h2 [ Attr.class "scroll-mt-12" ] [ Html.text "Package" ]
    , Html.p []
        [ Html.text "When running "
        , Html.code [] [ Html.text "guida init --package" ]
        , Html.text " a "
        , Html.code [] [ Html.text "guida.json" ]
        , Html.text " file is generated with the following content:"
        ]
    , CodeBlock.view """{
    "type": "package",
    "name": "author/project",
    "summary": "helpful summary of your project, less than 80 characters",
    "license": "BSD-3-Clause",
    "version": "1.0.0",
    "exposed-modules": [],
    "guida-version": "1.0.0 <= v < 2.0.0",
    "dependencies": {
        "elm/core": "1.0.5 <= v < 2.0.0"
    },
    "test-dependencies": {
        "elm-explorations/test": "2.2.0 <= v < 3.0.0"
    }
}"""
    , Properties.view
        [ { name = "\"type\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "Either "
                    , Html.code [] [ Html.text "\"application\"" ]
                    , Html.text " or "
                    , Html.code [] [ Html.text "\"package\"" ]
                    , Html.text ". All the other fields are based on this choice."
                    ]
                ]
          }
        , { name = "\"name\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "The name of a GitHub repo like "
                    , Html.code [] [ Html.text "\"elm/core\"" ]
                    , Html.text " or "
                    , Html.code [] [ Html.text "\"rtfeldman/elm-css\"" ]
                    , Html.text "."
                    ]
                , Note.view
                    [ Html.strong [] [ Html.text "Note:" ]
                    , Html.text " We currently only support GitHub repos to ensure that there are no author name collisions. This seems like a pretty tricky problem to solve in a pleasant way. For example, do we have to keep an author name registry and give them out as we see them? But if someone is the same person on two platforms? And how to make this all happen in a way this is really nice for typical Elm users? Etc. So adding other hosting endpoints is harder than it sounds."
                    ]
                ]
          }
        , { name = "\"summary\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "A short summary that will appear on "
                    , Button.view (Button.Link "https://package.guida-lang.org") Button.Text Nothing [] [ Html.text "package.guida-lang.org" ]
                    , Html.text " that describes what the package is for. Must be under 80 characters."
                    ]
                ]
          }
        , { name = "\"license\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "An OSI approved SPDX code like "
                    , Html.code [] [ Html.text "\"BSD-3-Clause\"" ]
                    , Html.text " or "
                    , Html.code [] [ Html.text "\"MIT\"" ]
                    , Html.text ". These are the two most common licenses in the Elm ecosystem, but you can see the full list of options "
                    , Button.view (Button.Link "https://spdx.org/licenses") Button.Text Nothing [] [ Html.text "here" ]
                    , Html.text "."
                    ]
                ]
          }
        , { name = "\"version\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "All packages start at "
                    , Html.code [] [ Html.text "\"1.0.0\"" ]
                    , Html.text " and from there, Guida automatically enforces semantic versioning by comparing API changes."
                    ]
                , Html.p []
                    [ Html.text "So if you make a PATCH change and call "
                    , Html.code [] [ Html.text "guida bump" ]
                    , Html.text " it will update you to "
                    , Html.code [] [ Html.text "\"1.0.1\"" ]
                    , Html.text ". And if you then decide to remove a function (a MAJOR change) and call "
                    , Html.code [] [ Html.text "guida bump" ]
                    , Html.text " it will update you to "
                    , Html.code [] [ Html.text "\"2.0.0\"" ]
                    , Html.text ". Etc."
                    ]
                ]
          }
        , { name = "\"exposed-modules\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "A list of modules that will be exposed to people using your package. The order you list them will be the order they appear on "
                    , Button.view (Button.Link "https://package.guida-lang.org") Button.Text Nothing [] [ Html.text "package.guida-lang.org" ]
                    , Html.text "."
                    ]
                , Html.p []
                    [ Html.strong [] [ Html.text "Note:" ]
                    , Html.text " If you have five or more modules, you can use a labelled list like "
                    , Button.view (Button.Link "https://github.com/elm/core/blob/1.0.5/elm.json") Button.Text Nothing [] [ Html.text "this" ]
                    , Html.text ". We show the labels on the package website to help people sort through larger packages with distinct categories. Labels must be under 20 characters."
                    ]
                ]
          }
        , { name = "\"guida-version\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "The range of Elm compilers that work with your package. Right now "
                    , Html.code [] [ Html.text "\"0.19.0 <= v < 0.20.0\"" ]
                    , Html.text " is always what you want for this."
                    ]
                ]
          }
        , { name = "\"dependencies\""
          , type_ = Nothing
          , children =
                [ Html.p []
                    [ Html.text "A list of packages that you depend upon. In each application, there can only be one version of each package, so wide ranges are great. Fewer dependencies is even better though!"
                    ]
                , Note.view
                    [ Html.strong [] [ Html.text "Note:" ]
                    , Html.text " Dependency ranges should only express tested ranges. It is not nice to use optimistic ranges and end up causing build failures for your users down the line. Eventually we would like to have an automated system that tries to build and test packages as new packages come out. If it all works, we could send a PR to the author widening the range."
                    ]
                ]
          }
        , { name = "\"test-dependencies\""
          , type_ = Nothing
          , children =
                [ Html.text "Dependencies that are only used in the "
                , Html.code [] [ Html.text "tests/" ]
                , Html.text " directory by "
                , Html.code [] [ Html.text "guida test" ]
                , Html.text ". Values from these packages will not appear in any final build artifacts."
                ]
          }
        ]
    , References.view
        [ "https://github.com/elm/compiler/blob/0.19.1/docs/elm.json/application.md"
        , "https://github.com/elm/compiler/blob/0.19.1/docs/elm.json/package.md"
        , "https://gren-lang.org/book/appendix/gren_json/"
        ]
    ]


recordsView : List (Html msg)
recordsView =
    [ Html.h1 [] [ Html.text "Records" ]
    , References.view
        [ "https://elm-lang.org/docs/records"
        ]
    ]


commandView : Route.Command -> List (Html msg)
commandView command =
    case command of
        Route.Repl ->
            [ Html.h1 [] [ Html.text "guida repl" ]
            , Html.p [] [ Html.text "The REPL lets you interact with Guida values and functions in your terminal." ]
            , Html.p [] [ Html.text "You can type in expressions, definitions, custom types, and module imports using normal Guida syntax." ]
            , CodeBlock.view """> 1 + 1
2 : number

> "hello" ++ "world"
"helloworld" : String"""
            , Html.p [] [ Html.text "The same can be done with definitions and custom types:" ]
            , CodeBlock.view """> fortyTwo = 42
42 : number

> increment n = n + 1
<function> : number -> number

> increment 41
42 : number

> factorial n =
|   if n < 1 then
|     1
|   else
|     n * factorial (n-1)
|
<function> : number -> number

> factorial 5
120 : number

> type User
|   = Regular String
|   | Visitor String
|

> case Regular "Tom" of
|   Regular name -> "Hey again!"
|   Visitor name -> "Nice to meet you!"
|
"Hey again!" : String"""
            , Html.p []
                [ Html.text "When you run "
                , Html.code [] [ Html.text "guida repl" ]
                , Html.text " in a project with an "
                , Button.view (Button.Link "/docs/guida-json") Button.Text Nothing [] [ Html.text "guida.json" ]
                , Html.text " file, you can import any module available in the project. So if your project has an "
                , Html.code [] [ Html.text "elm/html" ]
                , Html.text " dependency, you could say:"
                ]
            , CodeBlock.view """> import Html exposing (Html)

> Html.text "hello"
<internals> : Html msg

> Html.text
<function> : String -> Html msg"""
            , Html.p []
                [ Html.text "If you create a module in your project named "
                , Html.code [] [ Html.text "MyThing" ]
                , Html.text " in your project, you can say "
                , Html.code [] [ Html.text "import MyThing" ]
                , Html.text " in the REPL as well. Any module that is accessible in your project should be accessible in the REPL."
                ]
            , Html.hr [] []
            , Html.h2 [ Attr.class "scroll-mt-24" ] [ Html.text "Exit" ]
            , Html.p []
                [ Html.text "To exit the REPL, you can type "
                , Html.code [] [ Html.text ":exit" ]
                , Html.text "."
                ]
            , Html.p []
                [ Html.text "You can also press "
                , Html.code [] [ Html.text "ctrl-d" ]
                , Html.text " or "
                , Html.code [] [ Html.text "ctrl-c" ]
                , Html.text " on some platforms."
                ]
            , Html.hr [] []
            , Html.h2 [ Attr.class "scroll-mt-24" ] [ Html.text "Flags" ]
            , Html.p [] [ Html.text "You can customize this command with the following flags:" ]
            , Properties.view
                [ { name = "--interpreter=<interpreter>"
                  , type_ = Nothing
                  , children = [ Html.text "Path to a alternate JS interpreter, like node or nodejs." ]
                  }
                , { name = "--no-colors"
                  , type_ = Nothing
                  , children = [ Html.text "Turn off the colors in the REPL. This can help if you are having trouble reading the values. Some terminals use a custom color scheme that diverges significantly from the standard ANSI colors, so another path may be to pick a more standard color scheme." ]
                  }
                ]
            , References.view
                [ "https://github.com/elm/compiler/blob/0.19.1/hints/repl.md"
                ]
            ]

        Route.Init ->
            [ Html.h1 [] [ Html.text "guida init" ]
            ]

        Route.Make ->
            [ Html.h1 [] [ Html.text "guida make" ]
            ]

        Route.Install ->
            [ Html.h1 [] [ Html.text "guida install" ]
            ]

        Route.Uninstall ->
            [ Html.h1 [] [ Html.text "guida uninstall" ]
            ]

        Route.Bump ->
            [ Html.h1 [] [ Html.text "guida bump" ]
            ]

        Route.Diff ->
            [ Html.h1 [] [ Html.text "guida diff" ]
            ]

        Route.Publish ->
            [ Html.h1 [] [ Html.text "guida publish" ]
            ]

        Route.Format ->
            [ Html.h1 [] [ Html.text "guida format" ]
            ]

        Route.Test ->
            [ Html.h1 [] [ Html.text "guida test" ]
            ]


hintView : Route.Hint -> List (Html msg)
hintView hint =
    case hint of
        _ ->
            []


sidebarNavigation : Model -> Navigation
sidebarNavigation model =
    let
        activeCommand cmd =
            model.section == Route.Commands cmd

        activeHint hint =
            model.section == Route.Hints hint
    in
    [ { title = "Guide"
      , links =
            [ { title = "Introduction", href = "/docs", active = model.section == Route.Introduction }
            , { title = "Syntax", href = "/docs/syntax", active = model.section == Route.Syntax }
            , { title = "From JavaScript or Elm?", href = "/docs/from-javascript-or-elm", active = model.section == Route.FromJavaScriptOrElm }
            , { title = "guida.json", href = "/docs/guida-json", active = model.section == Route.GuidaJson }
            , { title = "Records", href = "/docs/records", active = model.section == Route.Records }
            ]
      }
    , { title = "Commands"
      , links =
            [ { title = "repl", href = "/docs/1.0.0/commands/repl", active = activeCommand Route.Repl }
            , { title = "init", href = "/docs/1.0.0/commands/init", active = activeCommand Route.Init }
            , { title = "make", href = "/docs/1.0.0/commands/make", active = activeCommand Route.Make }
            , { title = "install", href = "/docs/1.0.0/commands/install", active = activeCommand Route.Install }
            , { title = "uninstall", href = "/docs/1.0.0/commands/uninstall", active = activeCommand Route.Uninstall }
            , { title = "bump", href = "/docs/1.0.0/commands/bump", active = activeCommand Route.Bump }
            , { title = "diff", href = "/docs/1.0.0/commands/diff", active = activeCommand Route.Diff }
            , { title = "publish", href = "/docs/1.0.0/commands/publish", active = activeCommand Route.Publish }
            , { title = "format", href = "/docs/1.0.0/commands/format", active = activeCommand Route.Format }
            , { title = "test", href = "/docs/1.0.0/commands/test", active = activeCommand Route.Test }
            ]
      }
    , { title = "Hints"
      , links =
            [ { title = "Bad recursion", href = "/docs/1.0.0/hints/bad-recursion", active = activeHint Route.BadRecursion }
            , { title = "Comparing custom types", href = "/docs/1.0.0/hints/comparing-custom-types", active = activeHint Route.ComparingCustomTypes }
            , { title = "Comparing records", href = "/docs/1.0.0/hints/comparing-records", active = activeHint Route.ComparingRecords }
            , { title = "Implicit casts", href = "/docs/1.0.0/hints/implicit-casts", active = activeHint Route.ImplicitCasts }
            , { title = "Import cycles", href = "/docs/1.0.0/hints/import-cycles", active = activeHint Route.ImportCycles }
            , { title = "Imports", href = "/docs/1.0.0/hints/imports", active = activeHint Route.Imports }
            , { title = "Infinite type", href = "/docs/1.0.0/hints/infinite-type", active = activeHint Route.InfiniteType }
            , { title = "Missing patterns", href = "/docs/1.0.0/hints/missing-patterns", active = activeHint Route.MissingPatterns }
            , { title = "Optimize", href = "/docs/1.0.0/hints/optimize", active = activeHint Route.Optimize }
            , { title = "Port modules", href = "/docs/1.0.0/hints/port-modules", active = activeHint Route.PortModules }
            , { title = "Recursive alias", href = "/docs/1.0.0/hints/recursive-alias", active = activeHint Route.RecursiveAlias }
            , { title = "Shadowing", href = "/docs/1.0.0/hints/shadowing", active = activeHint Route.Shadowing }
            , { title = "Tuples", href = "/docs/1.0.0/hints/tuples", active = activeHint Route.Tuples }
            , { title = "Type annotations", href = "/docs/1.0.0/hints/type-annotations", active = activeHint Route.TypeAnnotations }
            ]
      }
    ]
