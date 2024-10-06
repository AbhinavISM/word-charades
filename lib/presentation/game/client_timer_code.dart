import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For parsing ISO8601 dates
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Game Timer',
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  IO.Socket? socket;
  Timer? countdownTimer;
  int timeRemaining = 60; // Default game duration

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io('http://localhost:3000',
        IO.OptionBuilder().setTransports(['websocket']).build());

    socket?.onConnect((_) {
      print('Connected to server');
    });

    // Listen for the startTimer event from the server
    socket?.on('startTimer', (data) {
      String startTimeString = data['startTime'];
      int duration = data['duration'];

      DateTime startTime =
          DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(startTimeString);
      startCountdown(startTime, duration);
    });

    // Listen for periodic syncTimer events to adjust the countdown
    socket?.on('syncTimer', (data) {
      String startTimeString = data['startTime'];
      int duration = data['duration'];

      DateTime startTime =
          DateFormat("yyyy-MM-ddTHH:mm:ssZ").parse(startTimeString);
      adjustCountdown(startTime, duration);
    });

    // Listen for the endGame event
    socket?.on('endGame', (data) {
      countdownTimer?.cancel();
      print(data['message']); // Game over notification
    });
  }

  void startCountdown(DateTime startTime, int duration) {
    final currentTime = DateTime.now();
    final timeElapsed = currentTime.difference(startTime).inSeconds;
    setState(() {
      timeRemaining = duration - timeElapsed;
    });

    countdownTimer?.cancel(); // Cancel any existing timers

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining <= 0) {
        timer.cancel();
        print("Time's up!");
      } else {
        setState(() {
          timeRemaining--;
        });
      }
    });
  }

  void adjustCountdown(DateTime startTime, int duration) {
    final currentTime = DateTime.now();
    final timeElapsed = currentTime.difference(startTime).inSeconds;
    int syncedTimeRemaining = duration - timeElapsed;

    // Adjust the local countdown only if it's off by more than 1 second
    if ((timeRemaining - syncedTimeRemaining).abs() > 1) {
      setState(() {
        timeRemaining = syncedTimeRemaining;
      });
    }
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    socket?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Timer')),
      body: Center(
        child: Text(
          'Time Remaining: $timeRemaining seconds',
          style: const TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
