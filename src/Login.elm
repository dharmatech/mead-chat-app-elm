module Login exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)

init : () -> (Model, Cmd Msg)
init _ = (0, Cmd.none)

type Msg = Abc

type alias Model = Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = (model, Cmd.none)

view : Model -> Html Msg
view model =
    div [ class "centered-form" ] 
    [
        h1 [] [ text "Join" ],

        Html.form [ action "chat.html" ]
        [
            label [] [ text "Display name"],
            input [ type_ "text", name "username", placeholder "Display name", required True ] [],

            label [] [ text "Room" ],
            input [ type_ "text", name "room", placeholder "Room", required True ] [],

            button [] [ text "Join" ]
        ]
    ]

main = Browser.element 
    { init = init, subscriptions = (\_ -> Sub.none), update = update, view = view }