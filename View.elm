module View exposing (view)

import Common exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


view : Model -> Html Msg
view model =
    div [] [ viewDroplets model.droplets ]


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
