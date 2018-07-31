module Data.Session exposing (..)

import Data.Authentication as Authentication exposing (UserClaims)
import Json.Decode as Decode exposing (Decoder, string)
import Json.Encode as Encode exposing (Value)
import Ports.LocalStorage as LocalStorage

type alias Session = 
    { token: Maybe Authentication.Token
    , userClaims: Maybe UserClaims
    }

session : Maybe Authentication.Token -> Session
session token = 
    case token of
        Nothing ->
            { token = Nothing, userClaims = Nothing}
        Just t ->
            { token = Just t, userClaims = Authentication.userClaims t }

attempt : String -> (Authentication.Token -> Cmd msg) -> Session -> (List String, Cmd msg)
attempt attemptedAction toCmd session =  
    case session.token of
        Nothing -> ([ "You have been signed out. Please sign back in to " ++ attemptedAction], Cmd.none)
        Just token -> ([], toCmd token)

decode : Decoder Session
decode =
    Decode.nullable Authentication.decodeToken
    |> Decode.field "token" 
    |> Decode.map session

encode : Session -> Value
encode session =
    Encode.object
        [ ("token", Maybe.map Authentication.encodeToken session.token |> Maybe.withDefault Encode.null)
        , ("user_claims", Maybe.map Authentication.encodeUserClaims session.userClaims |> Maybe.withDefault Encode.null)
        ]

store : Session -> Cmd msg
store session =
    session
    |> encode
    |> LocalStorage.storeSession

fromValue : Value -> Session
fromValue value = 
    value
    |> Decode.decodeValue decode 
    |> Result.toMaybe
    |> Maybe.map .token
    |> Maybe.andThen identity
    |> \t -> session t
