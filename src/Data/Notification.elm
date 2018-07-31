module Data.Notification exposing (..)

import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline exposing (required)
import Json.Encode as Encode


type Kind
    = Success
    | Warning
    | Error


type alias Notification =
    { kind : Kind
    , title : String
    , content : String
    , silent : Bool
    }


type alias Toast =
    { kind : Kind
    , title : String
    , content : String
    }


asToast : Notification -> Toast
asToast n =
    { kind = n.kind, title = n.title, content = n.content }


isToast : Notification -> Bool
isToast =
    not << .silent


kindString : Kind -> String
kindString ttype =
    toString ttype |> String.toLower


kindFromString : String -> Maybe Kind
kindFromString str =
    case String.toLower str of
        "success" ->
            Just Success

        "warning" ->
            Just Warning

        "error" ->
            Just Error

        _ ->
            Nothing


decode : Decoder Notification
decode =
    let
        typeDecoder =
            Decode.string
                |> Decode.andThen
                    (\str ->
                        kindFromString str
                            |> Maybe.map Decode.succeed
                            |> Maybe.withDefault (Decode.fail "Unknown toast type")
                    )
    in
    Pipeline.decode Notification
        |> required "type" typeDecoder
        |> required "title" Decode.string
        |> required "content" Decode.string
        |> required "silent" Decode.bool


encode : Notification -> Encode.Value
encode n =
    Encode.object
        [ ( "type", Encode.string <| kindString n.kind )
        , ( "title", Encode.string n.title )
        , ( "content", Encode.string n.content )
        , ( "silent", Encode.bool n.silent )
        ]
