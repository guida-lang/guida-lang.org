module Data.Examples exposing
    ( Example
    , animation
    , book
    , buttons
    , cards
    , clock
    , crate
    , cube
    , dragAndDrop
    , firstPerson
    , forms
    , groceries
    , hello
    , imagePreviews
    , keyboard
    , mario
    , mouse
    , numbers
    , picture
    , positions
    , quotes
    , shapes
    , textFields
    , thwomp
    , time
    , triangle
    , turtle
    , upload
    )

import Data.Registry.Defaults as Defaults
import Data.Registry.Package exposing (Package)
import Data.Version as V


type alias Example =
    { direct : List Package
    , indirect : List Package
    , content : String
    }


animation : Example
animation =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Create animations that spin, wave, and zig-zag.
-- This one is a little red wagon bumping along a dirt road.
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/

import Playground exposing (..)


main =
    animation view


view time =
    [ octagon darkGray 36
        |> moveLeft 100
        |> rotate (spin 3 time)
    , octagon darkGray 36
        |> moveRight 100
        |> rotate (spin 3 time)
    , rectangle red 300 80
        |> moveUp (wave 50 54 2 time)
        |> rotate (zigzag -2 2 8 time)
    ]
    """
    }


book : Example
book =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Make a GET request to load a book called "Public Opinion"
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/http.html

import Browser
import Html exposing (Html, pre, text)
import Http



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | Loading
    | Success String


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Http.get
        { url = "/assets/public-opinion.txt"
        , expect = Http.expectString GotText
        }
    )



-- UPDATE


type Msg
    = GotText (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotText result ->
            case result of
                Ok fullText ->
                    ( Success fullText, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        Failure ->
            text "I was unable to load your book."

        Loading ->
            text "Loading..."

        Success fullText ->
            pre [] [ text fullText ]
    """
    }


buttons : Example
buttons =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Press buttons to increment and decrement a counter.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/buttons.html

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    Int


init : Model
init =
    0



-- UPDATE


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



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (String.fromInt model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]
    """
    }


cards : Example
cards =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Press a button to draw a random card.
--
-- Dependencies:
--   guida install elm/random

import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (..)
import Random



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { card : Card
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Three
    , Cmd.none
    )


type Card
    = Ace
    | Two
    | Three
    | Four
    | Five
    | Six
    | Seven
    | Eight
    | Nine
    | Ten
    | Jack
    | Queen
    | King



-- UPDATE


type Msg
    = Draw
    | NewCard Card


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Draw ->
            ( model
            , Random.generate NewCard cardGenerator
            )

        NewCard newCard ->
            ( Model newCard
            , Cmd.none
            )


cardGenerator : Random.Generator Card
cardGenerator =
    Random.uniform Ace
        [ Two
        , Three
        , Four
        , Five
        , Six
        , Seven
        , Eight
        , Nine
        , Ten
        , Jack
        , Queen
        , King
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Draw ] [ text "Draw" ]
        , div [ style "font-size" "12em" ] [ text (viewCard model.card) ]
        ]


viewCard : Card -> String
viewCard card =
    case card of
        Ace ->
            "🂡"

        Two ->
            "🂢"

        Three ->
            "🂣"

        Four ->
            "🂤"

        Five ->
            "🂥"

        Six ->
            "🂦"

        Seven ->
            "🂧"

        Eight ->
            "🂨"

        Nine ->
            "🂩"

        Ten ->
            "🂪"

        Jack ->
            "🂫"

        Queen ->
            "🂭"

        King ->
            "🂮"
    """
    }


clock : Example
clock =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Show an analog clock for your time zone.
--
-- Dependencies:
--   guida install elm/svg
--   guida install elm/time
--
-- For a simpler version, check out:
--   https://guida-lang.org/examples/time

import Browser
import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Task
import Time



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0)
    , Cmd.batch
        [ Task.perform AdjustTimeZone Time.here
        , Task.perform Tick Time.now
        ]
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
    let
        hour =
            toFloat (Time.toHour model.zone model.time)

        minute =
            toFloat (Time.toMinute model.zone model.time)

        second =
            toFloat (Time.toSecond model.zone model.time)
    in
    svg
        [ viewBox "0 0 400 400"
        , width "400"
        , height "400"
        ]
        [ circle [ cx "200", cy "200", r "120", fill "#1293D8" ] []
        , viewHand 6 60 (hour / 12)
        , viewHand 6 90 (minute / 60)
        , viewHand 3 90 (second / 60)
        ]


