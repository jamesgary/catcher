module View exposing (view)

import Common exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Svg exposing (defs, feGaussianBlur, filter, g, line, linearGradient, polygon, stop, svg)
import Svg.Attributes exposing (fill, offset, points, stdDeviation, stroke, x1, x2, y1, y2)


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
        [ viewBackground
        , svg [ Svg.Attributes.class "svgContainer" ]
            [ viewFilters
            , viewCatcher model.catcher
            ]
        , viewDroplets model.droplets
        , viewGlass
        ]


viewBackground : Html Msg
viewBackground =
    div [ class "ground" ] []


viewGlass : Html Msg
viewGlass =
    div [ class "glass", onMouseMove, onMouseOut ] []


viewFilters : Html Msg
viewFilters =
    defs []
        [ linearGradient [ id "catcher-blur-fill", x1 "0", x2 "0", y1 "0", y2 "1" ]
            [ stop [ Svg.Attributes.class "catcher-blur-stop-1", offset "0%" ] []
            , stop [ Svg.Attributes.class "catcher-blur-stop-2", offset "100%" ] []
            ]
        ]


viewCatcher : Catcher -> Html Msg
viewCatcher catcher =
    let
        pos =
            catcher.pos

        lastPos =
            catcher.lastPos

        cw =
            config.catcherWidth

        betterLastPosY =
            if lastPos.y == pos.y then
                lastPos.y + 1
            else
                lastPos.y

        a =
            Pos pos.x pos.y

        b =
            Pos (pos.x + config.catcherWidth) pos.y

        c =
            Pos (lastPos.x + config.catcherWidth) betterLastPosY

        d =
            Pos lastPos.x betterLastPosY

        pointsStr =
            strFromPos a
                ++ strFromPos b
                ++ strFromPos c
                ++ strFromPos d
    in
    g []
        [ polygon
            [ Svg.Attributes.fill "url(#catcher-blur-fill)"
            , points pointsStr
            ]
            []
        , line
            [ Svg.Attributes.class "catcher-line"
            , x1 (toString a.x)
            , y1 (toString a.y)
            , x2 (toString b.x)
            , y2 (toString b.y)
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
            [ ( "transform"
              , "translate(" ++ px pos.x ++ "," ++ px pos.y ++ ")"
              )
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
