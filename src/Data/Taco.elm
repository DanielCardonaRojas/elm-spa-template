module Data.Taco exposing (..)

import Data.Flags as Flags exposing (Flags)
import Data.Session as Session exposing (Session)
import Data.Theme as Theme exposing (Theme(..))
import Geolocation
import Time.DateTime as DateTime exposing (DateTime)


type alias Taco =
    { session : Session
    , geolocation : Maybe Geolocation.Location
    , startDate : DateTime -- Date for when application starts running
    , flags : Flags
    , theme : Theme
    }


type Update
    = UpdateSession Session
    | UpdateFlags Flags
    | UpdateTheme Theme
    | UpdateLocation Geolocation.Location
    | SetStartDate DateTime


default : Taco
default =
    { session = Session.session Nothing
    , geolocation = Nothing
    , startDate = DateTime.epoch
    , flags = { theme = "" }
    , theme = LightTheme
    }


update : Update -> Taco -> Taco
update msg taco =
    case msg of
        UpdateSession session ->
            { taco | session = session }

        UpdateLocation loc ->
            { taco | geolocation = Just loc }

        SetStartDate datetime ->
            { taco | startDate = datetime }

        UpdateFlags flags ->
            { taco | flags = flags }

        UpdateTheme theme ->
            { taco | theme = theme }