viewHand : Int -> Float -> Float -> Svg msg
viewHand width length turns =
    let
        t =
            2 * pi * (turns - 0.25)

        x =
            200 + length * cos t

        y =
            200 + length * sin t
    in
    line
        [ x1 "200"
        , y1 "200"
        , x2 (String.fromFloat x)
        , y2 (String.fromFloat y)
        , stroke "white"
        , strokeWidth (String.fromInt width)
        , strokeLinecap "round"
        ]
        []
    """
    }


crate : Example
crate =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Demonstrate how to load textures and put them on a cube.
--
-- Dependencies:
--   guida install elm-explorations/linear-algebra
--   guida install elm-explorations/webgl

import Browser
import Browser.Events as E
import Html exposing (Html)
import Html.Attributes exposing (height, style, width)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Result
import Task
import WebGL
import WebGL.Texture as Texture



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = \\msg model -> ( update msg model, Cmd.none )
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { angle : Float
    , texture : Maybe Texture.Texture
    }


init : () -> ( Model, Cmd Msg )
init () =
    ( { angle = 0
      , texture = Nothing
      }
    , Task.attempt GotTexture (Texture.load "/images/wood-crate.jpg")
    )



-- UPDATE


type Msg
    = TimeDelta Float
    | GotTexture (Result Texture.Error Texture.Texture)


update : Msg -> Model -> Model
update msg model =
    case msg of
        TimeDelta dt ->
            { model | angle = model.angle + dt / 5000 }

        GotTexture result ->
            { model | texture = Result.toMaybe result }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    E.onAnimationFrameDelta TimeDelta



-- VIEW


view : Model -> Html Msg
view model =
    case model.texture of
        Nothing ->
            Html.text "Loading texture..."

        Just texture ->
            WebGL.toHtml
                [ width 400
                , height 400
                , style "display" "block"
                ]
                [ WebGL.entity vertexShader fragmentShader crateMesh (toUniforms model.angle texture)
                ]



-- UNIFORMS


type alias Uniforms =
    { rotation : Mat4
    , perspective : Mat4
    , camera : Mat4
    , texture : Texture.Texture
    }


toUniforms : Float -> Texture.Texture -> Uniforms
toUniforms angle texture =
    { rotation =
        Mat4.mul
            (Mat4.makeRotate (3 * angle) (vec3 0 1 0))
            (Mat4.makeRotate (2 * angle) (vec3 1 0 0))
    , perspective = perspective
    , camera = camera
    , texture = texture
    }


perspective : Mat4
perspective =
    Mat4.makePerspective 45 1 0.01 100


camera : Mat4
camera =
    Mat4.makeLookAt (vec3 0 0 5) (vec3 0 0 0) (vec3 0 1 0)



-- MESH


type alias Vertex =
    { position : Vec3
    , coord : Vec2
    }


crateMesh : WebGL.Mesh Vertex
crateMesh =
    WebGL.triangles <|
        List.concatMap rotatedSquare <|
            [ ( 0, 0 )
            , ( 90, 0 )
            , ( 180, 0 )
            , ( 270, 0 )
            , ( 0, 90 )
            , ( 0, 270 )
            ]


rotatedSquare : ( Float, Float ) -> List ( Vertex, Vertex, Vertex )
rotatedSquare ( angleXZ, angleYZ ) =
    let
        transformMat =
            Mat4.mul
                (Mat4.makeRotate (degrees angleXZ) Vec3.j)
                (Mat4.makeRotate (degrees angleYZ) Vec3.i)

        transform vertex =
            { vertex | position = Mat4.transform transformMat vertex.position }

        transformTriangle ( a, b, c ) =
            ( transform a, transform b, transform c )
    in
    List.map transformTriangle square


square : List ( Vertex, Vertex, Vertex )
square =
    let
        topLeft =
            Vertex (vec3 -1 1 1) (vec2 0 1)

        topRight =
            Vertex (vec3 1 1 1) (vec2 1 1)

        bottomLeft =
            Vertex (vec3 -1 -1 1) (vec2 0 0)

        bottomRight =
            Vertex (vec3 1 -1 1) (vec2 1 0)
    in
    [ ( topLeft, topRight, bottomLeft )
    , ( bottomLeft, topRight, bottomRight )
    ]



-- SHADERS


vertexShader : WebGL.Shader Vertex Uniforms { vcoord : Vec2 }
vertexShader =
    [glsl|
    attribute vec3 position;
    attribute vec2 coord;
    uniform mat4 perspective;
    uniform mat4 camera;
    uniform mat4 rotation;
    varying vec2 vcoord;

    void main () {
        gl_Position = perspective * camera * rotation * vec4(position, 1.0);
        vcoord = coord;
    }
  |]


fragmentShader : WebGL.Shader {} Uniforms { vcoord : Vec2 }
fragmentShader =
    [glsl|
    precision mediump float;
    uniform sampler2D texture;
    varying vec2 vcoord;

    void main () {
        gl_FragColor = texture2D(texture, vcoord);
    }
  |]
    """
    }


cube : Example
cube =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Render a spinning cube.
--
-- Dependencies:
--   guida install elm-explorations/linear-algebra
--   guida install elm-explorations/webgl

import Browser
import Browser.Events as E
import Html exposing (Html)
import Html.Attributes exposing (height, style, width)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import WebGL



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    Float


init : () -> ( Model, Cmd Msg )
init () =
    ( 0, Cmd.none )



-- UPDATE


type Msg
    = TimeDelta Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg angle =
    case msg of
        TimeDelta dt ->
            ( angle + dt / 5000, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    E.onAnimationFrameDelta TimeDelta



-- VIEW


view : Model -> Html Msg
view angle =
    WebGL.toHtml
        [ width 400
        , height 400
        , style "display" "block"
        ]
        [ WebGL.entity vertexShader fragmentShader cubeMesh (uniforms angle)
        ]


type alias Uniforms =
    { rotation : Mat4
    , perspective : Mat4
    , camera : Mat4
    }


uniforms : Float -> Uniforms
uniforms angle =
    { rotation =
        Mat4.mul
            (Mat4.makeRotate (3 * angle) (vec3 0 1 0))
            (Mat4.makeRotate (2 * angle) (vec3 1 0 0))
    , perspective = Mat4.makePerspective 45 1 0.01 100
    , camera = Mat4.makeLookAt (vec3 0 0 5) (vec3 0 0 0) (vec3 0 1 0)
    }



-- MESH


type alias Vertex =
    { color : Vec3
    , position : Vec3
    }


cubeMesh : WebGL.Mesh Vertex
cubeMesh =
    let
        rft =
            vec3 1 1 1

        lft =
            vec3 -1 1 1

        lbt =
            vec3 -1 -1 1

        rbt =
            vec3 1 -1 1

        rbb =
            vec3 1 -1 -1

        rfb =
            vec3 1 1 -1

        lfb =
            vec3 -1 1 -1

        lbb =
            vec3 -1 -1 -1
    in
    WebGL.triangles <|
        List.concat <|
            [ face (vec3 115 210 22) rft rfb rbb rbt

            -- green
            , face (vec3 52 101 164) rft rfb lfb lft

            -- blue
            , face (vec3 237 212 0) rft lft lbt rbt

            -- yellow
            , face (vec3 204 0 0) rfb lfb lbb rbb

            -- red
            , face (vec3 117 80 123) lft lfb lbb lbt

            -- purple
            , face (vec3 245 121 0) rbt rbb lbb lbt

            -- orange
            ]


face : Vec3 -> Vec3 -> Vec3 -> Vec3 -> Vec3 -> List ( Vertex, Vertex, Vertex )
face color a b c d =
    let
        vertex position =
            Vertex (Vec3.scale (1 / 255) color) position
    in
    [ ( vertex a, vertex b, vertex c )
    , ( vertex c, vertex d, vertex a )
    ]



-- SHADERS


vertexShader : WebGL.Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|
    attribute vec3 position;
    attribute vec3 color;
    uniform mat4 perspective;
    uniform mat4 camera;
    uniform mat4 rotation;
    varying vec3 vcolor;
    void main () {
        gl_Position = perspective * camera * rotation * vec4(position, 1.0);
        vcolor = color;
    }
  |]


