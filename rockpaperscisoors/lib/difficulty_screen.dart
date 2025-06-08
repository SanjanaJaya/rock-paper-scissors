// difficulty_screen.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:rockpaperscisoors/constants.dart';
import 'package:rockpaperscisoors/game.dart';
import 'package:rockpaperscisoors/menu_button.dart';

class DifficultySelectionGame extends FlameGame {
  final Function(Difficulty) onDifficultySelected;

  DifficultySelectionGame({required this.onDifficultySelected});

  @override
  Color backgroundColor() => GameConstants.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Don't add UI components here - wait for layout
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Clear existing components when resizing
    removeAll(children.where((component) =>
    component is TextComponent || component is MenuButton).toList());
    _setupUI();
  }

  @override
  void onMount() {
    super.onMount();
    // Setup UI once the game is mounted and has layout
    if (hasLayout) {
      _setupUI();
    }
  }

  void _setupUI() {
    if (!hasLayout) return;

    final centerX = size.x / 2;
    final buttonWidth = size.x * GameConstants.menuButtonWidth;
    final buttonHeight = size.y * GameConstants.menuButtonHeight;
    final buttonSpacing = buttonHeight + 20;

    // Title
    add(TextComponent(
      text: 'Select Difficulty',
      position: Vector2(centerX, size.y * 0.2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: GameConstants.highlightColor,
          fontSize: size.y * 0.045, // 4.5% of screen height
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    // Easy button
    add(MenuButton(
      text: 'Easy',
      onPressed: () => onDifficultySelected(Difficulty.easy),
      position: Vector2(centerX, size.y * 0.35),
      size: Vector2(buttonWidth, buttonHeight),
      buttonColor: Colors.green.withOpacity(0.7),
      textColor: Colors.white,
    ));

    // Medium button
    add(MenuButton(
      text: 'Medium',
      onPressed: () => onDifficultySelected(Difficulty.medium),
      position: Vector2(centerX, size.y * 0.35 + buttonSpacing),
      size: Vector2(buttonWidth, buttonHeight),
      buttonColor: Colors.orange.withOpacity(0.7),
      textColor: Colors.white,
    ));

    // Hard button
    add(MenuButton(
      text: 'Hard',
      onPressed: () => onDifficultySelected(Difficulty.hard),
      position: Vector2(centerX, size.y * 0.35 + buttonSpacing * 2),
      size: Vector2(buttonWidth, buttonHeight),
      buttonColor: Colors.red.withOpacity(0.7),
      textColor: Colors.white,
    ));

    // Back button
    add(MenuButton(
      text: 'Back',
      onPressed: () {
        // Navigate back to main menu
        // This might need to be handled differently depending on your navigation setup
      },
      position: Vector2(centerX, size.y - buttonHeight * 1.5),
      size: Vector2(buttonWidth, buttonHeight),
      buttonColor: GameConstants.buttonColor,
      textColor: Colors.black,
    ));
  }
}