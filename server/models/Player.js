const mongoose = require('mongoose');

const playerSchema = new mongoose.Schema({
    nick_name: {
        type: String,
        trim: true,
    },
    socket_id: {
        type: String,
    },
    is_room_leader: {
        type: Boolean,
        default: false
    },
    points: {
        type: Number,
        default: 0
    }
})

const playermodel = mongoose.model('Player', playerSchema);
module.exports = {playermodel, playerSchema};