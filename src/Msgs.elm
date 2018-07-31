module Msgs exposing (..)

import Animation
import Data.Authentication as Authentication
import Data.Notification exposing (Toast)
import Data.Route exposing (Route)
import Data.Session exposing (Session)
import Data.Taco as Taco exposing (Taco)
import Navigation exposing (Location)
import Page.Home as Home
import Page.Login as Login
import Page.Signup as Signup
import Toasty


type Msg
    = SetRoute Location
    | Navigate Route
    | HomeMsg Home.Msg
    | SignupMsg Signup.Msg
    | LoginMsg Login.Msg
    | Logout
    | SetSession Session
    | RefreshToken -- Request token to be refreshed
    | NewToken Authentication.Token -- Did receive a new token
    | AnimateSideBar Animation.Msg
    | AnimateSideBarReveal Animation.Msg
    | AnimateSettingsPane Animation.Msg
    | ToggleSideBar
    | ToggleSettings
    | TacoUpdate Taco.Update
    | ToastyMsg (Toasty.Msg Toast)
    | AddToast Toast
    | NoOp



-- Translators


homeTranslator : Home.Msg -> Msg
homeTranslator msg =
    case msg of
        msg_ ->
            HomeMsg msg_


loginTranslator : Login.Msg -> Msg
loginTranslator msg =
    case msg of
        msg_ ->
            LoginMsg msg_