fragmentShader : WebGL.Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|
    precision mediump float;
    varying vec3 vcolor;
    void main () {
        gl_FragColor = 0.8 * vec4(vcolor, 1.0);
    }
  |]
    """
    }


dragAndDrop : Example
dragAndDrop =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Image upload with a drag and drop zone.
--
-- Dependencies:
--   guida install elm/file
--   guida install elm/json

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { hover : Bool
    , files : List File
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model False [], Cmd.none )



-- UPDATE


type Msg
    = Pick
    | DragEnter
    | DragLeave
    | GotFiles File (List File)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Pick ->
            ( model
            , Select.files [ "image/*" ] GotFiles
            )

        DragEnter ->
            ( { model | hover = True }
            , Cmd.none
            )

        DragLeave ->
            ( { model | hover = False }
            , Cmd.none
            )

        GotFiles file files ->
            ( { model
                | files =
                    file :: files
                , hover =
                    False
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style "border"
            (if model.hover then
                "6px dashed purple"

             else
                "6px dashed #ccc"
            )
        , style "border-radius" "20px"
        , style "width" "480px"
        , style "height" "100px"
        , style "margin" "100px auto"
        , style "padding" "20px"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "justify-content" "center"
        , style "align-items" "center"
        , hijackOn "dragenter" (D.succeed DragEnter)
        , hijackOn "dragover" (D.succeed DragEnter)
        , hijackOn "dragleave" (D.succeed DragLeave)
        , hijackOn "drop" dropDecoder
        ]
        [ button [ onClick Pick ] [ text "Upload Images" ]
        , span [ style "color" "#ccc" ] [ text (Debug.toString model) ]
        ]


dropDecoder : D.Decoder Msg
dropDecoder =
    D.at [ "dataTransfer", "files" ] (D.oneOrMore GotFiles File.decoder)


hijackOn : String -> D.Decoder msg -> Attribute msg
hijackOn event decoder =
    preventDefaultOn event (D.map hijack decoder)


hijack : msg -> ( msg, Bool )
hijack msg =
    ( msg, True )
    """
    }


firstPerson : Example
firstPerson =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Walk around in 3D space using the keyboard.
--
-- Dependencies:
--   guida install elm-explorations/linear-algebra
--   guida install elm-explorations/webgl
--
-- Try adding the ability to crouch or to land on top of the crate!

import Browser
import Browser.Dom as Dom
import Browser.Events as E
import Html exposing (Html, div, p, text)
import Html.Attributes exposing (height, style, width)
import Json.Decode as D
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Task
import WebGL
import WebGL.Texture as Texture



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = \\msg model -> ( update msg model, Cmd.none )
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { keys : Keys
    , width : Float
    , height : Float
    , person : Person
    , texture : Maybe Texture.Texture
    }


type alias Keys =
    { up : Bool
    , left : Bool
    , down : Bool
    , right : Bool
    , space : Bool
    }


type alias Person =
    { position : Vec3
    , velocity : Vec3
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { keys = noKeys
      , width = 400
      , height = 400
      , person = Person (vec3 0 eyeLevel -10) (vec3 0 0 0)
      , texture = Nothing
      }
    , Cmd.batch
        [ Task.attempt GotTexture (Texture.load "/images/wood-crate.jpg")
        , Task.perform (\\{ viewport } -> Resized viewport.width viewport.height) Dom.getViewport
        ]
    )


eyeLevel : Float
eyeLevel =
    2


noKeys : Keys
noKeys =
    Keys False False False False False



-- UPDATE


type Msg
    = GotTexture (Result Texture.Error Texture.Texture)
    | KeyChanged Bool String
    | TimeDelta Float
    | Resized Float Float
    | VisibilityChanged E.Visibility


update : Msg -> Model -> Model
update msg model =
    case msg of
        GotTexture result ->
            { model | texture = Result.toMaybe result }

        KeyChanged isDown key ->
            { model | keys = updateKeys isDown key model.keys }

        TimeDelta dt ->
            { model | person = updatePerson dt model.keys model.person }

        Resized width height ->
            { model
                | width =
                    width
                , height =
                    height
            }

        VisibilityChanged _ ->
            { model | keys = noKeys }


