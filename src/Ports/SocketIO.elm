port module Ports.SocketIO exposing (connect, decodeMessage, emit, listen, send)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Utilities.Misc as Utils


------------- COMMANDS  -----------------


-- Connect to socketio server with url
port connect : String -> Cmd msg 


port listen : String -> Cmd msg


port emit_ : ( String, Encode.Value ) -> Cmd msg


emit : String -> Encode.Value -> Cmd msg
emit =
    curry emit_


send : Encode.Value -> Cmd msg
send =
    emit "message"



------------- SUBSCRIPTIONS  -----------------


port on_ : (( String, Decode.Value ) -> msg) -> Sub msg


decodeMessage : (String -> Decoder msg) -> msg -> Sub msg
decodeMessage toDecoder default =
    let
        toMsg : ( String, Decode.Value ) -> msg
        toMsg t =
            Tuple.second t
                |> Decode.decodeValue (Tuple.first t |> toDecoder |> Utils.traceDecoder "SocketIO decode msg")
                |> Result.withDefault default
    in
    toMsg |> on_
