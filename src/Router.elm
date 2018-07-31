module Router exposing (route, setRoute)

import Constants as Const exposing (apiEndpoint, navigationRoute, string)
import Data.Route as Route exposing (Route(..))
import Data.Session as Session exposing (Session)
import List.Selection as Selection
import Model exposing (Model, Page(..))
import Msgs exposing (..)
import Navigation exposing (Location)
import Page.Home
import Page.Login
import Page.Signup
import RemoteData
import Return
import UrlParser exposing ((</>), Parser, map, oneOf, s, top)


route : Parser (Route -> Route) Route
route =
    oneOf
        [ map HomeRoute top
        , map LoginRoute (s string.login)
        , map SignupRoute (s string.signup)
        ]


setRoute : Location -> Model -> ( Model, Cmd Msg )
setRoute location model =
    let
        parsedRoute =
            UrlParser.parseHash route location
                |> Maybe.withDefault HomeRoute
    in
    updatePage parsedRoute model
        |> Return.map (\m -> { m | navigationMenu = Selection.select parsedRoute m.navigationMenu })
        |> Return.command
            (if parsedRoute == LoginRoute then
                Session.store <| Session.session Nothing
             else
                Cmd.none
            )


updatePage : Route -> Model -> ( Model, Cmd Msg )
updatePage route model =
    case ( route, model.taco.session.token ) of
        --( _, Nothing ) ->
        --Page.Login.init
        --|> Return.mapBoth Msgs.loginTranslator Login
        --|> Return.map (\p -> { model | page = p })
        ( LoginRoute, _ ) ->
            Page.Login.init
                |> Return.mapBoth Msgs.loginTranslator Login
                |> Return.map (\p -> { model | page = p })

        ( SignupRoute, _ ) ->
            Page.Signup.init
                |> Return.mapBoth SignupMsg Signup
                |> Return.map (\p -> { model | page = p })

        ( HomeRoute, _ ) ->
            Page.Home.init
                |> Return.mapBoth Msgs.homeTranslator Home
                |> Return.map (\p -> { model | page = p })