updateKeys : Bool -> String -> Keys -> Keys
updateKeys isDown key keys =
    case key of
        " " ->
            { keys | space = isDown }

        "ArrowUp" ->
            { keys | up = isDown }

        "ArrowLeft" ->
            { keys | left = isDown }

        "ArrowDown" ->
            { keys | down = isDown }

        "ArrowRight" ->
            { keys | right = isDown }

        _ ->
            keys


updatePerson : Float -> Keys -> Person -> Person
updatePerson dt keys person =
    let
        velocity =
            stepVelocity dt keys person

        position =
            Vec3.add person.position (Vec3.scale (dt / 500) velocity)
    in
    if Vec3.getY position < eyeLevel then
        { position = Vec3.setY eyeLevel position
        , velocity = Vec3.setY 0 velocity
        }

    else
        { position = position
        , velocity = velocity
        }


stepVelocity : Float -> Keys -> Person -> Vec3
stepVelocity dt { left, right, up, down, space } person =
    if Vec3.getY person.position > eyeLevel then
        Vec3.setY (Vec3.getY person.velocity - dt / 250) person.velocity

    else
        let
            toV positive negative =
                (if positive then
                    1

                 else
                    0
                )
                    - (if negative then
                        1

                       else
                        0
                      )
        in
        vec3 (toV left right)
            (if space then
                2

             else
                0
            )
            (toV up down)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ E.onResize (\\w h -> Resized (toFloat w) (toFloat h))
        , E.onKeyUp (D.map (KeyChanged False) (D.field "key" D.string))
        , E.onKeyDown (D.map (KeyChanged True) (D.field "key" D.string))
        , E.onAnimationFrameDelta TimeDelta
        , E.onVisibilityChange VisibilityChanged
        ]



-- VIEW


view : Model -> Html Msg
view model =
    let
        entities =
            case model.texture of
                Nothing ->
                    []

                Just texture ->
                    [ viewCrate model.width model.height model.person texture ]
    in
    div
        [ style "position" "absolute"
        , style "left" "0"
        , style "top" "0"
        , style "width" (String.fromFloat model.width ++ "px")
        , style "height" (String.fromFloat model.height ++ "px")
        ]
        [ WebGL.toHtmlWith [ WebGL.depth 1, WebGL.clearColor 1 1 1 1 ]
            [ style "display" "block"
            , width (round model.width)
            , height (round model.height)
            ]
            entities
        , keyboardInstructions model.keys
        ]


viewCrate : Float -> Float -> Person -> Texture.Texture -> WebGL.Entity
viewCrate width height person texture =
    let
        perspective =
            Mat4.mul
                (Mat4.makePerspective 45 (width / height) 0.01 100)
                (Mat4.makeLookAt person.position (Vec3.add person.position Vec3.k) Vec3.j)
    in
    WebGL.entity vertexShader
        fragmentShader
        crate
        { texture = texture
        , perspective = perspective
        }


keyboardInstructions : Keys -> Html msg
keyboardInstructions keys =
    div
        [ style "position" "absolute"
        , style "font-family" "monospace"
        , style "text-align" "center"
        , style "left" "20px"
        , style "right" "20px"
        , style "top" "20px"
        ]
        [ p [] [ text "Walk around with a first person perspective." ]
        , p [] [ text "Arrows keys to move, space bar to jump." ]
        ]



-- MESH


type alias Vertex =
    { position : Vec3
    , coord : Vec2
    }


crate : WebGL.Mesh Vertex
crate =
    WebGL.triangles <|
        List.concatMap rotatedSquare <|
            [ ( 0, 0 )
            , ( 90, 0 )
            , ( 180, 0 )
            , ( 270, 0 )
            , ( 0, 90 )
            , ( 0, -90 )
            ]


rotatedSquare : ( Float, Float ) -> List ( Vertex, Vertex, Vertex )
rotatedSquare ( angleXZ, angleYZ ) =
    let
        transformMat =
            Mat4.mul
                (Mat4.makeRotate (degrees angleXZ) Vec3.j)
                (Mat4.makeRotate (degrees angleYZ) Vec3.i)

        transform vertex =
            { vertex
                | position =
                    Mat4.transform transformMat vertex.position
            }

        transformTriangle ( a, b, c ) =
            ( transform a, transform b, transform c )
    in
    List.map transformTriangle square


square : List ( Vertex, Vertex, Vertex )
square =
    let
        topLeft =
            Vertex (vec3 -1 1 1) (vec2 0 1)

        topRight =
            Vertex (vec3 1 1 1) (vec2 1 1)

        bottomLeft =
            Vertex (vec3 -1 -1 1) (vec2 0 0)

        bottomRight =
            Vertex (vec3 1 -1 1) (vec2 1 0)
    in
    [ ( topLeft, topRight, bottomLeft )
    , ( bottomLeft, topRight, bottomRight )
    ]



-- SHADERS


type alias Uniforms =
    { texture : Texture.Texture
    , perspective : Mat4
    }


vertexShader : WebGL.Shader Vertex Uniforms { vcoord : Vec2 }
vertexShader =
    [glsl|
    attribute vec3 position;
    attribute vec2 coord;
    uniform mat4 perspective;
    varying vec2 vcoord;

    void main () {
      gl_Position = perspective * vec4(position, 1.0);
      vcoord = coord;
    }
  |]


