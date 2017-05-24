module View exposing (view)

import Common exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode


view : Model -> Html Msg
view model =
    let
        ( width, height ) =
            model.arena
    in
    div
        [ class "arena"
        , onMouseMove
        , style [ ( "width", px width ), ( "height", px height ) ]
        ]
        [ viewDroplets model.droplets
        , viewCatcher model.catcher
        ]


viewCatcher : Catcher -> Html Msg
viewCatcher catcher =
    let
        ( x, y ) =
            catcher.pos
    in
    div
        [ class "catcher"
        , style
            [ ( "width", px catcher.width )
            , ( "top", px y )
            , ( "left", px x )
            ]
        ]
        []


viewDroplets : List Droplet -> Html Msg
viewDroplets droplets =
    div [ class "droplets" ] (List.map viewDroplet droplets)


viewDroplet : Droplet -> Html Msg
viewDroplet droplet =
    let
        ( x, y ) =
            droplet.pos
    in
    div
        [ class "droplet"
        , style
            [ ( "top", px y )
            , ( "left", px x )
            ]
        ]
        []


px : a -> String
px a =
    toString a ++ "px"


onMouseMove : Html.Attribute Msg
onMouseMove =
    on "mousemove" (Decode.map MouseMove decodeMousePos)


decodeMousePos : Decode.Decoder ( Float, Float )
decodeMousePos =
    Decode.map2 (,)
        (Decode.at [ "offsetX" ] Decode.float)
        (Decode.at [ "offsetY" ] Decode.float)



--Decode.map2 (,)
--    (Decode.map2 (/)
--        (Decode.at [ "offsetX" ] Decode.float)
--        (Decode.at [ "target", "clientWidth" ] Decode.float)
--    )
--    (Decode.map2 (/)
--        (Decode.at [ "offsetY" ] Decode.float)
--        (Decode.at [ "target", "clientHeight" ] Decode.float)
--    )
