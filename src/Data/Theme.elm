module Data.Theme exposing(..)

import Data.Types exposing (..)

type Theme
    = LightTheme
    | DarkTheme

all : List Theme
all =
    [ LightTheme
    , DarkTheme
    ]

theme : Stringable Theme
theme =
    { stringable = \x -> 
        case x of
            LightTheme ->
                "theme-light"
            DarkTheme ->
                "theme-dark"
    }
