module Utilities.Parsers exposing (..)

import Parser exposing (Parser, (|.), (|=), succeed, symbol, float, ignore, zeroOrMore, oneOrMore)
import Time.DateTime as DateTime exposing (DateTime)

dateTimeParser : Parser DateTime
dateTimeParser =
    let
        -- Parses this format: yyyy-mm-dd HH:mm
        spaces = ignore oneOrMore (\c -> c == ' ')

        paddedInt = 
            Parser.oneOf 
                [ Parser.ignore (Parser.Exactly 1) (\c -> c == '0') |> Parser.andThen (always Parser.int)
                , Parser.int
                ]

        createDateTime year month day hour minute = 
            DateTime.zero 
            |> DateTime.dateTime
            |> DateTime.setYear year
            |> DateTime.setMonth month
            |> DateTime.setDay day
            |> DateTime.setHour hour
            |> DateTime.setMinute minute
    in
        Parser.succeed createDateTime
            |= Parser.int
            |. symbol "-"
            |= paddedInt
            |. symbol "-"
            |= paddedInt
            |. spaces
            |= paddedInt
            |. symbol ":"
            |= paddedInt
