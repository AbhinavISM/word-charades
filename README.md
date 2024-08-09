# yayscribbl

Word Charades is a multiplayer realtime word guessing game, I developed whole of the frontend of this app using flutter and dart, and backend of the app using nodejs and mongo db. I facilitated real time communication using socket.io for realtime connections.

Users can create game room by providing details like number of users in the game, number of rounds and a room name. this data is sent to the server which joins the user to a socket room.

the user can share this to room name to friends, who can join the room directly using it.

once the room has enough users, the game starts.

Built realtime whiteboard for one user to draw on, the data is caputred as list of coordinates on the screen and sent to the server. the server then broadcasts this data to all other players in the room.

Other users can guess the word and write it in the integrated chatbox, once someone guess the word, chatbox is disabled for him and message is hidden. Once everybody guesses the word or the timer runs out, game moves to next round.

All members of the same room are also connected over voice calls implemented using agoda sdk.

Users can view the leaderboard in real time, change brush size, color, etc.

Tech Stack :
Flutter - Dart, Node.js, MongoDB, Socket.io

Improvements Required:
Improve screen drawing performance by drawing only parts that have changed.
Better synhronisation - running timers and calculating scores on the server instead of the device.

# Screenshots

![Screenshot_20240710_155536](https://github.com/user-attachments/assets/44f16f7d-cbc7-4574-b014-cb3f00a4d7c3)
![Screenshot_20240710_160359](https://github.com/user-attachments/assets/ee04067c-9922-46bc-876e-a7ad5b6c6eb1)
![Screenshot_20240710_160312](https://github.com/user-attachments/assets/fa411d4d-1144-4a7b-85d4-783d915dd0ae)
![Screenshot_20240710_160202](https://github.com/user-attachments/assets/50f4acb0-e946-49fd-891a-e8f655a11548)
![Screenshot_20240710_160132](https://github.com/user-attachments/assets/d25a00ee-983c-48d8-b8eb-6506e186cbfa)
![Screenshot_20240710_160123](https://github.com/user-attachments/assets/14c103be-859c-4d80-b6c2-5032f118bc08)
![Screenshot_20240710_155743](https://github.com/user-attachments/assets/35ff42d1-2ba9-4f25-a960-60ab073ffe16)
![Screenshot_20240710_155735](https://github.com/user-attachments/assets/dfbde326-4259-44a5-a6da-7b85ca9b7102)
![Screenshot_20240710_155646](https://github.com/user-attachments/assets/a37b3569-6606-48ce-a4d2-433a23fd0818)
