module View.FlatPickr exposing (..)

import Html exposing (..)
import Html.Events as Events
import Html.Attributes as Attributes exposing (attribute, class)
import Json.Decode as Decode exposing (Decoder, string, int)
import Json.Decode.Pipeline as Pipeline exposing (required)
import Utilities.Misc as Utils

{- 
    configurations can be set through attributes changing
    camelcase names for lowercase dash seperated words:

    http://www.dropzonejs.com/#configuration-options
-}

field : List (Attribute msg) -> Html msg
field attrs =
    Html.node "flat-pickr" (attribute "type" "text" :: attribute "readonly" "readonly" :: attrs) []
    --input ([attribute "is" "flat-pickr", attribute "type" "text", attribute "readonly" "readonly"] ++  attrs) []