fragmentShader : WebGL.Shader {} Uniforms { vcoord : Vec2 }
fragmentShader =
    [glsl|
    precision mediump float;
    uniform sampler2D texture;
    varying vec2 vcoord;

    void main () {
      gl_FragColor = texture2D(texture, vcoord);
    }
  |]
    """
    }


forms : Example
forms =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Input a user name and password. Make sure the password matches.
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/forms.html

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { name : String
    , password : String
    , passwordAgain : String
    }


init : Model
init =
    Model "" "" ""



-- UPDATE


type Msg
    = Name String
    | Password String
    | PasswordAgain String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }

        Password password ->
            { model | password = password }

        PasswordAgain password ->
            { model | passwordAgain = password }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewInput "text" "Name" model.name Name
        , viewInput "password" "Password" model.password Password
        , viewInput "password" "Re-enter Password" model.passwordAgain PasswordAgain
        , viewValidation model
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewValidation : Model -> Html msg
viewValidation model =
    if model.password == model.passwordAgain then
        div [ style "color" "green" ] [ text "OK" ]

    else
        div [ style "color" "red" ] [ text "Passwords do not match!" ]
    """
    }


groceries : Example
groceries =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Show a list of items I need to buy at the grocery store.

import Html exposing (..)


main =
    div []
        [ h1 [] [ text "My Grocery List" ]
        , ul []
            [ li [] [ text "Black Beans" ]
            , li [] [ text "Limes" ]
            , li [] [ text "Greek Yogurt" ]
            , li [] [ text "Cilantro" ]
            , li [] [ text "Honey" ]
            , li [] [ text "Sweet Potatoes" ]
            , li [] [ text "Cumin" ]
            , li [] [ text "Chili Powder" ]
            , li [] [ text "Quinoa" ]
            ]
        ]
    """
    }


hello : Example
hello =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

import Html exposing (text)


main =
    text "Hello!"
    """
    }


imagePreviews : Example
imagePreviews =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Image upload with a drag and drop zone. See image previews!
--
-- Dependencies:
--   guida install elm/file
--   guida install elm/json

import Browser
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Task



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { hover : Bool
    , previews : List String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model False [], Cmd.none )



-- UPDATE


type Msg
    = Pick
    | DragEnter
    | DragLeave
    | GotFiles File (List File)
    | GotPreviews (List String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Pick ->
            ( model
            , Select.files [ "image/*" ] GotFiles
            )

        DragEnter ->
            ( { model | hover = True }
            , Cmd.none
            )

        DragLeave ->
            ( { model | hover = False }
            , Cmd.none
            )

        GotFiles file files ->
            ( { model | hover = False }
            , Task.perform GotPreviews <|
                Task.sequence <|
                    List.map File.toUrl (file :: files)
            )

        GotPreviews urls ->
            ( { model | previews = urls }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style "border"
            (if model.hover then
                "6px dashed purple"

             else
                "6px dashed #ccc"
            )
        , style "border-radius" "20px"
        , style "width" "480px"
        , style "margin" "100px auto"
        , style "padding" "40px"
        , style "display" "flex"
        , style "flex-direction" "column"
        , style "justify-content" "center"
        , style "align-items" "center"
        , hijackOn "dragenter" (D.succeed DragEnter)
        , hijackOn "dragover" (D.succeed DragEnter)
        , hijackOn "dragleave" (D.succeed DragLeave)
        , hijackOn "drop" dropDecoder
        ]
        [ button [ onClick Pick ] [ text "Upload Images" ]
        , div
            [ style "display" "flex"
            , style "align-items" "center"
            , style "height" "60px"
            , style "padding" "20px"
            ]
            (List.map viewPreview model.previews)
        ]


viewPreview : String -> Html msg
viewPreview url =
    div
        [ style "width" "60px"
        , style "height" "60px"
        , style "background-image" ("url('" ++ url ++ "')")
        , style "background-position" "center"
        , style "background-repeat" "no-repeat"
        , style "background-size" "contain"
        ]
        []


dropDecoder : D.Decoder Msg
dropDecoder =
    D.at [ "dataTransfer", "files" ] (D.oneOrMore GotFiles File.decoder)


hijackOn : String -> D.Decoder msg -> Attribute msg
hijackOn event decoder =
    preventDefaultOn event (D.map hijack decoder)


hijack : msg -> ( msg, Bool )
hijack msg =
    ( msg, True )
    """
    }


keyboard : Example
keyboard =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Move a square around with the arrow keys: UP, DOWN, LEFT, RIGHT
-- Try making it move around more quickly!
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/

import Playground exposing (..)


main =
    game view update ( 0, 0 )


view computer ( x, y ) =
    [ square blue 40
        |> move x y
    ]


update computer ( x, y ) =
    ( x + toX computer.keyboard
    , y + toY computer.keyboard
    )
    """
    }


mario : Example
mario =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Walk around with the arrow keys. Press the UP arrow to jump!
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/

import Playground exposing (..)



-- MAIN


main =
    game view
        update
        { x = 0
        , y = 0
        , vx = 0
        , vy = 0
        , dir = "right"
        }



-- VIEW


view computer mario =
    let
        w =
            computer.screen.width

        h =
            computer.screen.height

        b =
            computer.screen.bottom
    in
    [ rectangle (rgb 174 238 238) w h
    , rectangle (rgb 74 163 41) w 100
        |> moveY b
    , image 70 70 (toGif mario)
        |> move mario.x (b + 76 + mario.y)
    ]


toGif mario =
    if mario.y > 0 then
        "/images/mario/jump/" ++ mario.dir ++ ".gif"

    else if mario.vx /= 0 then
        "/images/mario/walk/" ++ mario.dir ++ ".gif"

    else
        "/images/mario/stand/" ++ mario.dir ++ ".gif"



-- UPDATE


