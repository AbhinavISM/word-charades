const mongoose = require('mongoose');
const {playerSchema} = require('./Player');

const roomSchema = new mongoose.Schema({
    word: {
        required: true,
        type: String
    },
    room_name: {
        required: true,
        type: String,
        unique: true,   
        trim: true,
    },
    room_size: {
        required: true,
        type: Number,
        default: 4
    },
    max_rounds: {
        required: true,
        type: Number
    },
    current_round: {
        required: true,
        type: Number,
        default: 1,
    },
    players: [playerSchema],
    can_join: {
        type: Boolean,
        default: true,
    },
    turn: playerSchema,
    turn_index: {
        type: Number,
        default: 0
    }
})

const gameModel = mongoose.model('Room', roomSchema);
module.exports = gameModel;