// difficulty_screen.dart
// This file is kept for reference but the difficulty selection is now handled
// as a popup dialog in main.dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:rockpaperscisoors/constants.dart';

// This class is kept for backward compatibility but is no longer used
// The difficulty selection is now handled as a popup dialog in main.dart
class DifficultySelectionGame extends FlameGame {
  final Function(Difficulty) onDifficultySelected;

  DifficultySelectionGame({required this.onDifficultySelected});

  @override
  Color backgroundColor() => GameConstants.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // This game class is no longer used - difficulty selection is now a popup
  }
}