const express = require("express");
const app = express();
const PORT = 4000;

function convertStringToDate(dateTimeString) {
    var [datePart, timePart] = dateTimeString.split(' '); // Split the date and time parts
    var [hhmmss, ms] = timePart.split('.');
    // var [year, month, day] = datePart.split('-').map(Number); // Split the date part into year, month, and day
    // var [hours, minutes, seconds] = timePart.split(':').map(Number); // Split the time part into hours, minutes, and seconds
  
    // Create a new Date object using the extracted values
    var dateObject = new Date(datePart+"T"+hhmmss+"+05:30");
  
    return dateObject;
}

const server = app.listen(PORT, '0.0.0.0', () => {
    console.log('server started and running at port ' + PORT);
});

const mongoose = require("mongoose");
const io = require("socket.io")(server)

const db = 'mongodb+srv://Abhinavkism:TMecPvft6v9rf9B8@cluster0.akleghw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0';
const getWord = require('./api/getWord');
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const User = require("./models/User");

app.use(express.json());

mongoose.connect(db).then(() => {
    console.log('connection succesful to mongo db');
}).catch((e) => {
    console.log(e);
});

//socket.emit() -> send to sender only
//io.emit() -> send to everyone
//socket.broadcast.emit() -> send to everyone except sender
//socket.broadcast.to(room_name).emit() -> send to everyone except sender in room
//io.to(room_name).emit() -> send to everyone in room
//socket.to('room_name').emit() -> sending to sender client, only if its in room
//socket.broadcast.to(socketid).emit() -> sending to individual socketid
//for (var socketid in io.sockets.sockets) {} -> list socketid

let roomsMap = new Map();
let socketToRoomNameMap = new Map();
class RoomClass {
    constructor(word, room_name, room_size, max_rounds, current_round, players, can_join, turn, turn_index){
        this.word = word;
        this.room_name = room_name;
        this.room_size = room_size;
        this.max_rounds = max_rounds;
        this.current_round = current_round;
        this.players = players;
        this.can_join = can_join;
        this.turn = turn;
        this.turn_index = turn_index;
    }
}
class PlayerClass {
    constructor(nick_name, socket_id, is_room_leader, points){
        this.nick_name = nick_name;
        this.socket_id = socket_id;
        this.is_room_leader = is_room_leader;
        this.points = points;
    }
}

app.post("/signup", async (req, res) => {
    const {username, email, password} = req.body;
    try{
        const existing_user = await User.findOne({email : email});
        if(existing_user){
            return res.status(400).json({message : "User already exists"});
        }
        const hashedPassword = await bcrypt.hash(password, 10);
        const result = User.create({
            name : username,
            email : email,
            password : hashedPassword,
        });
        const token = jwt.sign({email : result.email, id : result._id}, "wordcharades");
        res.status(201).json({user : result, token : token});
    } catch (e) {
        console.log(e);
        res.status(500).json({message : "Something went wrong"});
    }
});

app.get("/signin",  async (req, res) => {
    const {email, password} = req.body;
    try {
        const existingUser = await User.findOne({email : email});
        if(!existingUser){
            res.status(400).json({message : "User does not exist"});
        }
        const matchPassword = await bcrypt.compare(password, existingUser.password);
        if(!matchPassword){
            return res.status(400).json({message : "invalid credentials"});
        }
        const token = jwt.sign({email : existingUser.email, id : existingUser._id}, "wordcharades");
        res.status(201).json({user : existingUser, token : token});
    } catch (e) {
        console.log(e);
        res.status(500).json({message : "Something went wrong"});
    }
});

