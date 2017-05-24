module Common exposing (..)

import Time


type alias Model =
    { droplets : List Droplet
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
    }
