import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
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
    Vector2? size,
  }) : super(
    size: size ?? Vector2(GameConstants.buttonWidth, GameConstants.buttonHeight),
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

      // Draw border with responsive corner radius
      final cornerRadius = size.x * 0.1; // 10% of button width
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          Radius.circular(cornerRadius),
        ),
        Paint()..color = _isPressed ? GameConstants.highlightColor : GameConstants.buttonColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.x * 0.02, // 2% of button width
      );

      super.render(canvas);
    } else {
      // Fallback rendering with text
      final paint = Paint()
        ..color = _isPressed ? GameConstants.highlightColor : GameConstants.buttonColor
        ..style = PaintingStyle.fill;

      final cornerRadius = size.x * 0.1; // 10% of button width
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.x, size.y),
          Radius.circular(cornerRadius),
        ),
        paint,
      );

      // Draw choice text with responsive font size
      final emojiSize = size.x * 0.3; // 30% of button width
      final textPainter = TextPainter(
        text: TextSpan(
          text: getChoiceEmoji(),
          style: TextStyle(
            color: Colors.white,
            fontSize: emojiSize,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.x - textPainter.width) / 2,
          (size.y - textPainter.height) / 2 - size.y * 0.1,
        ),
      );

      // Draw choice name with responsive font size
      final textSize = size.x * 0.12; // 12% of button width
      final namePainter = TextPainter(
        text: TextSpan(
          text: getChoiceText(),
          style: TextStyle(
            color: Colors.white,
            fontSize: textSize,
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
          size.y - (size.y * 0.2), // 20% from bottom
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
    FlameAudio.play(GameConstants.buttonClickSound, volume: 0.7);
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