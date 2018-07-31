module Data.Types exposing (..)

type alias URL = String
type alias UUID = String
type alias UUIDTagged r = { r | uuid : UUID }

type alias Translator childMsg msg = childMsg -> msg

-- Preparing for elm 0.19
type alias Stringable a =
    { stringable : a -> String }

-- TODO: Rename to toString
show : Stringable a -> a -> String
show { stringable } x =
    stringable x
