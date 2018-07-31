port module Ports.LocalStorage exposing (..)

import Json.Encode exposing (Value)

port storeSession : Value -> Cmd msg

port onSessionChange : (Value -> msg) -> Sub msg

port retrieveSession : () -> Cmd msg
