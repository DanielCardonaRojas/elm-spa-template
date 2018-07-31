module View.Spinners exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

foldingCube : Html msg
foldingCube =
    let 
        innerFace = List.map (\i -> div [class <| "sk-cube" ++ toString i ++ " sk-cube"] [])
    in
        div [class "sk-folding-cube"] <| innerFace [1, 2, 4, 3]
        
wave : Html msg
wave =
    let 
        inner= List.map (\i -> div [class <| "sk-rect" ++ toString i ++ " sk-rect"] [])
    in
        div [class "sk-wave"] <| inner[1, 2, 3, 4, 5]

pulse : Html msg
pulse =
    div [class "sk-spinner sk-spinner-pulse"][]

threeBounce : Html msg
threeBounce =
    let 
        inner= List.map (\i -> div [class <| "sk-bounce" ++ toString i ++ " sk-child"] [])
    in
        div [class "sk-three-bounce"] <| inner[1, 2, 3]
