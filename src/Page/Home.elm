module Page.Home exposing (..)

import Data.Taco as Taco exposing (Taco)
import Data.Types exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import RemoteData exposing (WebData)
import Return
import View.GoogleMap as GoogleMap exposing (Marker)
import View.Spinners as Spinners


type alias Model =
    {}


type Msg
    = NoOp


view : Taco -> Model -> Html Msg
view taco model =
    let
        marker : Marker
        marker =
            { position = { lat = 6.211003, lng = -75.5630472 }
            , title = "Daniel Cardona Rojas"
            , draggable = False
            , infoWindow = Just { content = "Daniel Cardona" }
            }
    in
    List.singleton marker
        |> GoogleMap.map
            [ attribute "map-type" "roadmap"
            , attribute "zoom" "10"
            , attribute "zoom-control" "false"
            , attribute "fit-to-markers" ""
            , attribute "draggable" "true"
            , id "home-map"
            ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            Return.singleton model


init : ( Model, Cmd Msg )
init =
    Return.singleton {}
