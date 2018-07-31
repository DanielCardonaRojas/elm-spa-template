module View.Animations exposing (..)

import Animation 
import Ease
import Time
import Utilities.Misc as Utils

spaced : Int -> Float -> Float -> (Float -> Float) -> List Float
spaced points from to easing =
    let
        min = if from < to then from else to
        max = if from < to then to else from
    in
    List.range 0 points
    |> Utils.bypass (from < to) List.reverse
    |> List.map (easing << (\i -> i / toFloat points) << toFloat)
    |> List.map (\x -> (max - min) * x + min)

customAnimationSteps : Int -> Float -> Float -> (Float -> Float) -> (Float -> Animation.Property) -> List Animation.Step
customAnimationSteps points from to easing toProperty = 
    spaced points from to easing
    |> List.map ( Animation.set << List.singleton << toProperty )
    |> List.intersperse (Animation.wait (Time.millisecond * 10))

sideBarStep : Bool -> List Animation.Step
sideBarStep isOpen =
    let
        cssGridColumnTemplate : Float -> Animation.Property
        cssGridColumnTemplate v =
            Animation.exactly "grid-template-columns" 
             <| toString v ++ "rem repeat(11, 1fr)"
    in
        if isOpen then
            customAnimationSteps 10 12 4 Ease.outBack cssGridColumnTemplate
        else 
            customAnimationSteps 10 4 12 Ease.inExpo cssGridColumnTemplate

settingsPaneStep : Bool -> List Animation.Step
settingsPaneStep isOpen =
    let 
        percent = if isOpen then 80.0 else 100.0
    in
        [   
          Animation.left (Animation.percent percent )
          |> List.singleton
          |> Animation.to
        ]

sideBarReveal : Bool -> List Animation.Step
sideBarReveal isOpen =
    if isOpen then
        [ Animation.set [Animation.display Animation.none]
        , Animation.to [ Animation.opacity 0.0 ]
        ]
    else 
        [ Animation.wait (Time.millisecond  * 400)
        , Animation.set [Animation.display Animation.inline]
        , Animation.to [ Animation.opacity 1.0 ]
        ]


hideRevealDetail : Bool -> List Animation.Step
hideRevealDetail isOpen =
    let 
        percent = if isOpen then 0.0 else -100.0
    in
        [   
          Animation.right (Animation.percent percent )
          |> List.singleton
          |> Animation.to
        ]
