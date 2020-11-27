port module Main exposing (..)

import Platform.Sub
import Browser
import Html             exposing (..)
import Html.Events
import Html.Attributes  exposing (..)
import Json.Decode
import Json.Encode
import Debug
import Browser.Dom
import Task
----------------------------------------------------------------------
port send_message : String -> Cmd msg
port receive_message : (Json.Decode.Value -> msg) -> Sub msg
----------------------------------------------------------------------
port receive_room_data : (Json.Decode.Value -> msg) -> Sub msg
----------------------------------------------------------------------
port send_location : () -> Cmd msg

port receive_location : (Json.Decode.Value -> msg) -> Sub msg
----------------------------------------------------------------------
type alias User = { id: String, username: String, room: String }

type alias RoomData = { room: String, users: List User }
----------------------------------------------------------------------
type alias LocationMessage = { username : String, url : String, created_at : String }
----------------------------------------------------------------------
type alias TextMessage = { username: String, message : String, created_at : String }

type Message = Text TextMessage | Location LocationMessage

type alias Model = 
    { 
        messages : List Message, 
        draft : String,
        room : String,
        users : List User,
        send_location_button_enabled : Bool
    }

type Msg = 
    ReceivedMessage Json.Decode.Value | 
    SendMessage | 
    ChangeDraft String |
    ReceivedRoomData Json.Decode.Value |
    SendLocation |
    ReceivedLocation Json.Decode.Value |
    NoOp

init : () -> (Model, Cmd Msg)
init _ = 
    (
        { 
            messages = [], 
            draft = "", 
            room = "", 
            users = [],
            send_location_button_enabled = True
        }, 
        Cmd.none
    )


onClickAlt : msg -> Attribute msg
onClickAlt val =
    Html.Events.custom "click"
    (
        Json.Decode.succeed { message = val, stopPropagation = True, preventDefault = True }
    )

view : Model -> Html Msg
view model = 
    div [ class "chat" ] 
    [
        div [ id "sidebar", class "sidebar" ] 
        [
            h2 [ class "room-title" ] [ text model.room ],
            h3 [ class "list-title" ] [ text "Users" ],
            ul [ class "users" ]
            (List.map (\user -> li [] [ text user.username ]) model.users)
        ],

        div [ class "main" ]
        [
            div [ id "messages", class "messages" ]            
                (
                    List.map (\message -> 

                        case message of
                            Text val ->
                                div [ class "message" ] 
                                [
                                    p []
                                    [
                                        span [ class "message__name" ] [ text val.username ],
                                        span [ class "message__meta" ] [ text val.created_at ]
                                    ],
                                    p [] [ text val.message ]
                                ]
                            Location val ->
                                div [ class "message" ] 
                                [
                                    p []
                                    [
                                        span [ class "message__name" ] [ text val.username ],
                                        span [ class "message__meta" ] [ text val.created_at ]
                                    ],
                                    p [] 
                                    [ 
                                        a [ href val.url, target "_blank" ]
                                        [ text "location" ]
                                    ]
                                ]
                        )
                        model.messages
                ),

            div [ class "compose" ]
            [
                Html.form [ id "message-form" ]
                [
                    input 
                        [ 
                            name "message", 
                            placeholder "Message", 
                            required True, 
                            autocomplete False,
                            value model.draft,
                            Html.Events.onInput ChangeDraft
                        ] 
                        [],
                    button [ onClickAlt SendMessage ] [ text "Send" ]
                ],

                button
                    (
                        if model.send_location_button_enabled then
                            [ id "send-location", onClickAlt SendLocation ]
                        else
                            [ id "send-location", onClickAlt SendLocation, disabled True ]
                    )
                    [ text "Send location" ]
            ]
        ]
    ]

decoder : Json.Decode.Decoder TextMessage
decoder =
    Json.Decode.map3 TextMessage
        (Json.Decode.field "username"   Json.Decode.string)
        (Json.Decode.field "message"    Json.Decode.string)
        (Json.Decode.field "created_at" Json.Decode.string)

decoder_user : Json.Decode.Decoder User
decoder_user =
    Json.Decode.map3 User
        (Json.Decode.field "id"       Json.Decode.string)
        (Json.Decode.field "username" Json.Decode.string)
        (Json.Decode.field "room"     Json.Decode.string)

decoder_room_data : Json.Decode.Decoder RoomData
decoder_room_data =
    Json.Decode.map2 RoomData
        (Json.Decode.field "room" Json.Decode.string)
        (Json.Decode.field "users" (Json.Decode.list decoder_user))

decoder_location : Json.Decode.Decoder LocationMessage
decoder_location =
    Json.Decode.map3 LocationMessage
        (Json.Decode.field "username"   Json.Decode.string)
        (Json.Decode.field "url"        Json.Decode.string)
        (Json.Decode.field "created_at" Json.Decode.string)

jumpToBottom : String -> Cmd Msg
jumpToBottom id =
    Browser.Dom.getViewportOf id
        |> Task.andThen (\info -> Browser.Dom.setViewportOf id 0 info.scene.height)
        |> Task.attempt (\_ -> NoOp)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ReceivedMessage val ->
            case Json.Decode.decodeValue decoder val of 
                Ok message -> 
                    (
                        { model | messages = List.append model.messages [ (Text message) ] }, 
                        jumpToBottom "#messages"
                    )
                Err _ -> (model, Cmd.none)
        
        ChangeDraft val -> ({ model | draft = val }, Cmd.none)
        
        SendMessage ->
            (
                { model | draft = "" },
                if model.draft == "" then 
                    Cmd.none
                else send_message model.draft
            )
            
        ReceivedRoomData val ->
            case Json.Decode.decodeValue decoder_room_data val of
                Ok room_data ->
                    (
                        { model | room = room_data.room, users = room_data.users }, 
                        Cmd.none
                    )

                Err _ -> (model, Cmd.none)

        SendLocation -> ({ model | send_location_button_enabled = False }, send_location ())
              
        ReceivedLocation val ->
            case Json.Decode.decodeValue decoder_location val of
                Ok location_message ->
                    (
                        { 
                            model | 
                                messages = 
                                    model.messages ++ [ (Location location_message) ],
                                send_location_button_enabled = True
                        },
                        jumpToBottom "#messages"
                    )
                Err _ -> ({ model | send_location_button_enabled = True }, Cmd.none)

        NoOp -> (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model = 
    Platform.Sub.batch
    [
        receive_message ReceivedMessage,
        receive_room_data ReceivedRoomData,
        receive_location ReceivedLocation
    ]

main = Browser.element
    {
        init = init,
        view = view,
        update = update,
        subscriptions = subscriptions
    }