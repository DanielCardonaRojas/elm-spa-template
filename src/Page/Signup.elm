module Page.Signup exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import View.Components as Cmps
import Verify exposing (Validator, verify)
import String.Verify exposing (..)
import Regex
import Return

type alias Model = Registration

type alias Registration =
    { email : String
    , password : String
    , passwordConfirmation : String
    , errors : List (FormField, String)
    , visitedFields : List FormField -- Sets don't work with Union types fix this later
    }

type alias RegistrationData =
    { email : String
    , password : String
    }

type FormField 
    = Email
    | Password
    | PasswordConfirm

type Msg
    = SubmitForm
    | SetField FormField String
    | BlurField FormField
    | FocusField FormField

uniqueAppend : a -> List a -> List a
uniqueAppend a lst =
    if List.member a lst then
        lst
    else 
        a :: lst

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    let 
        validate mdl = 
            case validator mdl of
                Ok value -> []
                Err errors -> errors
    in
    case msg of
        SetField field string ->
            model
            |> Return.singleton
            |> Return.map (setField field string)
            |> Return.map (\m -> { m | errors = validate m })

        BlurField field ->
            Return.singleton model

        FocusField field ->
            Return.singleton { model | visitedFields = uniqueAppend field model.visitedFields }

        SubmitForm ->
            (model, Cmd.none)

view : Model -> Html Msg
view model =
    let 

        field itype plcholder txt field = 
            div [ class "field"]
            [
                Cmps.inputText 
                    [ class "is_medium"
                    , type_ itype
                    , placeholder plcholder
                    , onInput <|  SetField field 
                    , onBlur <| BlurField field
                    , onFocus <| FocusField field
                    , value txt
                    ],
                filteredErrorsBy field
            ]

        errors es =
            List.map (\ e -> li [class "has-text-danger"][text <| Tuple.second e]) es
            |> ul [class "no-bottom-border"]

        filteredErrorsBy field =
            model.errors 
            |> List.filter (Tuple.first >> flip List.member model.visitedFields)
            |> List.filter (Tuple.first >> \f -> f == field )
            |> errors 
    in
        Html.form [onSubmit SubmitForm]
        [ field "text" "Email" model.email Email
        , field "password" "Password" model.password Password
        , field "password" "Password confirmation" model.passwordConfirmation PasswordConfirm
        , div [ class "field is-grouped"]
              [ div [class "control"] [button [class "button is-success is-outlined"] [text "Submit"]]
              ]
        ]

init : (Model, Cmd Msg)
init = 
    { password = ""
    , passwordConfirmation = ""
    , email = ""
    , errors = []
    , visitedFields = []
    } |> Return.singleton

-- Helpers
setField :  FormField -> String -> Model -> Model 
setField field value model =
    case field of
        Email ->
            { model | email = value}
        Password ->
            { model | password = value}
        PasswordConfirm ->
            { model | passwordConfirmation = value}

--Validators
validatePassword : Validator (FormField, String) Model String
validatePassword = 
    let 
        minError = (Password, "Password is required to be at least 8 characters long.")
        maxError = (Password, "Password can be at most 20 characters long.")
        matchError = (PasswordConfirm, "Passwords don't match")
        blankError = (Password, "Password can't be blank")

        passwordValidator : Validator (FormField, String) String String
        passwordValidator = 
            notBlank blankError
            |> Verify.compose (minLength 8 minError) 
            |> Verify.compose (maxLength 20 maxError) 

        equalPasswords : Validator (FormField, String) (String, String) String
        equalPasswords =
            matchError
            |> Verify.fromMaybe (\(p, c) -> if p == c then Just p else Nothing)

    in 
        Verify.validate always
        |> verify .password passwordValidator
        |> verify (\u -> (u.password, u.passwordConfirmation)) equalPasswords


validateEmail : String -> Bool
validateEmail email =
    let
        emailPattern =
            Regex.regex "\\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}\\b"

    in
        Regex.contains emailPattern email


validator : Validator (FormField, String) Model RegistrationData
validator =
    let 
        withPredicate pred = 
            Verify.fromMaybe (\a -> if pred a then Just a else Nothing)

        emailValidations = 
            notBlank (Email, "Email can't be left blank")
            |> Verify.compose (withPredicate validateEmail (Email, "Is not a well formed email"))
    in
        Verify.validate RegistrationData
        |> verify identity validatePassword
        |> verify .email emailValidations
