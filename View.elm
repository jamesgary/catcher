module View exposing (view)

import Common exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Svg exposing (polyline, svg)
import Svg.Attributes exposing (fill, points, stroke)


view : Model -> Html Msg
view model =
    let
        ( width, height ) =
            model.arena
    in
    div
        [ class "gameContainer"
        , style
            [ ( "width", px width )
            , ( "height", px height )
            ]
        ]
        [ svg [ Svg.Attributes.class "svgContainer" ]
            [ viewCatcher model.catcher
            ]
        , viewDroplets model.droplets
        , viewGlass
        ]


viewGlass : Html Msg
viewGlass =
    div [ class "glass", onMouseMove, onMouseOut ] []


viewCatcher : Catcher -> Html Msg
viewCatcher catcher =
    let
        pos =
            catcher.pos

        lastPos =
            catcher.lastPos

        cw =
            config.catcherWidth

        pointsStr =
            strFromPos (Pos pos.x pos.y)
                ++ strFromPos (Pos (pos.x + config.catcherWidth) pos.y)
                ++ strFromPos (Pos (lastPos.x + config.catcherWidth) lastPos.y)
                ++ strFromPos (Pos lastPos.x lastPos.y)
                ++ strFromPos (Pos pos.x pos.y)
    in
    svg []
        [ polyline
            [ fill "gray"
            , stroke "black"
            , points pointsStr
            ]
            []
        ]


strFromPos : Pos -> String
strFromPos pos =
    toString pos.x ++ "," ++ toString pos.y ++ " "


viewDroplets : List Droplet -> Html Msg
viewDroplets droplets =
    div [ class "droplets" ] (List.map viewDroplet droplets)


viewDroplet : Droplet -> Html Msg
viewDroplet droplet =
    let
        pos =
            droplet.pos
    in
    div
        [ class "droplet"
        , style
            [ ( "top", px pos.y )
            , ( "left", px pos.x )
            ]
        ]
        []


px : a -> String
px a =
    toString a ++ "px"


onMouseMove : Html.Attribute Msg
onMouseMove =
    on "mousemove" (Decode.map MouseMove decodeMousePos)


onMouseOut : Html.Attribute Msg
onMouseOut =
    on "mouseout" (Decode.map MouseMove decodeMousePos)


decodeMousePos : Decode.Decoder Pos
decodeMousePos =
    Decode.map2 Pos
        (Decode.at [ "offsetX" ] Decode.float)
        (Decode.at [ "offsetY" ] Decode.float)
