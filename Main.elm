module Main exposing (main)

import AnimationFrame
import Common exposing (..)
import Html
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
    ( { droplets =
            [ { pos = ( 20, 50 ) }
            , { pos = ( 300, 200 ) }
            ]
      , arena = ( 800, 450 )
      , timeSinceLastDrop = 0
      , randomSeed = Random.initialSeed 42
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AnimFrame time ->
            ( updateAnimFrame time model, Cmd.none )


updateAnimFrame : Time.Time -> Model -> Model
updateAnimFrame time model =
    model
        |> updateTsld time
        |> addDroplets time
        |> animDroplets time


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
