module Common exposing (..)

import Mouse
import Random
import Time


config =
    { speed = 0.05
    , dropCooldown = 100
    , catcherWidth = 100
    }


type alias Model =
    { droplets : List Droplet
    , arena : ( Float, Float )
    , timeSinceLastDrop : Time.Time
    , randomSeed : Random.Seed
    , catcher : Catcher
    }


type alias Catcher =
    { pos : Pos -- left anchor of pos
    , lastPos : Pos
    , width : Float
    }


type alias Droplet =
    { pos : Pos
    , lastPos : Pos
    }


type alias Pos =
    { x : Float
    , y : Float
    }


type alias Line =
    ( Pos, Pos )


type Msg
    = AnimFrame Time.Time
    | MouseMove Pos
