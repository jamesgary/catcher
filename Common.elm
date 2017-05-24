module Common exposing (..)

import Random
import Time


type alias Model =
    { droplets : List Droplet
    , arena : ( Float, Float )
    , timeSinceLastDrop : Time.Time
    , randomSeed : Random.Seed
    }


type alias Droplet =
    { pos : Pos
    }


type alias Pos =
    ( Float, Float )


type Msg
    = AnimFrame Time.Time


config =
    { speed = 0.05
    , dropCooldown = 100
    }
