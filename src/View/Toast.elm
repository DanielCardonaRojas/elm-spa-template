module View.Toast exposing (config, render)

import Data.Notification as Notification exposing (Notification, Toast)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Toasty


-- TODO: Maybe add actions handling for click closing


render : Toast -> Html msg
render toast =
    let
        notificationType =
            case toast.kind of
                Notification.Success ->
                    "is-info"

                _ ->
                    "is-warning"
    in
    article [ class <| "message " ++ notificationType ]
        [ div [ class "message-header" ]
            [ text toast.title
            , button [ class "delete" ] []
            ]
        , div [ class "message-body" ]
            [ text toast.content
            ]
        ]


config : Toasty.Config msg
config =
    Toasty.config
        |> Toasty.transitionOutDuration 700
        |> Toasty.transitionOutAttrs transitionOutAttrs
        |> Toasty.transitionInAttrs transitionInAttrs
        |> Toasty.containerAttrs containerAttrs
        |> Toasty.delay 9000


containerAttrs : List (Attribute msg)
containerAttrs =
    [ class "toast-stack"
    , style
        [ ( "max-width", "300px" )
        , ( "width", "30rem" )
        , ( "position", "fixed" )
        , ( "right", "1rem" )
        , ( "bottom", "2rem" )
        , ( "z-index", "30" )
        , ( "list-style-type", "none" )
        ]
    ]


transitionInAttrs : List (Html.Attribute msg)
transitionInAttrs =
    [ class "animated bounceInRight"
    ]


transitionOutAttrs : List (Html.Attribute msg)
transitionOutAttrs =
    [ class "animated fadeOutRightBig"
    ]
