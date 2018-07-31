module View.Dropzone exposing (..)

import Html exposing (..)
import Html.Events as Events
import Json.Decode as Decode exposing (Decoder, string, int)
import Json.Decode.Pipeline as Pipeline exposing (required)
import Utilities.Misc as Utils

{- 
    configurations can be set through attributes changing
    camelcase names for lowercase dash seperated words:

    http://www.dropzonejs.com/#configuration-options
-}

type alias File =
    { name : String
    , status : String
    , bytes : Int
    , mimetype : String
    }

area : List (Attribute msg) -> Html msg
area attrs =
    Html.node "drop-zone" attrs []


fileDecoder =
    Pipeline.decode File
    |> required "name" string
    |> required "status" string
    |> required "size" int
    |> required "type" string

on : String -> (event -> msg) -> Decoder event -> Attribute msg
on name tagger decoder =
    decoder
        |> Decode.map tagger
        |> Utils.traceDecoder ("Dropzone:" ++ name)
        |> Events.on name


onDragOver : ({x: Int, y: Int} -> msg) -> Attribute msg
onDragOver tagger =
    Pipeline.decode (\x y -> {x = x, y = y})
    |> required "offsetX" int
    |> required "offsetY" int
    |> Decode.at ["detail"]
    |> on "dragover" tagger

onAddedFile : (File -> msg) -> Attribute msg
onAddedFile tagger =
    fileDecoder 
    |> Decode.at ["detail", "file"]
    |> on "addedfile" tagger 

onRemovedFile : (File -> msg) -> Attribute msg
onRemovedFile tagger =
    fileDecoder
    |> Decode.at ["detail", "file"]
    |> on "removedfile" tagger

-- TODO: This should have a tagger of type ((File, ServerResponse) -> msg)
onSuccess : (File -> msg) -> Attribute msg
onSuccess tagger =
    fileDecoder
    |> Decode.at ["detail", "file"]
    |> on "success" tagger
