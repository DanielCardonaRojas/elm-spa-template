module Page.Login exposing (..)

import Data.Authentication as Authentication exposing (Credentials, Token)
import Data.Route as Route exposing (Route(..))
import Data.Session as Session exposing (Session)
import Data.Taco as Taco exposing (Taco)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode
import Maybe exposing (Maybe(..))
import RemoteData exposing (WebData)
import Requests
import Return
import Utilities.Misc as Utils


type alias Error =
    ( FormField, String )


type alias Model =
    { jwt : WebData Token
    , credentials : Credentials
    , errors : List Error
    , serverError : Maybe Http.Error
    }


type FormField
    = Email
    | Password


type Msg
    = SubmitForm
    | SetField FormField String
    | Authenticate Credentials (WebData Token)
    | DidLogin


update : Taco -> Msg -> Model -> ( Model, Cmd Msg )
update taco msg model =
    case msg of
        SetField field string ->
            ( setField field string model, Cmd.none )

        SubmitForm ->
            --( model, login model.credentials )
            ( model, Route.modify Route.HomeRoute )

        Authenticate creds webdata ->
            let
                updatedModel =
                    case webdata of
                        RemoteData.Failure error ->
                            { model | serverError = Just error }

                        _ ->
                            { model | jwt = webdata }

                command =
                    case webdata of
                        RemoteData.Success token ->
                            Cmd.batch
                                [ Session.store <| Session.session (Just token)
                                , Route.modify HomeRoute
                                , Utils.send DidLogin
                                ]

                        RemoteData.Failure error ->
                            Session.store <| Session.session Nothing

                        _ ->
                            Cmd.none
            in
            ( updatedModel, command )

        DidLogin ->
            Return.singleton model


view : Model -> Html Msg
view model =
    let
        field itype plcholder txt msg =
            input
                [ class "input is_medium"
                , type_ itype
                , placeholder plcholder
                , onInput msg
                , value txt
                ]
                []
    in
    Html.form [ onSubmit SubmitForm ]
        [ Maybe.map (\e -> p [ class "help is-danger" ] [ text <| readableHttpError e ]) model.serverError |> Maybe.withDefault (text "")
        , field "text" "Email" model.credentials.email <| SetField Email
        , field "password" "Password" model.credentials.password <| SetField Password
        , div [ class "field is-grouped" ]
            [ div [ class "control" ] [ button [ class "button is-success is-outlined" ] [ text "Submit" ] ]
            ]
        ]


init : ( Model, Cmd Msg )
init =
    let
        model =
            { jwt = RemoteData.NotAsked
            , credentials = { email = "", password = "" }
            , errors = []
            , serverError = Nothing
            }
    in
    ( model, Cmd.none )



-- Helpers


setField : FormField -> String -> Model -> Model
setField field value model =
    case field of
        Email ->
            let
                credentials =
                    model.credentials

                updatedCredentials =
                    { credentials | email = value }
            in
            { model | credentials = updatedCredentials }

        Password ->
            let
                credentials =
                    model.credentials

                updatedCredentials =
                    { credentials | password = value }
            in
            { model | credentials = updatedCredentials }


login : Credentials -> Cmd Msg
login creds =
    Requests.login creds
        |> RemoteData.sendRequest
        |> Cmd.map (Authenticate creds)


readableHttpError : Http.Error -> String
readableHttpError error =
    let
        decoder =
            Decode.field "message" Decode.string
    in
    case error of
        Http.BadStatus response ->
            Decode.decodeString decoder response.body |> Result.toMaybe |> Maybe.withDefault response.body

        _ ->
            toString error
