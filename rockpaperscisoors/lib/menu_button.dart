// menu_button.dart
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:rockpaperscisoors/constants.dart';

class MenuButton extends RectangleComponent with TapCallbacks {
  final String text;
  final VoidCallback onPressed;
  final Color buttonColor;
  final Color textColor;

  MenuButton({
    required this.text,
    required this.onPressed,
    this.buttonColor = GameConstants.menuButtonColor,
    this.textColor = GameConstants.menuTextColor,
    required Vector2 position,
  }) : super(
    size: Vector2(GameConstants.menuButtonWidth, GameConstants.menuButtonHeight),
    position: position,
    anchor: Anchor.center,
    paint: Paint()..color = buttonColor,
  );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Draw button text
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
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

    // Draw border
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(10),
      ),
      Paint()
        ..color = GameConstants.highlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
    super.onTapDown(event);
  }
}