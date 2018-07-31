module Data.Authentication
    exposing
        ( Credentials
        , Token
        , UserClaims
        , decodeToken
        , encodeCredentials
        , encodeToken
        , encodeUserClaims
        , userClaims
        )

import Base64
import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline as Pipeline exposing (hardcoded, required)
import Json.Encode as Encode exposing (Value)
import Utilities.Misc as Utils


type alias Token =
    { accessToken : String
    , refreshToken : String
    }


type alias Credentials =
    { email : String
    , password : String
    }


type alias UserClaims =
    { email : String
    , role : String
    , organization : String
    , uuid : String
    }


isAdmin : UserClaims -> Bool
isAdmin user =
    user.role == "admin"


decodeToken : Decoder Token
decodeToken =
    Pipeline.decode Token
        |> required "access_token" string
        |> required "refresh_token" string


encodeCredentials : Credentials -> Value
encodeCredentials creds =
    Encode.object
        [ ( "email", Encode.string creds.email )
        , ( "password", Encode.string creds.password )
        ]


encodeToken : Token -> Value
encodeToken token =
    Encode.object
        [ ( "access_token", Encode.string token.accessToken )
        , ( "refresh_token", Encode.string token.refreshToken )
        ]


encodeUserClaims : UserClaims -> Value
encodeUserClaims claims =
    Encode.object
        [ ( "email", Encode.string claims.email )
        , ( "role", Encode.string claims.role )
        , ( "organization", Encode.string claims.organization )
        , ( "uuid", Encode.string claims.uuid )
        ]


userClaims : Token -> Maybe UserClaims
userClaims token =
    decodeJwtPayload token.accessToken userClaimsDecoder



-- Jwt parsing


decodeJwtPayload : String -> Decoder a -> Maybe a
decodeJwtPayload jwt decoder =
    let
        jwtPayload token =
            String.split "." token |> List.drop 1 |> List.head
    in
    jwt
        |> jwtPayload
        |> Maybe.andThen (Base64.decode >> Result.toMaybe)
        |> Maybe.andThen (Decode.decodeString decoder >> Result.toMaybe)


userClaimsDecoder : Decoder UserClaims
userClaimsDecoder =
    Pipeline.decode UserClaims
        |> required "email" string
        |> required "role" string
        |> required "organization" string
        |> required "uuid" string
        |> Decode.field "user_claims"
        |> Utils.traceDecoder "User decoder"