update computer mario =
    let
        dt =
            1.666

        vx =
            toX computer.keyboard

        vy =
            if mario.y == 0 then
                if computer.keyboard.up then
                    5

                else
                    0

            else
                mario.vy - dt / 8

        x =
            mario.x + dt * vx

        y =
            mario.y + dt * vy
    in
    { x = x
    , y = max 0 y
    , vx = vx
    , vy = vy
    , dir =
        if vx == 0 then
            mario.dir

        else if vx < 0 then
            "left"

        else
            "right"
    }
    """
    }


mouse : Example
mouse =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Draw a cicle around the mouse. Change its color by pressing down.
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/

import Playground exposing (..)


main =
    game view update ()


view computer memory =
    [ circle lightPurple 30
        |> moveX computer.mouse.x
        |> moveY computer.mouse.y
        |> fade
            (if computer.mouse.down then
                0.2

             else
                1
            )
    ]


update computer memory =
    memory
    """
    }


numbers : Example
numbers =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Press a button to generate a random number between 1 and 6.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/random.html

import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Random



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { dieFace : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model 1
    , Cmd.none
    )



-- UPDATE


type Msg
    = Roll
    | NewFace Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model
            , Random.generate NewFace (Random.int 1 6)
            )

        NewFace newFace ->
            ( Model newFace
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text (String.fromInt model.dieFace) ]
        , button [ onClick Roll ] [ text "Roll" ]
        ]
    """
    }


picture : Example
picture =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Create pictures from simple shapes. Like a tree!
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/

import Playground exposing (..)


main =
    picture
        [ rectangle brown 40 200
            |> moveDown 80
        , circle green 100
            |> moveUp 100
        ]
    """
    }


positions : Example
positions =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- A button that moves to random positions when pressed.
--
-- Dependencies:
--   guida install elm/random

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { x : Int
    , y : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model 100 100
    , Cmd.none
    )



-- UPDATE


type Msg
    = Clicked
    | NewPosition ( Int, Int )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Clicked ->
            ( model
            , Random.generate NewPosition positionGenerator
            )

        NewPosition ( x, y ) ->
            ( Model x y
            , Cmd.none
            )


positionGenerator : Random.Generator ( Int, Int )
positionGenerator =
    Random.map2 Tuple.pair
        (Random.int 50 350)
        (Random.int 50 350)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    button
        [ style "position" "absolute"
        , style "top" (String.fromInt model.x ++ "px")
        , style "left" (String.fromInt model.y ++ "px")
        , onClick Clicked
        ]
        [ text "Click me!" ]
    """
    }


quotes : Example
quotes =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Press a button to send a GET request for random quotes.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/json.html

import Browser
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (..)
import Http
import Json.Decode exposing (Decoder, field, int, map4, string)



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Failure
    | Loading
    | Success Quote


type alias Quote =
    { quote : String
    , source : String
    , author : String
    , year : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getRandomQuote )



-- UPDATE


type Msg
    = MorePlease
    | GotQuote (Result Http.Error Quote)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MorePlease ->
            ( Loading, getRandomQuote )

        GotQuote result ->
            case result of
                Ok quote ->
                    ( Success quote, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Random Quotes" ]
        , viewQuote model
        ]


viewQuote : Model -> Html Msg
viewQuote model =
    case model of
        Failure ->
            div []
                [ text "I could not load a random quote for some reason. "
                , button [ onClick MorePlease ] [ text "Try Again!" ]
                ]

        Loading ->
            text "Loading..."

        Success quote ->
            div []
                [ button [ onClick MorePlease, style "display" "block" ] [ text "More Please!" ]
                , blockquote [] [ text quote.quote ]
                , p [ style "text-align" "right" ]
                    [ text "— "
                    , cite [] [ text quote.source ]
                    , text (" by " ++ quote.author ++ " (" ++ String.fromInt quote.year ++ ")")
                    ]
                ]



-- HTTP


getRandomQuote : Cmd Msg
getRandomQuote =
    Http.get
        { url = "https://elm-lang.org/api/random-quotes"
        , expect = Http.expectJson GotQuote quoteDecoder
        }


quoteDecoder : Decoder Quote
quoteDecoder =
    map4 Quote
        (field "quote" string)
        (field "source" string)
        (field "author" string)
        (field "year" int)
    """
    }


shapes : Example
shapes =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Scalable Vector Graphics (SVG) can be a nice way to draw things in 2D.
-- Here are some common SVG shapes.
--
-- Dependencies:
--   guida install elm/svg

import Html exposing (Html)
import Svg exposing (..)
import Svg.Attributes exposing (..)


main : Html msg
main =
    svg
        [ viewBox "0 0 400 400"
        , width "400"
        , height "400"
        ]
        [ circle
            [ cx "50"
            , cy "50"
            , r "40"
            , fill "red"
            , stroke "black"
            , strokeWidth "3"
            ]
            []
        , rect
            [ x "100"
            , y "10"
            , width "40"
            , height "40"
            , fill "green"
            , stroke "black"
            , strokeWidth "2"
            ]
            []
        , line
            [ x1 "20"
            , y1 "200"
            , x2 "200"
            , y2 "20"
            , stroke "blue"
            , strokeWidth "10"
            , strokeLinecap "round"
            ]
            []
        , polyline
            [ points "200,40 240,40 240,80 280,80 280,120 320,120 320,160"
            , fill "none"
            , stroke "red"
            , strokeWidth "4"
            , strokeDasharray "20,2"
            ]
            []
        , text_
            [ x "130"
            , y "130"
            , fill "black"
            , textAnchor "middle"
            , dominantBaseline "central"
            , transform "rotate(-45 130,130)"
            ]
            [ text "Welcome to Shapes Club"
            ]
        ]



