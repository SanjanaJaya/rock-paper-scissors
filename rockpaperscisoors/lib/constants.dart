import 'package:flutter/material.dart';

class GameConstants {
  static const Color backgroundColor = Color(0xFF1E1E1E);
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color buttonColor = Color(0xFF4A4A4A);
  static const Color highlightColor = Color(0xFF00FF00);

  static const double buttonWidth = 150;
  static const double buttonHeight = 150;

  static const String rockAsset = 'rock.png';
  static const String paperAsset = 'paper.png';
  static const String scissorsAsset = 'scissors.png';
}

enum GameChoice { rock, paper, scissors }