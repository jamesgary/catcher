module Common exposing (..)

import Mouse
import Random
import Time


type alias Model =
    { droplets : List Droplet
    , arena : ( Float, Float )
    , timeSinceLastDrop : Time.Time
    , randomSeed : Random.Seed
    , catcher : Catcher
    }


type alias Catcher =
    { pos : Pos
    , width : Float
    }


type alias Droplet =
    { pos : Pos
    }


type alias Pos =
    ( Float, Float )


type Msg
    = AnimFrame Time.Time
    | MouseMove Pos


config =
    { speed = 0.05
    , dropCooldown = 100
    , catcherWidth = 100
    }
