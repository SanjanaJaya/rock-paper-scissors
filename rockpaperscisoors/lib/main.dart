import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rock Paper Scissors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: RockPaperScissorsGame(),
      ),
    );
  }
}