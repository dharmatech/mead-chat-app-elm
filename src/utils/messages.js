const generate_message = (username, text) => {
    return {
        username,
        text, 
        created_at: new Date().getTime()
    }
}

module.exports = {
    generate_message
}