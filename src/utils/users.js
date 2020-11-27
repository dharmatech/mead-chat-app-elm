const users = []

const add_user = ({ id, username, room }) => {

    username = username.trim().toLowerCase()
    room     = room    .trim().toLowerCase()

    if (!username || !room) {
        return {
            error: 'username and room are required'
        }
    }
    
    const existing_user = users.find((user) => {
        return user.room === room && user.username === username
    })
    
    if (existing_user === undefined) {
        const user = { id, username, room }
        users.push(user)
        return { user }
    } else {
        return {
            error: 'Username is in use'
        }
    }
}

const remove_user = (id) => {
    const index = users.findIndex(user => user.id === id)

    if (index >= 0)
        return users.splice(index, 1)[0]
}

const get_user = (id) => users.find(user => user.id === id)

const get_users_in_room = (room) => users.filter(user => user.room === room.toLowerCase())

module.exports = {
    add_user,
    remove_user,
    get_user,
    get_users_in_room
}

// --------------------------------------------------------------------------------

// add_user({id: 20, username: 'Linus Torvalds',   room: 'Linux'})
// add_user({id: 30, username: 'RMS',              room: 'GNU'})
// add_user({id: 40, username: 'Alan Kay',         room: 'Smalltalk-80'})
// add_user({id: 50, username: 'Dan Ingalls',      room: 'Smalltalk-80'})

// console.log(users)

// console.log(   add_user({id: 20, username: ' RMS ', room: ' GNU ' })   )
// console.log(   add_user({id: 20, username: '',      room: '' })   )
// console.log(   add_user({id: 20, username: null,    room: '' })   )
// console.log(   add_user({id: 20,                    room: '' })   )

// console.log(   remove_user(20)   )

// console.log(users)

// console.log(get_user(30))

// console.log(get_users_in_room('Smalltalk-80'))