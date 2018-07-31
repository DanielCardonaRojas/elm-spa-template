module Data.Route exposing (Route(..), modify)

import Constants exposing (navigationRoute)
import Navigation exposing (Location)


type Route
    = HomeRoute
    | LoginRoute
    | SignupRoute


toUrl : Route -> String
toUrl route =
    let
        urlComponent =
            case route of
                HomeRoute ->
                    ""

                LoginRoute ->
                    navigationRoute.login

                SignupRoute ->
                    navigationRoute.signup
    in
    "#/" ++ urlComponent


modify : Route -> Cmd msg
modify =
    toUrl >> Navigation.modifyUrl
