const socket = io()

socket.on('room-data', (obj) => {    
    app.ports.receive_room_data.send({
        room: obj.room,
        users: obj.users
    })
})

// const $messages = document.querySelector('#messages')

// const autoscroll = () => {
//     const $new_message = $messages.lastElementChild
        
//     if ($messages.scrollHeight - ($new_message.offsetHeight + parseInt(getComputedStyle($new_message).marginBottom))
//         <= 
//         $messages.scrollTop + $messages.offsetHeight) 
//     {
//         $messages.scrollTop = $messages.scrollHeight
//     }
// }
    
socket.on('message', (msg) => {
    app.ports.receive_message.send(
        { 
            username: msg.username,
            message: msg.text,
            created_at: moment(msg.created_at).format('HH:mm a')
        }
    )
})

socket.on('location-message', (obj) => {
    app.ports.receive_location.send({
        username: obj.username, 
        url: obj.text,
        created_at: moment(obj.created_at).format('HH:mm a')
    })
})

app.ports.send_message.subscribe(function (msg) {
    console.log('ports send_message')
    socket.emit('send_message', msg, (error) => {})
})

app.ports.send_location.subscribe(function (msg) {

    navigator.geolocation.getCurrentPosition((position) => {
        socket.emit('send-location', 
            {
                latitude: position.coords.latitude,
                longitude: position.coords.longitude
            }, 
            () => {})    
    })    

})

{
    const query = Qs.parse(location.search, { ignoreQueryPrefix: true })
        
    socket.emit('join', query, error => {
        if (error) {
            alert(error)
            location.href = '/'
        }
    })
}