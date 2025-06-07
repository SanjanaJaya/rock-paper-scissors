import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:rockpaperscisoors/constants.dart';

class ChoiceButton extends SpriteComponent with TapCallbacks, HasVisibility {
  final GameChoice choice;
  final VoidCallback onPressed;
  bool _isPressed = false;

  ChoiceButton({
    required this.choice,
    required this.onPressed,
    required Vector2 position,
  }) : super(
    size: Vector2(GameConstants.buttonWidth, GameConstants.buttonHeight),
    position: position,
    anchor: Anchor.center,
  );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final imagePath = switch (choice) {
      GameChoice.rock => GameConstants.rockAsset,
      GameChoice.paper => GameConstants.paperAsset,
      GameChoice.scissors => GameConstants.scissorsAsset,
    };

    try {
      sprite = await Sprite.load(imagePath);
    } catch (e) {
      // If image loading fails, create a simple colored rectangle as fallback
      sprite = null;
    }
  }

  @override
  void render(Canvas canvas) {
    if (sprite != null) {
      // Draw the sprite with some visual feedback
      final paint = Paint();
      if (_isPressed) {
        paint.colorFilter = const ColorFilter.mode(Colors.grey, BlendMode.multiply);
      }

      // Draw border
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          const Radius.circular(10),
        ),
        Paint()..color = _isPressed ? GameConstants.highlightColor : GameConstants.buttonColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      super.render(canvas);
    } else {
      // Fallback rendering with text
      final paint = Paint()
        ..color = _isPressed ? GameConstants.highlightColor : GameConstants.buttonColor
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          const Radius.circular(10),
        ),
        paint,
      );

      // Draw choice text
      final textPainter = TextPainter(
        text: TextSpan(
          text: getChoiceEmoji(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.x - textPainter.width) / 2,
          (size.y - textPainter.height) / 2,
        ),
      );

      // Draw choice name
      final namePainter = TextPainter(
        text: TextSpan(
          text: getChoiceText(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      namePainter.layout();
      namePainter.paint(
        canvas,
        Offset(
          (size.x - namePainter.width) / 2,
          size.y - 25,
        ),
      );
    }
  }

  String getChoiceEmoji() {
    switch (choice) {
      case GameChoice.rock:
        return '🪨';
      case GameChoice.paper:
        return '📄';
      case GameChoice.scissors:
        return '✂️';
    }
  }

  String getChoiceText() {
    switch (choice) {
      case GameChoice.rock:
        return 'ROCK';
      case GameChoice.paper:
        return 'PAPER';
      case GameChoice.scissors:
        return 'SCISSORS';
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isPressed = true;
    onPressed();
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isPressed = false;
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isPressed = false;
    super.onTapCancel(event);
  }
}