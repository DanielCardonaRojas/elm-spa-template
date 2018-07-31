module View.Components exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events as Events exposing (..)
import Json.Decode as Decode exposing (Decoder)


sideBarMenu : List (Html msg) -> Html msg
sideBarMenu html =
    ul [ class "menu-list" ] html


sideBarMenuTitle : String -> Html msg
sideBarMenuTitle title =
    p [ class "menu-labed" ] [ text title ]


sideBar : List (Attribute msg) -> List (Html msg) -> Html msg
sideBar attrs html =
    aside attrs
        [ nav [ class "menu" ] html
        ]


navItem : msg -> String -> Html msg
navItem msg title =
    a [ class "navbar-item is-tab", onClick msg ] [ text title ]


menuItem : msg -> String -> Html msg
menuItem msg title =
    li []
        [ a [ onClick msg ]
            [ text title
            ]
        ]


container : List (Html msg) -> Html msg
container html =
    div [ class "section" ] [ columns html ]


columns : List (Html msg) -> Html msg
columns html =
    div [ class "columns" ] html


inputText : List (Attribute msg) -> Html msg
inputText attrs =
    div [ class "control" ]
        [ input (class "input" :: attrs) []
        ]


level : List (Attribute msg) -> List (Html msg) -> List (Html msg) -> Html msg
level attrs left right =
    nav (class "level" :: attrs)
        [ div [ class "level-left" ] left
        , div [ class "level-right" ] right
        ]


levelItem : List (Html msg) -> Html msg
levelItem html =
    p [ class "level-item" ] html


levelLinkItem : List (Attribute msg) -> String -> Html msg
levelLinkItem attrs title =
    levelItem <| [ a attrs [ text title ] ]


levelButtonItem : List (Attribute msg) -> String -> Html msg
levelButtonItem attrs title =
    levelLinkItem (class "button" :: attrs) title


fieldGroup : List (Html msg) -> Html msg
fieldGroup lst =
    let
        wrapper content =
            p [ class "control" ] [ content ]
    in
    lst
        |> List.map wrapper
        |> div [ class "field has-addons" ]


buttonGroup : List (Attribute msg) -> List (Html msg) -> Html msg
buttonGroup attrs lst =
    let
        wrapper content =
            span (class "button" :: attrs) [ content ]
    in
    lst
        |> List.map wrapper
        |> div [ class "buttons has-addons" ]


btnGroup : List (Attribute msg) -> (Int -> msg) -> Int -> List (Html msg) -> Html msg
btnGroup attrs toMsg selected html =
    let
        wrapper attrs content =
            span (class "button" :: attrs) [ content ]
    in
    html
        |> List.indexedMap
            (\idx tag ->
                wrapper
                    [ onClick <| toMsg idx
                    , if idx == selected then
                        class "is-selected is-danger"
                      else
                        class ""
                    ]
                    tag
            )
        |> div (class "buttons has-addons" :: attrs)


modal : String -> msg -> Bool -> List (Html msg) -> Html msg -> Html msg
modal title closeMsg toggle buttons content =
    div
        (class "modal"
            |> (\x ->
                    if toggle then
                        [ x, class "is-active" ]
                    else
                        [ x ]
               )
        )
        [ div [ class "modal-background" ] []
        , div [ class "modal-card" ]
            [ header [ class "modal-card-head" ]
                [ p [ class "modal-card-title" ] [ text title ]
                , button [ class "delete", onClick closeMsg ] []
                ]
            , section [ class "modal-card-body" ]
                [ content
                ]
            , footer [ class "modal-card-foot" ] buttons
            ]
        ]



-- Helpers


divWrap : String -> Html msg -> Html msg
divWrap className html =
    div [ class className ] [ html ]
