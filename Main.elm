module Main exposing (main)

import AnimationFrame
import Common exposing (..)
import Html
import Mouse
import Random
import Time
import View exposing (view)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( { droplets = []
      , arena = ( 800, 450 )
      , timeSinceLastDrop = 0
      , randomSeed = Random.initialSeed 42
      , catcher =
            { width = config.catcherWidth
            , pos = ( 400, 225 )
            }
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AnimFrame time ->
            ( updateAnimFrame time model, Cmd.none )

        MouseMove mousePos ->
            ( moveCatcher mousePos model, Cmd.none )


moveCatcher : Pos -> Model -> Model
moveCatcher mousePos model =
    let
        ( x, y ) =
            mousePos

        newPos =
            ( x - (config.catcherWidth / 2), y )

        catcher =
            model.catcher

        newCatcher =
            { catcher | pos = newPos }
    in
    { model
        | catcher = newCatcher
    }


updateAnimFrame : Time.Time -> Model -> Model
updateAnimFrame time model =
    model
        |> updateTsld time
        |> addDroplets time
        |> clearDroplets
        |> catchDroplets
        -- TODO time
        |> animDroplets time


catchDroplets : Model -> Model
catchDroplets model =
    { model
        | droplets = List.filter (isntTouchingCatcher model.catcher) model.droplets
    }


isntTouchingCatcher : Catcher -> Droplet -> Bool
isntTouchingCatcher catcher droplet =
    let
        yBuffer =
            10

        ( cx, cy ) =
            catcher.pos

        ( cx1, cx2 ) =
            ( cx, cx + config.catcherWidth )

        ( cy1, cy2 ) =
            ( cy - yBuffer, cy + yBuffer )

        ( dx, dy ) =
            droplet.pos
    in
    not
        ((cx1 <= dx)
            && (dx <= cx2)
            && (cy1 <= dy)
            && (dy <= cy2)
        )


clearDroplets : Model -> Model
clearDroplets model =
    let
        ( width, height ) =
            model.arena
    in
    { model
        | droplets = List.filter (isVisibleDroplet height) model.droplets
    }


isVisibleDroplet : Float -> Droplet -> Bool
isVisibleDroplet maxHeight droplet =
    let
        ( x, y ) =
            droplet.pos
    in
    y <= maxHeight


updateTsld : Time.Time -> Model -> Model
updateTsld time model =
    { model | timeSinceLastDrop = model.timeSinceLastDrop + time }


addDroplets : Time.Time -> Model -> Model
addDroplets time model =
    if model.timeSinceLastDrop > config.dropCooldown then
        let
            ( droplet, newSeed ) =
                newDroplet model.randomSeed
        in
        { model
            | droplets = droplet :: model.droplets
            , timeSinceLastDrop = 0
            , randomSeed = newSeed
        }
    else
        model


newDroplet : Random.Seed -> ( Droplet, Random.Seed )
newDroplet seed =
    let
        ( x, nextSeed ) =
            Random.step (Random.float 0 800) seed
    in
    ( { pos = ( x, -10 )
      }
    , nextSeed
    )


animDroplets : Time.Time -> Model -> Model
animDroplets time model =
    { model
        | droplets = List.map (animDroplet time) model.droplets
    }


animDroplet : Time.Time -> Droplet -> Droplet
animDroplet time droplet =
    let
        ( x, y ) =
            droplet.pos

        distance =
            time * config.speed

        newPos =
            ( x, y + distance )
    in
    { droplet | pos = newPos }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs AnimFrame
        ]
