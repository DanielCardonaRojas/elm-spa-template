module Model exposing (..)

import Animation exposing (em, percent, px, rem)
import Data.Notification exposing (Notification, Toast)
import Data.Route as Route exposing (Route)
import Data.Taco as Taco exposing (Taco)
import List.Selection as Selection exposing (Selection)
import Page.Home as Home
import Page.Login as Login
import Page.Signup as Signup
import Toasty


type alias Model =
    { page : Page
    , taco : Taco
    , toasties : Toasty.Stack Toast
    , notifications : List Notification
    , navigationMenu : Selection Route
    , isSideBarOpen : Bool
    , isSettingsOpen : Bool
    , sideBarStyle : Animation.State
    , sideBarReveal : Animation.State
    , settingsPaneStyle : Animation.State
    }


type Page
    = Home Home.Model
    | Login Login.Model
    | Signup Signup.Model


init : Model
init =
    { page = Home <| Tuple.first Home.init
    , taco = Taco.default
    , toasties = Toasty.initialState
    , notifications = []
    , navigationMenu =
        Selection.fromList [ Route.HomeRoute ]
            |> Selection.select Route.HomeRoute
    , isSideBarOpen = True
    , isSettingsOpen = True
    , sideBarStyle =
        Animation.style
            [ Animation.exactly "grid-template-columns" "12rem repeat(11, 1fr)"
            ]
    , sideBarReveal =
        Animation.style
            [ Animation.opacity 1.0
            ]
    , settingsPaneStyle =
        Animation.style
            [ Animation.left (percent 100.0)
            ]
    }
