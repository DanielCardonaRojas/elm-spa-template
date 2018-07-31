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
    text "Home page"


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        _ ->
            Return.singleton model


init : ( Model, Cmd Msg )
init =
    Return.singleton {}
