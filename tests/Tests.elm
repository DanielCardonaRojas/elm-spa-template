module Tests exposing (..)

import Application
import Data.Session as Session
import Expect
import Fuzz exposing (int, list, string, tuple)
import Json.Decode as Decode
import Json.Encode as Encode
import Model
import Msgs exposing (..)
import Test exposing (..)


testSessionDecoder : Test
testSessionDecoder =
    fuzz2 string string "Session.decode maps to Session" <|
        \accessToken refreshToken ->
            let
                token =
                    Encode.object
                        [ ( "access_token", Encode.string accessToken )
                        , ( "refresh_token", Encode.string refreshToken )
                        ]

                json =
                    Encode.object [ ( "token", token ) ]

                expectedValue =
                    { accessToken = accessToken
                    , refreshToken = refreshToken
                    }
            in
            Decode.decodeValue Session.decode json
                |> Expect.equal (Ok <| Session.session (Just expectedValue))


testSessionFromValue : Test
testSessionFromValue =
    fuzz2 string string "Session.fromValue" <|
        \accessToken refreshToken ->
            let
                token =
                    Encode.object
                        [ ( "access_token", Encode.string accessToken )
                        , ( "refresh_token", Encode.string refreshToken )
                        ]

                json =
                    Encode.object [ ( "token", token ) ]

                expectedValue =
                    { accessToken = accessToken
                    , refreshToken = refreshToken
                    }
            in
            Session.fromValue json
                |> Expect.equal (Just expectedValue |> Session.session)



-- Updates


testMainUpdate : Test
testMainUpdate =
    let
        update_ =
            List.foldl (\msg mdl -> Application.update msg mdl |> Tuple.first)

        toggleSideBarUpdate =
            test "Updates on toggle sidebar" <|
                \_ ->
                    [ ToggleSideBar ]
                        |> update_ Model.init
                        |> Expect.notEqual Model.init

        noMessagesNoUpdates =
            test "No messages no updates" <|
                \_ ->
                    []
                        |> update_ Model.init
                        |> Expect.equal Model.init
    in
    describe "Main update tests"
        [ toggleSideBarUpdate
        , noMessagesNoUpdates
        ]
