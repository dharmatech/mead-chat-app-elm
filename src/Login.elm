module Login exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)

main : Html a
main =
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
