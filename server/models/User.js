const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    name : {
        type : String
    }, 
    money : {
        type : Number,
        default : 0,
    },
    email : {
        type : String
    },
    password : {
        type : String
    }
});

const userModel = mongoose.model('User', userSchema);
module.exports = userModel;