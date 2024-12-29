let syncIntervalsMap = new Map();
let roomsMap = new Map();
class RoomClass {
    constructor(word, room_name, room_size, max_rounds, current_round, players, can_join, turn, turn_index){

    }
}
class PlayerClass {
    constructor(nick_name, socket_id, is_room_leader, points){

    }
}

function startTimer(room_name){
  const startTime = new Date();  // Current time when the game starts

  // Send start time and duration to all clients
  io.to(room_name).emit('startTimer', {
    startTime: startTime.toISOString(),  // ISO format timestamp
  });

  let timeElapsed = 0;
  // Optionally, send periodic sync messages every 10 seconds
  syncIntervals[room_name] = setInterval(() => {
      timeElapsed += 10;
      if(timeElapsed<60){
          io.to(room_name).emit('syncTimer', {
              startTime: startTime.toISOString(),
            });   
      } else {
          endTimer(room_name);
      }
  }, 10000);  // Sync every 10 seconds

}

function endTimer(room_name) {
  if(syncIntervals[room_name]) {
      clearInterval(syncIntervals[room_name]);
      delete syncIntervals[room_name];
  }
  changeTurn(room_name);
}