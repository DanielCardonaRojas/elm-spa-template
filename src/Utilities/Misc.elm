module Utilities.Misc exposing (..)

import Date exposing (Month(..))
import Fuzzy
import Json.Decode as Decode exposing (Decoder)
import Ordering exposing (Ordering)
import Task
import Time.DateTime as DateTime exposing (DateTime)


-- Ordering


toComparableString : String -> String
toComparableString =
    String.toLower >> String.trimLeft >> String.trimRight


fuzzyFilter : (a -> String) -> String -> List a -> List a
fuzzyFilter selector str lst =
    let
        matcher =
            Fuzzy.match [] [ " " ] (toComparableString str) >> .score

        threshold score =
            score < 1099
    in
    List.filter (selector >> toComparableString >> matcher >> threshold) lst


fuzzyOrdering : (a -> String) -> String -> Ordering a
fuzzyOrdering selector query =
    let
        matcher : String -> Int
        matcher =
            Fuzzy.match [] [] (toComparableString query) >> .score
    in
    Ordering.byField (selector >> toComparableString >> matcher)



-- Decoders


traceDecoder : String -> Decoder msg -> Decoder msg
traceDecoder message decoder =
    Decode.value
        |> Decode.andThen
            (\value ->
                case Decode.decodeValue decoder value of
                    Ok decoded ->
                        Decode.succeed decoded

                    Err err ->
                        let
                            _ =
                                Debug.log message err
                        in
                        Decode.fail err
            )



-- Functions


bypass : Bool -> (a -> a) -> a -> a
bypass b f =
    if b then
        identity
    else
        f



-- Commands


send : msg -> Cmd msg
send msg =
    Task.succeed msg
        |> Task.perform identity



-- time


dateToDateTime : Date.Date -> DateTime
dateToDateTime d =
    DateTime.dateTime DateTime.zero
        |> DateTime.setYear (Date.year d)
        |> DateTime.setMonth (Date.month d |> monthToInt)
        |> DateTime.setDay (Date.day d)
        |> DateTime.setHour (Date.hour d)
        |> DateTime.setMinute (Date.minute d)
        |> DateTime.setSecond (Date.second d)


monthToInt : Date.Month -> Int
monthToInt month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


secondsToTime :
    Int
    -> ( Int, Int, Int, Int ) -- (days, hours, minutes, seconds)
secondsToTime secs =
    let
        seconds =
            secs % 60

        minutes =
            (secs // 60) % 60

        hours =
            (secs // 3600) % 24

        days =
            secs // 86400
    in
    ( days, hours, minutes, seconds )


format : DateTime -> String
format datetime =
    let
        ( y, m, d, h, min, s, _ ) =
            DateTime.toTuple datetime

        ( year, month, day, hour, minute ) =
            ( toString y
            , pad m
            , pad d
            , pad h
            , pad min
            )

        pad =
            String.padLeft 2 '0' << toString
    in
    year ++ "-" ++ month ++ "-" ++ day ++ " " ++ hour ++ ":" ++ minute
