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
    let
        defaultPos =
            Pos 400 225
    in
    ( { droplets = []
      , arena = ( 800, 450 )
      , timeSinceLastDrop = 0
      , randomSeed = Random.initialSeed 42
      , catcher =
            { width = config.catcherWidth
            , pos = defaultPos
            , lastPos = defaultPos
            }
      , mousePos = defaultPos
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AnimFrame time ->
            ( updateAnimFrame time model, Cmd.none )

        MouseMove mousePos ->
            ( { model | mousePos = mousePos }, Cmd.none )


moveCatcher : Time.Time -> Model -> Model
moveCatcher time model =
    let
        curPos =
            model.catcher.pos

        desiredPos =
            Pos (model.mousePos.x - (config.catcherWidth / 2)) model.mousePos.y

        travelDist =
            distance curPos desiredPos

        -- move a max speed of x/s
        desiredRate =
            travelDist / time

        newPos =
            if desiredRate > config.catcherSpeed then
                Pos
                    (curPos.x - ((curPos.x - desiredPos.x) * (config.catcherSpeed / desiredRate)))
                    (curPos.y - ((curPos.y - desiredPos.y) * (config.catcherSpeed / desiredRate)))
            else
                desiredPos

        catcher =
            model.catcher

        newCatcher =
            { catcher
                | pos = newPos
                , lastPos = catcher.pos
            }
    in
    { model
        | catcher = newCatcher
    }


distance : Pos -> Pos -> Float
distance a b =
    sqrt (sq (a.x - b.x) + sq (a.y - b.y))


sq : number -> number
sq num =
    num * num


updateAnimFrame : Time.Time -> Model -> Model
updateAnimFrame time model =
    model
        |> updateTsld time
        |> addDroplets time
        |> clearDroplets
        |> moveCatcher time
        |> catchDroplets
        |> animDroplets time


catchDroplets : Model -> Model
catchDroplets model =
    { model
        | droplets = List.filter (not << isTouchingCatcher model.catcher) model.droplets
    }


isTouchingCatcher : Catcher -> Droplet -> Bool
isTouchingCatcher catcher droplet =
    let
        a =
            Pos catcher.pos.x catcher.pos.y

        b =
            Pos (catcher.pos.x + config.catcherWidth) catcher.pos.y

        c =
            Pos (catcher.lastPos.x + config.catcherWidth) catcher.lastPos.y

        d =
            Pos catcher.lastPos.x catcher.lastPos.y

        catcherLines =
            [ ( a, b )
            , ( b, c )
            , ( c, d )
            , ( d, a )
            ]
    in
    doesLineIntersectLines ( droplet.pos, droplet.lastPos ) catcherLines
        || (List.length (List.filter (doLinesIntersect ( droplet.pos, Pos -1000 -1000 )) catcherLines) % 2 == 1)


doesLineIntersectLines : Line -> List Line -> Bool
doesLineIntersectLines line lines =
    List.any (doLinesIntersect line) lines


doLinesIntersect : Line -> Line -> Bool
doLinesIntersect line1 line2 =
    -- https://stackoverflow.com/a/24392281
    let
        ( line1A, line1B ) =
            line1

        ( line2A, line2B ) =
            line2

        a =
            line1A.x

        b =
            line1A.y

        c =
            line1B.x

        d =
            line1B.y

        p =
            line2A.x

        q =
            line2A.y

        r =
            line2B.x

        s =
            line2B.y

        det =
            (c - a) * (s - q) - (r - p) * (d - b)
    in
    if det == 0 then
        False
    else
        let
            lambda =
                ((s - q) * (r - a) + (p - r) * (s - b)) / det

            gamma =
                ((b - d) * (r - a) + (c - a) * (s - b)) / det
        in
        (0 < lambda && lambda < 1) && (0 < gamma && gamma < 1)


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
    droplet.pos.y <= maxHeight


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
    ( { pos = Pos x -10
      , lastPos = Pos x -11
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
        pos =
            droplet.pos

        distance =
            time * config.dropletSpeed

        newPos =
            Pos pos.x (pos.y + distance)
    in
    { droplet
        | pos = newPos
        , lastPos = droplet.pos
    }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs AnimFrame
        ]
