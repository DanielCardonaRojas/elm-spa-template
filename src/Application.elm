module Application exposing (main, update)

import Animation
import Constants as Const
import Data.Authentication exposing (Token)
import Data.Flags exposing (Flags)
import Data.Notification as Notification
import Data.Route as Route exposing (Route(..))
import Data.Session as Session exposing (Session)
import Data.Taco as Taco exposing (Taco)
import Date
import Geolocation
import Http
import Json.Decode as Decode exposing (Decoder)
import List.Selection as Selection
import Model exposing (..)
import Msgs exposing (Msg(..))
import Navigation exposing (Location)
import Page.Home as Home
import Page.Login as Login
import Page.Signup as Signup
import Ports.Echo as Echo
import Ports.LocalStorage as LocalStorage
import Ports.SocketIO as SocketIO
import Requests
import Result.Extra as Result
import Return
import Router
import Task
import Time
import Toasty
import Utilities.Misc as Utils
import View
import View.Animations
import View.Toast as Toast


main : Program Flags Model Msg
main =
    Navigation.programWithFlags SetRoute
        { init = init
        , update = update
        , view = View.view
        , subscriptions = subscriptions
        }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    Model.init
        |> Return.singleton
        |> Return.map (\m -> { m | taco = Taco.update (Taco.UpdateFlags flags) m.taco })
        |> Return.andThen (Router.setRoute location)
        |> Return.command (LocalStorage.retrieveSession ())
        --|> Return.command (SocketIO.connect Const.socketioUrl)
        --|> Return.command (SocketIO.listen "message")
        |> Return.command (Utils.send RefreshToken)
        |> Return.command (Task.perform (TacoUpdate << Taco.SetStartDate << Utils.dateToDateTime) Date.now)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRoute location ->
            Router.setRoute location model

        Navigate route ->
            Return.singleton { model | navigationMenu = Selection.select route model.navigationMenu }
                |> Return.command (Route.modify route)
                |> Return.command
                    (if route == LoginRoute then
                        Session.store <| Session.session Nothing
                     else
                        Cmd.none
                    )

        -- Sesssion and authentication
        SetSession session ->
            Return.singleton { model | taco = Taco.update (Taco.UpdateSession session) model.taco }

        NewToken token ->
            Return.singleton model
                |> Return.command (Session.store <| Session.session <| Just token)

        RefreshToken ->
            Return.singleton model
                |> Return.effect_
                    (\m ->
                        m.taco.session.token
                            |> Maybe.map refreshToken
                            |> Maybe.withDefault Cmd.none
                    )

        Logout ->
            Return.singleton { model | taco = Taco.update (Taco.UpdateSession <| Session.session Nothing) model.taco }
                |> Return.command (Route.modify LoginRoute)

        -- Animations
        ToggleSideBar ->
            let
                sideBarStyle =
                    Animation.interrupt
                        (View.Animations.sideBarStep model.isSideBarOpen)
                        model.sideBarStyle

                sideBarReveal =
                    Animation.interrupt
                        (View.Animations.sideBarReveal model.isSideBarOpen)
                        model.sideBarReveal
            in
            ( { model
                | isSideBarOpen = not model.isSideBarOpen
                , sideBarStyle = sideBarStyle
                , sideBarReveal = sideBarReveal
              }
            , Cmd.none
            )

        ToggleSettings ->
            let
                settingsStyle =
                    Animation.interrupt
                        (View.Animations.settingsPaneStep model.isSettingsOpen)
                        model.settingsPaneStyle
            in
            { model
                | isSettingsOpen = not model.isSettingsOpen
                , settingsPaneStyle = settingsStyle
            }
                |> Return.singleton

        AnimateSideBar msg_ ->
            Return.singleton { model | sideBarStyle = Animation.update msg_ model.sideBarStyle }

        AnimateSideBarReveal msg_ ->
            Return.singleton { model | sideBarReveal = Animation.update msg_ model.sideBarReveal }

        AnimateSettingsPane msg_ ->
            { model | settingsPaneStyle = Animation.update msg_ model.settingsPaneStyle }
                |> Return.singleton

        ToastyMsg msg_ ->
            Toasty.update Toast.config ToastyMsg msg_ model

        AddToast t ->
            Return.singleton model
                |> Toasty.addToast Toast.config ToastyMsg t

        NoOp ->
            ( model, Cmd.none )

        -- Global context
        TacoUpdate msg_ ->
            Return.singleton { model | taco = Taco.update msg_ model.taco }

        _ ->
            updatePage msg model


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        didChangeSession =
            LocalStorage.onSessionChange (SetSession << Session.fromValue)

        refreshToken =
            Time.every (Const.tokenRefreshRate * Time.minute) (\_ -> RefreshToken)

        echo =
            Echo.hear
                (Decode.decodeValue Notification.decode
                    >> Result.unpack (always NoOp) (AddToast << Notification.asToast)
                )

        socketIOEvents =
            let
                socketioDecoder str =
                    case str of
                        "message" ->
                            Notification.decode
                                |> Decode.map
                                    (\n ->
                                        if Notification.isToast n then
                                            AddToast <| Notification.asToast n
                                        else
                                            NoOp
                                    )

                        _ ->
                            Decode.fail ""
            in
            { kind = Notification.Error
            , title = "Decoding failed"
            , content = "Recied message but where unable to parse"
            , silent = False
            }
                |> (AddToast << Notification.asToast)
                |> SocketIO.decodeMessage socketioDecoder

        pageSubs =
            case model.page of
                _ ->
                    Sub.none
    in
    Sub.batch
        [ didChangeSession
        , refreshToken
        , pageSubs
        , socketIOEvents
        , echo
        , Geolocation.changes (TacoUpdate << Taco.UpdateLocation)
        , Animation.subscription AnimateSideBar [ model.sideBarStyle, model.sideBarReveal ]
        , Animation.subscription AnimateSideBarReveal [ model.sideBarReveal ]
        , Animation.subscription AnimateSettingsPane [ model.settingsPaneStyle ]
        ]



-- Helpers


refreshToken : Token -> Cmd Msg
refreshToken token =
    let
        handler =
            Result.unpack (always Logout) NewToken
    in
    Http.send handler (Requests.refreshToken token)


updatePage : Msg -> Model -> ( Model, Cmd Msg )
updatePage msg model =
    case ( msg, model.page ) of
        ( HomeMsg pageMsg, Home pageModel ) ->
            Home.update pageMsg pageModel
                |> Return.mapBoth Msgs.homeTranslator Home
                |> Return.map (\p -> { model | page = p })

        ( LoginMsg pageMsg, Login pageModel ) ->
            Login.update model.taco pageMsg pageModel
                |> Return.mapBoth Msgs.loginTranslator Login
                |> Return.map (\p -> { model | page = p })

        ( SignupMsg pageMsg, Signup pageModel ) ->
            Signup.update pageMsg pageModel
                |> Return.mapBoth SignupMsg Signup
                |> Return.map (\p -> { model | page = p })

        _ ->
            ( model, Cmd.none )



-- Commands
