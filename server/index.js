const express = require("express");
const app = express();
const PORT = process.env.PORT || 4000;

// bad line causes error in websocket connection
// var server = http.createServer(app);
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
    console.log('server started and running at port' + PORT);
    console.log('date : ', new Date("08 June 2023 10:01:00 UTC+05:30"));
    console.log('date : ', new Date("2023-06-08T10:01:00 UTC+05:30"));
    console.log('date : ', convertStringToDate("2023-06-08 11:59:07.240114"));

});

const mongoose = require("mongoose");
const io = require("socket.io")(server)

const db = 'mongodb+srv://Abhinavkism:TMecPvft6v9rf9B8@cluster0.akleghw.mongodb.net/?retryWrites=true&w=majority';
const Room = require('./models/Room');
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
            const existing_room = await Room.findOne({ room_name });
            if (existing_room) {
                socket.emit('notCorrectGame', 'room with that name already exists');
                return;
            }
            let room = new Room();
            const word = getWord();

            room.word = word;
            room.room_name = room_name;
            room.room_size = room_size;
            room.max_rounds = max_rounds;

            let player = {
                socketID: socket.id,
                nick_name,
                isPartyLeader: true,
            }
            room.players.push(player);
            room = await room.save();
            socket.join(room_name);
            let playerToSend;
                for(let i = 0; i<room.players.length; i++){
                    if(room.players[i].nick_name == nick_name){
                    playerToSend = room.players[i];
                    }
                }
            io.to(room_name).emit('update_room', {dataOfRoom : room , thisPlayer : playerToSend});
        } catch (err) {
            console.log(err);
        }
    });

    socket.on('join_game', async({nick_name,room_name,bullshit}) => {
        try{
            let room = await Room.findOne({room_name});
            if(!room){
                socket.emit('notCorrectGame', 'please enter a valid room name');
                return;
            }
            for(let i = 0; i<room.players.length; i++){
                if(room.players[i].nick_name == nick_name){
                socket.emit('notCorrectGame', 'name is already taken');
                return;
                }
            }
            if(room.isJoin){
                let player = {
                    socketID: socket.id,
                    nick_name,
                }
                room.players.push(player);
                socket.join(room_name);

                if(room.players.length == room.room_size){
                    room.isJoin = false;
                }

                room.turn = room.players[room.turnIndex];
                room = await room.save();
                let playerToSend;
                for(let i = 0; i<room.players.length; i++){
                    if(room.players[i].nick_name == nick_name){
                    playerToSend = room.players[i];
                    }
                }
                io.to(room_name).emit('update_room', {dataOfRoom : room , thisPlayer : playerToSend});
            }else{
                socket.emit('notCorrectGame', 'this game is in progress, please try later');
            }
        }
        catch(err){
            console.log(err);
        }
    });

    socket.on('paint', ({details, room_name}) => {
        io.to(room_name).emit('points_to_draw', {details: details});
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
                let room = await Room.findOne({room_name});
                if(time_taken!=0){
                    console.log('point update on server');
                    room.players.filter(
                        (player) => player.nick_name == sender_name
                    )[0].points += total_time-time_taken;
                }
                room = await room.save();
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
            let room = await Room.findOne({room_name});
            // let turnIndex = room.turnIndex;
            if(room.turnIndex+1 == room.players.length){
                room.currentRound+=1;
                console.log(room.currentRound.toString);
            }
            if(room.currentRound<=room.max_rounds){
                const word = await getWord();
                room.word = word;
                room.turnIndex = (room.turnIndex+1) % room.players.length;
                room.turn = room.players[room.turnIndex];
                room = await room.save();
                console.log(room);
                io.to(room_name).emit('change_turn', room);
            }
            else{
                io.to(room_name).emit('show_leader_board', room);
            }
        }
        catch(err){
            console.log(err);
        }
    });

    socket.on('update_score', async(room_name)=>{
        try{
            const room = await Room.findOne({room_name});
            io.to(room_name).emit('update_score', room);
        }catch(err){
            console.log(err);
        }
    });

    socket.on('disconnect', async()=>{
        console.log('someone disconnected');
        try{
            let room = await Room.findOne({'players.socketID': socket.id});
            let whoDisconnected;
            for(let i = 0; i<room.players.length; i++){
                if(room.players[i].socketID === socket.id){
                    whoDisconnected = room.players[i];
                    room.players.splice(i,1);
                }
            }
            room = await room.save();
            if(room.players.length === 1){
                socket.broadcast.to(room.room_name).emit('show_leader_board', {dataOfRoom : room, playerWhoDisconnected : whoDisconnected});
            }else{
                socket.broadcast.to(room.room_name).emit('user_disconnected', room);
            }
        } catch(err){
            console.log(err);
        }
    })
});