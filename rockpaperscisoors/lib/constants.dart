// constants.dart
import 'package:flutter/material.dart';

class GameConstants {
  // Colors
  static const Color backgroundColor = Color(0xFF1E1E1E);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color buttonColor = Color(0xFF4A4A4A);
  static const Color highlightColor = Color(0xFF00FF88);
  static const Color menuButtonColor = Color(0xFF3A3A3A);
  static const Color menuTextColor = Color(0xFFFFFFFF);

  // Sizes
  static const double buttonWidth = 120;
  static const double buttonHeight = 120;
  static const double menuButtonWidth = 250;
  static const double menuButtonHeight = 60;

  // Assets
  static const String rockAsset = 'rock.png';
  static const String paperAsset = 'paper.png';
  static const String scissorsAsset = 'scissors.png';
  static const String logoAsset = 'logo.png';
}

enum GameChoice { rock, paper, scissors }
enum GameMode { singlePlayer, multiPlayer }
enum Difficulty { easy, medium, hard }