io.on('connection', (socket) => {
    console.log("a user connected", socket.id);
    socket.on('create_game', async ({ nick_name, room_name, room_size, max_rounds, bullshit }) => {
        try {
            if(roomsMap.has(room_name)){
                socket.emit('notCorrectGame', 'room with that name already exists');
                return;
            }
            let word = getWord();
            let player = new PlayerClass(nick_name,socket.id,true,0);
            socketToRoomNameMap[socket.id] = room_name;
            let players = [];
            players.push(player);
            let room = new RoomClass(word, room_name, parseInt(room_size), parseInt(max_rounds), 1, players, true, player, 0);
            roomsMap.set(room_name, room);
            socket.join(room_name);
            io.to(room_name).emit('update_room', {roomData : room , thisPlayer : player});
        } catch (err) {
            console.log(err);
        }
    });

    socket.on('join_game', async({nick_name,room_name,bullshit}) => {
        try{
            if(!roomsMap.has(room_name)){
                socket.emit('notCorrectGame', 'please enter a valid room name');
                return;
            }
            let room = roomsMap.get(room_name);
            for(let i = 0; i<room.players.length; i++){
                if(room.players[i].nick_name == nick_name){
                    socket.emit('notCorrectGame', 'name is already taken');
                    return;
                }
            }
            if(room.can_join){
                let player = new PlayerClass(nick_name, socket.id, false, 0);
                socketToRoomNameMap[socket.id] = room_name;
                room.players.push(player);
                socket.join(room_name);
                if(room.players.length == room.room_size){
                    room.can_join = false;
                }
                roomsMap.set(room_name, room);
                io.to(room_name).emit('update_room', {roomData : room , thisPlayer : player});
            }else{
                socket.emit('notCorrectGame', 'this game is in progress, please try later');
            }
        }
        catch(err){
            console.log(err);
        }
    });

    socket.on('paint', ({details, room_name}) => {
        socket.broadcast.to(room_name).emit('points_to_draw', details);
    });

    socket.on('color_change', ({color, room_name}) => {
        io.to(room_name).emit('color_change', color);
    });

    socket.on('stroke_width', ({value, room_name}) => {
        io.to(room_name).emit('stroke_width', value);
    });

    socket.on('erase_all', (room_name) => {
        io.to(room_name).emit('erase_all', '');
    });

    socket.on('msg', async({sender_name, message, word, room_name, guessedUserCounter, total_time, time_taken}) => {
        try{
            if(message == word){
                let room = roomsMap.get(room_name);
                if(time_taken!=0){
                    console.log('point update on server');
                    room.players.filter(
                        (player) => player.nick_name == sender_name
                    )[0].points += total_time-time_taken;
                }
                roomsMap.set(room_name, room);
                io.to(room_name).emit('msg', {
                    sender_name : sender_name,
                    message : 'Guessed it!',
                    guessedUserCounter: guessedUserCounter + 1
                });
                socket.emit('close_input', '');
            }else{
                io.to(room_name).emit('msg', {
                    sender_name : sender_name,
                    message : message,
                    guessedUserCounter: guessedUserCounter
                });
            }
        }catch(err){
            console.log(err);
        }
    });

    socket.on('change_turn',async(room_name)=> {
        console.log('server change turn called');
        try{
            let room = roomsMap.get(room_name);
            if(room.turn_index+1 == room.players.length){
                room.current_round+=1;
                console.log(room.current_round.toString);
            }
            if(room.current_round<=room.max_rounds){
                let word = getWord();
                room.word = word;
                room.turn_index = (room.turn_index+1) % room.players.length;
                room.turn = room.players[room.turn_index];
                roomsMap.set(room_name, room);
                console.log(room);
                io.to(room_name).emit('change_turn', room);
            }
            else{
                roomsMap.get(room_name).players.forEach((player)=>{socketToRoomNameMap.delete(player.socket_id)});
                roomsMap.delete(room_name);
                io.to(room_name).emit('show_leader_board', room);
            }
        }
        catch(err){
            console.log(err);
        }
    });

    socket.on('update_score', async(room_name)=>{
        try{
            const room = roomsMap.get(room_name);
            io.to(room_name).emit('update_score', room);
        }catch(err){
            console.log(err);
        }
    });

    socket.on('disconnect', async()=>{
        console.log('someone disconnected');
        try{
            if(!(socketToRoomNameMap.has(socket.id) && roomsMap.has(socketToRoomNameMap[socket.id]))){
                let room_name = socketToRoomNameMap[socket.id];
                let room = roomsMap.get(room_name);
                let whoDisconnected;
                for(let i = 0; i<room.players.length; i++){
                    if(room.players[i].socket_id === socket.id){
                        whoDisconnected = room.players[i];
                        room.players.splice(i,1);
                    }
                }
                roomsMap.set(room_name, room);
                if(room.players.length === 1){
                    roomsMap.get(room_name).players.forEach((player)=>{socketToRoomNameMap.delete(player.socket_id)});
                    roomsMap.delete(room_name);
                    socket.broadcast.to(room.room_name).emit('show_leader_board', room);
                }else{
                    socket.broadcast.to(room.room_name).emit('user_disconnected', {roomData : room, playerWhoDisconnected : whoDisconnected});
                }
            }
        } catch(err){
            console.log(err);
        }
    })
});