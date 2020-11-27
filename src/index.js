const path     = require('path')
const http     = require('http')
const express  = require('express')
const socketio = require('socket.io')
const Filter   = require('bad-words')
const utils    = require('./utils/messages')
const users    = require('./utils/users')

const app = express()
const server = http.createServer(app)
const io = socketio(server)

const port = process.env.PORT || 3000
const public_directory_path = path.join(__dirname, "..", "public")
 
app.use(express.static(public_directory_path))

io.on('connection', (socket) => {
    console.log('New WebSocket connection')
    
    socket.on('join', ({ username, room }, callback) => {
        console.log(username, room)

        if (!username || !room)
            return callback('username and room must not be blank')

        const { error, user } = users.add_user({ id: socket.id, username, room })

        if (error)
            return callback(error)

        socket.join(user.room)

        socket.emit('message', utils.generate_message('Admin', 'Welcome!'))
    
        socket.broadcast.to(user.room)
            .emit('message', utils.generate_message('Admin', `${user.username} has joined`))

        io.to(user.room).emit('room-data', {
            room: user.room,
            users: users.get_users_in_room(user.room)
        })

        callback()
    })

    socket.on('send_message', (msg, callback) => {        
        const filter = new Filter()

        if (filter.isProfane(msg)) {
            callback('Profanity detected')
        } else {
            var user = users.get_user(socket.id)

            io.to(user.room).emit('message', utils.generate_message(user.username, msg))

            callback()
        }
    })
    
    socket.on('send-location', (obj, callback) => {
        var user = users.get_user(socket.id)

        const url = `http://google.com/maps?q=${obj.latitude},${obj.longitude}`
        
        io.to(user.room).emit('location-message', 
            utils.generate_message(user.username, url))

        callback()
    })

    socket.on('disconnect', () => {
        const user = users.remove_user(socket.id)

        if (user) {
            io.to(user.room).emit('message', 
                utils.generate_message('Admin', `${user.username} has disconnected`))

            io.to(user.room).emit('room-data', {
                room: user.room,
                users: users.get_users_in_room(user.room)
            })
        }
            
    })
})

server.listen(port, () => {
    console.log(`Server is running on port ${port}`)
})