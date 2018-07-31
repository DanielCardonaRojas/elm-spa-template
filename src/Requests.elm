module Requests exposing (..)

import Constants as Const exposing (apiEndpoint)
import Data.Authentication as Authentication exposing (Credentials, Token)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


login : Credentials -> Http.Request Token
login creds =
    Http.request
        { method = "POST"
        , headers = [ Http.header "Access-Control-Allow-Origin" "*" ]
        , url = apiEndpoint.token
        , body = Http.jsonBody <| Authentication.encodeCredentials creds
        , expect = Http.expectJson Authentication.decodeToken
        , timeout = Nothing
        , withCredentials = False
        }


refreshToken : Token -> Http.Request Token
refreshToken token =
    let
        accessTokenDecoder =
            Decode.field "access_token" Decode.string

        updateAccessToken token access =
            { token | accessToken = access }

        updatingDecoder =
            Decode.map (updateAccessToken token) accessTokenDecoder
    in
    Http.request
        { method = "POST"
        , headers = [ Http.header "Authorization" <| "Bearer " ++ token.refreshToken ]
        , url = apiEndpoint.tokenRefresh
        , body = Http.jsonBody Encode.null
        , expect = Http.expectJson updatingDecoder
        , timeout = Nothing
        , withCredentials = False
        }
