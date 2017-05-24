module Main exposing (main)

import AnimationFrame
import Common exposing (..)
import Html
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
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AnimFrame time ->
            ( updateAnimFrame model time, Cmd.none )


updateAnimFrame : Model -> Time.Time -> Model
updateAnimFrame model time =
    { model
        | droplets = animDroplets time model.droplets
    }


animDroplets : Time.Time -> List Droplet -> List Droplet
animDroplets time droplets =
    List.map (animDroplet time) droplets


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
