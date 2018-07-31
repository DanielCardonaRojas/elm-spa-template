module View exposing (..)

import Animation
import Data.Route exposing (Route(..))
import Data.Taco as Taco
import Data.Theme exposing (Theme(..), theme)
import Data.Types exposing (show)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Selection as Selection
import Model exposing (..)
import Msgs exposing (Msg(..))
import Page.Home as Home
import Page.Login as Login
import Page.Signup as Signup
import Toasty
import View.Components as Cmps
import View.Toast as Toast


view : Model -> Html Msg
view model =
    let
        dashboardTemplate =
            template model

        loginTemplate =
            loginSignupTemplate model
    in
    case model.page of
        Home pageModel ->
            dashboardTemplate <| Html.map Msgs.homeTranslator (Home.view model.taco pageModel)

        Login pageModel ->
            loginTemplate 1 <| Html.map Msgs.loginTranslator (Login.view pageModel)

        Signup pageModel ->
            loginTemplate 2 <| Html.map SignupMsg (Signup.view pageModel)



-- Model render functions


template : Model -> Html Msg -> Html Msg
template model html =
    let
        themeClass =
            show theme model.taco.theme

        sideBarItem : Bool -> Route -> Html Msg
        sideBarItem selected route =
            let
                titleIcon =
                    case route of
                        HomeRoute ->
                            ( "Home", "fas fa-home" )

                        _ ->
                            ( "Not Available", "fas fa-error" )

                style =
                    Animation.render model.sideBarReveal
                        ++ (if model.isSideBarOpen then
                                []
                            else
                                [ class "is-hidden" ]
                           )
            in
            a
                [ onClick <| Navigate route
                , if selected then
                    class "is-active"
                  else
                    class "is-notactive"
                ]
                [ span [ class "icon is-medium" ] [ i [ class <| Tuple.second titleIcon ] [] ]
                , span style [ text <| Tuple.first titleIcon ]
                ]

        sideBar : Html Msg
        sideBar =
            Cmps.sideBar [ class <| "template-sidebar" ]
                [ model.navigationMenu
                    |> Selection.mapSelected { selected = sideBarItem True, rest = sideBarItem False }
                    |> Selection.toList
                    |> Cmps.sideBarMenu
                ]

        settingsPane =
            div (class "settings" :: Animation.render model.settingsPaneStyle)
                [ h3 [ class "is-size-5 has-text-centered has-text-weight-bold" ] [ text "Settings" ]
                , nav []
                    [ ul [ class "menu-list" ]
                        [ a
                            [ onClick <| TacoUpdate <| Taco.UpdateTheme LightTheme
                            , if model.taco.theme == LightTheme then
                                class "is-active"
                              else
                                class ""
                            ]
                            [ text "LightTheme" ]
                        , a
                            [ onClick <| TacoUpdate <| Taco.UpdateTheme DarkTheme
                            , if model.taco.theme == DarkTheme then
                                class "is-active"
                              else
                                class ""
                            ]
                            [ text "DarkTheme" ]
                        ]
                    ]
                ]

        toasts : Html Msg
        toasts =
            Toasty.view Toast.config Toast.render ToastyMsg model.toasties

        topBar =
            nav [ class <| "navbar template-header", attribute "role" "navigation", attribute "aria-label" "main navigation" ]
                [ div [ class "navbar-brand is-size-4" ]
                    [ a [ class "navbar-item", onClick ToggleSideBar ] [ text "My Dashboard" ]
                    ]
                , div [ class "navbar-start" ] []
                , div [ class "navbar-end" ]
                    [ span [ class "navbar-item" ]
                        [ a [ onClick ToggleSettings ] [ i [ class "fas fa-cogs" ] [] ]
                        ]
                    , Cmps.navItem Logout "Signout"
                    ]
                ]
    in
    div (Animation.render model.sideBarStyle ++ [ class <| "elm-app " ++ themeClass ])
        [ topBar
        , sideBar
        , main_ [ class "template-content" ] [ html, settingsPane ]
        , div [ class "template-footer" ] []
        , toasts
        ]


loginSignupTemplate : Model -> Int -> Html Msg -> Html Msg
loginSignupTemplate model activeIndex html =
    div [ class <| "elm-app login-signup " ++ show theme model.taco.theme ]
        [ div [ class "form-container" ]
            [ div [ class "tabs is-centered is-large" ]
                [ ul [ class "nno-bottom-border" ]
                    [ li
                        [ class <|
                            if activeIndex == 1 then
                                "is-active"
                            else
                                ""
                        ]
                        [ a [ onClick <| Navigate LoginRoute ] [ text "Login" ] ]
                    , li
                        [ class <|
                            if activeIndex == 2 then
                                "is-active"
                            else
                                ""
                        ]
                        [ a [ onClick <| Navigate SignupRoute ] [ text "Signup" ] ]
                    ]
                ]
            , html
            ]
        ]
