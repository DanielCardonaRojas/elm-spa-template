module View.GoogleMap exposing (..)

import Constants as Const
import Html exposing (..)
import Html.Attributes exposing (attribute, property)
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder, float)
import Json.Decode.Pipeline as Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)
import Utilities.Misc as Utils


-- This marker type should mirror the same properties described
-- here: https://developers.google.com/maps/documentation/javascript/markers


type alias Marker =
    { title : String
    , position : { lat : Float, lng : Float }
    , draggable : Bool
    , infoWindow : Maybe InfoWindow -- This is an extra value to deal with InfoWindows
    }


decode : Decoder { latitude : Float, longitude : Float }
decode =
    Pipeline.decode (\lat lng -> { latitude = lat, longitude = lng })
        |> required "latitude" float
        |> required "longitude" float


encode : { latitude : Float, longitude : Float } -> Value
encode coordinates =
    Encode.object
        [ ( "latitude", Encode.float coordinates.latitude )
        , ( "longitude", Encode.float coordinates.longitude )
        ]



-- Should have options defined here:
-- https://developers.google.com/maps/documentation/javascript/reference/3.exp/info-window#InfoWindowOptions


type alias InfoWindow =
    { content : String -- Html string on popup
    }


infoWindowEncode : InfoWindow -> Value
infoWindowEncode info =
    Encode.object
        [ ( "content", Encode.string info.content )
        ]


markerEncode : Marker -> Value
markerEncode m =
    let
        position =
            Encode.object
                [ ( "lat", Encode.float m.position.lat )
                , ( "lng", Encode.float m.position.lng )
                ]

        infoWindowsValue =
            Maybe.map infoWindowEncode >> Maybe.withDefault Encode.null
    in
    Encode.object
        [ ( "position", position )
        , ( "title", Encode.string m.title )
        , ( "draggable", Encode.bool m.draggable )
        , ( "infoWindow", infoWindowsValue m.infoWindow )
        ]


map : List (Attribute a) -> List Marker -> Html a
map attrs markers =
    let
        attributes =
            [ attribute "api-key" Const.googleApiKey
            , property "markers" <| Encode.list (List.map markerEncode markers)
            ]
                |> List.append attrs
    in
    Html.node "google-map" attributes []



-- Google map Attributes


onMarkerDragEnd : ({ latitude : Float, longitude : Float } -> msg) -> Attribute msg
onMarkerDragEnd tagger =
    Decode.at [ "detail" ] decode
        |> Decode.map tagger
        |> Utils.traceDecoder "GoogleMapMarkerDragEnd"
        |> Events.on "google-map-marker.dragend"


onMarkerClick : ({ latitude : Float, longitude : Float } -> msg) -> Attribute msg
onMarkerClick tagger =
    Decode.at [ "detail" ] decode
        |> Decode.map tagger
        |> Utils.traceDecoder "GoogleMapMarkerClick"
        |> Events.on "google-map-marker.click"


onMapDragEnd : ({ latitude : Float, longitude : Float } -> msg) -> Attribute msg
onMapDragEnd tagger =
    Decode.at [ "detail" ] decode
        |> Decode.map tagger
        |> Utils.traceDecoder "GoogleMapOnDragEnd"
        |> Events.on "googlemap.dragend"


onMapDragStart : ({ latitude : Float, longitude : Float } -> msg) -> Attribute msg
onMapDragStart tagger =
    Decode.at [ "target" ] decode
        |> Decode.map tagger
        |> Utils.traceDecoder "GoogleMapOnDragStart"
        |> Events.on "google-map-dragstart"


onMapClick : ({ latitude : Float, longitude : Float } -> msg) -> Attribute msg
onMapClick tagger =
    Decode.at [ "detail" ] decode
        |> Decode.map tagger
        |> Utils.traceDecoder "GoogleMapOnClick"
        |> Events.on "googlemap.click"