-- There are a lot of odd things about SVG, so always try to find examples
-- to help you understand the weird stuff. Like these:
--
--   https://www.w3schools.com/graphics/svg_examples.asp
--   https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/d
--
-- If you cannot find relevant examples, make an experiment. If you push
-- through the weirdness, you can do a lot with SVG.
    """
    }


textFields : Example
textFields =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- A text input for reversing text. Very useful!
--
-- Read how it works:
--   https://guide.elm-lang.org/architecture/text_fields.html

import Browser
import Html exposing (Attribute, Html, div, input, text)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)



-- MAIN


main =
    Browser.sandbox { init = init, update = update, view = view }



-- MODEL


type alias Model =
    { content : String
    }


init : Model
init =
    { content = "" }



-- UPDATE


type Msg
    = Change String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Change newContent ->
            { model | content = newContent }



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ input [ placeholder "Text to reverse", value model.content, onInput Change ] []
        , div [] [ text (String.reverse model.content) ]
        ]
    """
    }


thwomp : Example
thwomp =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Thwomp looks at your mouse. What is it up to?
--
-- Dependencies:
--   guida install elm/json
--   guida install elm-explorations/linear-algebra
--   guida install elm-explorations/webgl
--
-- Thanks to The PaperNES Guy for the texture:
--   https://the-papernes-guy.deviantart.com/art/Thwomps-Thwomps-Thwomps-186879685

import Browser
import Browser.Dom as Dom
import Browser.Events as E
import Html exposing (Html)
import Html.Attributes exposing (height, style, width)
import Json.Decode as D
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Result
import Task
import WebGL
import WebGL.Texture as Texture



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = \\msg model -> ( update msg model, Cmd.none )
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { width : Float
    , height : Float
    , x : Float
    , y : Float
    , side : Maybe Texture.Texture
    , face : Maybe Texture.Texture
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { width = 0
      , height = 0
      , x = 0
      , y = 0
      , face = Nothing
      , side = Nothing
      }
    , Cmd.batch
        [ Task.perform GotViewport Dom.getViewport
        , Task.attempt GotFace (Texture.loadWith options "/images/thwomp-face.jpg")
        , Task.attempt GotSide (Texture.loadWith options "/images/thwomp-side.jpg")
        ]
    )


options : Texture.Options
options =
    { magnify = Texture.nearest
    , minify = Texture.nearest
    , horizontalWrap = Texture.repeat
    , verticalWrap = Texture.repeat
    , flipY = True
    }



-- UPDATE


type Msg
    = GotFace (Result Texture.Error Texture.Texture)
    | GotSide (Result Texture.Error Texture.Texture)
    | GotViewport Dom.Viewport
    | Resized Int Int
    | MouseMoved Float Float


update : Msg -> Model -> Model
update msg model =
    case msg of
        GotFace result ->
            { model
                | face =
                    Result.toMaybe result
            }

        GotSide result ->
            { model
                | side =
                    Result.toMaybe result
            }

        GotViewport { viewport } ->
            { model
                | width =
                    viewport.width
                , height =
                    viewport.height
            }

        Resized width height ->
            { model
                | width =
                    toFloat width
                , height =
                    toFloat height
            }

        MouseMoved x y ->
            { model
                | x =
                    x
                , y =
                    y
            }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ E.onResize Resized
        , E.onMouseMove decodeMovement
        ]


decodeMovement : D.Decoder Msg
decodeMovement =
    D.map2 MouseMoved
        (D.field "pageX" D.float)
        (D.field "pageY" D.float)



-- VIEW


view : Model -> Html Msg
view model =
    case Maybe.map2 Tuple.pair model.face model.side of
        Nothing ->
            Html.text "Loading textures..."

        Just ( face, side ) ->
            let
                perspective =
                    toPerspective model.x model.y model.width model.height
            in
            WebGL.toHtml
                [ style "display" "block"
                , style "position" "absolute"
                , style "left" "0"
                , style "top" "0"
                , width (round model.width)
                , height (round model.height)
                ]
                [ WebGL.entity vertexShader
                    fragmentShader
                    faceMesh
                    { perspective = perspective
                    , texture = face
                    }
                , WebGL.entity vertexShader
                    fragmentShader
                    sidesMesh
                    { perspective = perspective
                    , texture = side
                    }
                ]


toPerspective : Float -> Float -> Float -> Float -> Mat4
toPerspective x y width height =
    let
        eye =
            Vec3.scale 6 <|
                Vec3.normalize <|
                    vec3 (0.5 - x / width) (y / height - 0.5) 1
    in
    Mat4.mul
        (Mat4.makePerspective 45 (width / height) 0.01 100)
        (Mat4.makeLookAt eye (vec3 0 0 0) Vec3.j)



-- MESHES


type alias Vertex =
    { position : Vec3
    , coord : Vec2
    }


faceMesh : WebGL.Mesh Vertex
faceMesh =
    WebGL.triangles square


sidesMesh : WebGL.Mesh Vertex
sidesMesh =
    WebGL.triangles <|
        List.concatMap rotatedSquare <|
            [ ( 90, 0 )
            , ( 180, 0 )
            , ( 270, 0 )
            , ( 0, 90 )
            , ( 0, 270 )
            ]


rotatedSquare : ( Float, Float ) -> List ( Vertex, Vertex, Vertex )
rotatedSquare ( angleXZ, angleYZ ) =
    let
        transformMat =
            Mat4.mul
                (Mat4.makeRotate (degrees angleXZ) Vec3.j)
                (Mat4.makeRotate (degrees angleYZ) Vec3.i)

        transform vertex =
            { vertex | position = Mat4.transform transformMat vertex.position }

        transformTriangle ( a, b, c ) =
            ( transform a, transform b, transform c )
    in
    List.map transformTriangle square


