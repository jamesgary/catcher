module Common exposing (..)

import Time


type alias Model =
    { droplets : List Droplet
    , arena : ( Float, Float )
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
