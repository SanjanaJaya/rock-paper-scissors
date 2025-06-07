// constants.dart
import 'package:flutter/material.dart';

class GameConstants {
  // Colors
  static const Color backgroundColor = Color(0xFF1E1E1E);
  static const Color gameBackgroundColor = Colors.transparent;
  static const Color textColor = Color(0xFFFFFFFF);
  static const Color buttonColor = Color(0xAAFFFFFF); // Semi-transparent white
  static const Color highlightColor = Color(0xFFFFD700); // Gold
  static const Color menuButtonColor = Color(0xAAFFFFFF);
  static const Color menuTextColor = Color(0xFF000000);
  static const Color resultTextColor = Color(0xFFFFD700);
  static const Color winColor = Color(0xFF00FF00);
  static const Color loseColor = Color(0xFFFF0000);

  // Sizes
  static const double buttonWidth = 100;
  static const double buttonHeight = 100;
  static const double menuButtonWidth = 250;
  static const double menuButtonHeight = 60;
  static const double choiceAnimationSize = 180;

  // Assets
  static const String backgroundAsset = 'background.png';
  static const String rockAsset = 'rock.png';
  static const String paperAsset = 'paper.png';
  static const String scissorsAsset = 'scissors.png';
  static const String logoAsset = 'logo.png';
  static const String rockAnimationAsset = 'rock_animation.png';
  static const String paperAnimationAsset = 'paper_animation.png';
  static const String scissorsAnimationAsset = 'scissors_animation.png';
  static const String starAsset = 'star.png';
  static const String emptyStarAsset = 'empty_star.png';
}

enum GameChoice { rock, paper, scissors }
enum GameMode { singlePlayer, multiPlayer }
enum Difficulty { easy, medium, hard }