square : List ( Vertex, Vertex, Vertex )
square =
    let
        topLeft =
            Vertex (vec3 -1 1 1) (vec2 0 1)

        topRight =
            Vertex (vec3 1 1 1) (vec2 1 1)

        bottomLeft =
            Vertex (vec3 -1 -1 1) (vec2 0 0)

        bottomRight =
            Vertex (vec3 1 -1 1) (vec2 1 0)
    in
    [ ( topLeft, topRight, bottomLeft )
    , ( bottomLeft, topRight, bottomRight )
    ]



-- SHADERS


type alias Uniforms =
    { perspective : Mat4
    , texture : Texture.Texture
    }


vertexShader : WebGL.Shader Vertex Uniforms { vcoord : Vec2 }
vertexShader =
    [glsl|
    attribute vec3 position;
    attribute vec2 coord;
    uniform mat4 perspective;
    varying vec2 vcoord;

    void main () {
      gl_Position = perspective * vec4(position, 1.0);
      vcoord = coord.xy;
    }
  |]


fragmentShader : WebGL.Shader {} Uniforms { vcoord : Vec2 }
fragmentShader =
    [glsl|
    precision mediump float;
    uniform sampler2D texture;
    varying vec2 vcoord;

    void main () {
      gl_FragColor = texture2D(texture, vcoord);
    }
  |]
    """
    }


time : Example
time =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Show the current time in your time zone.
--
-- Read how it works:
--   https://guide.elm-lang.org/effects/time.html
--
-- For an analog clock, check out this SVG example:
--   https://guida-lang.org/examples/clock

import Browser
import Html exposing (..)
import Task
import Time



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0)
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { model | zone = newZone }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
    let
        hour =
            String.fromInt (Time.toHour model.zone model.time)

        minute =
            String.fromInt (Time.toMinute model.zone model.time)

        second =
            String.fromInt (Time.toSecond model.zone model.time)
    in
    h1 [] [ text (hour ++ ":" ++ minute ++ ":" ++ second) ]
    """
    }


triangle : Example
triangle =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- guida install elm-explorations/linear-algebra
-- guida install elm-explorations/webgl

import Browser
import Browser.Events as E
import Html exposing (Html)
import Html.Attributes exposing (height, style, width)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import WebGL



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    Float


init : () -> ( Model, Cmd Msg )
init () =
    ( 0, Cmd.none )



-- UPDATE


type Msg
    = TimeDelta Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg currentTime =
    case msg of
        TimeDelta delta ->
            ( delta + currentTime, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    E.onAnimationFrameDelta TimeDelta



-- VIEW


view : Model -> Html msg
view t =
    WebGL.toHtml
        [ width 400
        , height 400
        , style "display" "block"
        ]
        [ WebGL.entity vertexShader fragmentShader mesh { perspective = perspective (t / 1000) }
        ]


perspective : Float -> Mat4
perspective t =
    Mat4.mul
        (Mat4.makePerspective 45 1 0.01 100)
        (Mat4.makeLookAt (vec3 (4 * cos t) 0 (4 * sin t)) (vec3 0 0 0) (vec3 0 1 0))



-- MESH


type alias Vertex =
    { position : Vec3
    , color : Vec3
    }


mesh : WebGL.Mesh Vertex
mesh =
    WebGL.triangles
        [ ( Vertex (vec3 0 0 0) (vec3 1 0 0)
          , Vertex (vec3 1 1 0) (vec3 0 1 0)
          , Vertex (vec3 1 -1 0) (vec3 0 0 1)
          )
        ]



-- SHADERS


type alias Uniforms =
    { perspective : Mat4
    }


vertexShader : WebGL.Shader Vertex Uniforms { vcolor : Vec3 }
vertexShader =
    [glsl|
        attribute vec3 position;
        attribute vec3 color;
        uniform mat4 perspective;
        varying vec3 vcolor;

        void main () {
            gl_Position = perspective * vec4(position, 1.0);
            vcolor = color;
        }
    |]


fragmentShader : WebGL.Shader {} Uniforms { vcolor : Vec3 }
fragmentShader =
    [glsl|
        precision mediump float;
        varying vec3 vcolor;

        void main () {
            gl_FragColor = vec4(vcolor, 1.0);
        }
    |]
    """
    }


turtle : Example
turtle =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- Use arrow keys to move the turtle around.
--
-- Forward with UP and turn with LEFT and RIGHT.
--
-- Learn more about the playground here:
--   https://package.elm-lang.org/packages/evancz/elm-playground/latest/

import Playground exposing (..)


main =
    game view
        update
        { x = 0
        , y = 0
        , angle = 0
        }


view computer turtle =
    [ rectangle blue computer.screen.width computer.screen.height
    , image 96 96 "/images/turtle.gif"
        |> move turtle.x turtle.y
        |> rotate turtle.angle
    ]


update computer turtle =
    { x = turtle.x + toY computer.keyboard * cos (degrees turtle.angle)
    , y = turtle.y + toY computer.keyboard * sin (degrees turtle.angle)
    , angle = turtle.angle - toX computer.keyboard
    }
    """
    }


upload : Example
upload =
    { direct = Defaults.direct
    , indirect = Defaults.indirect
    , content = String.trim """
module Main exposing (main)

-- File upload with the <input type="file"> node.
--
-- Dependencies:
--   guida install elm/file
--   guida install elm/json

import Browser
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as D



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    List File


init : () -> ( Model, Cmd Msg )
init _ =
    ( [], Cmd.none )



-- UPDATE


type Msg
    = GotFiles (List File)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotFiles files ->
            ( files, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ input
            [ type_ "file"
            , multiple True
            , on "change" (D.map GotFiles filesDecoder)
            ]
            []
        , div [] [ text (Debug.toString model) ]
        ]


filesDecoder : D.Decoder (List File)
filesDecoder =
    D.at [ "target", "files" ] (D.list File.decoder)
    """
    }
