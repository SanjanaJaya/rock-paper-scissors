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

  // Sizes - now based on percentages of screen size
  static const double buttonWidth = 0.2; // 20% of screen width
  static const double buttonHeight = 0.2; // 20% of screen width (to keep square)
  static const double menuButtonWidth = 0.6;
  static const double menuButtonHeight = 0.1;
  static const double choiceAnimationSize = 0.4; // 40% of screen width

  // Spacing
  static const double buttonSpacing = 0.05; // 5% of screen width between buttons
  static const double buttonBottomMargin = 0.05; // 5% from bottom

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