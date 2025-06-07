import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class ChoiceButton extends SpriteComponent with TapCallbacks {
  final GameChoice choice;
  final VoidCallback onPressed;

  ChoiceButton({
    required this.choice,
    required this.onPressed,
    required Vector2 position,
  }) : super(
    size: Vector2(GameConstants.buttonWidth, GameConstants.buttonHeight),
    position: position,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final imagePath = switch (choice) {
      GameChoice.rock => GameConstants.rockAsset,
      GameChoice.paper => GameConstants.paperAsset,
      GameChoice.scissors => GameConstants.scissorsAsset,
    };
    sprite = await Sprite.load(imagePath);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
    super.onTapDown(event);
  }
}