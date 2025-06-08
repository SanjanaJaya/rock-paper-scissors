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
  bool _isPressed = false;

  MenuButton({
    required this.text,
    required this.onPressed,
    this.buttonColor = GameConstants.menuButtonColor,
    this.textColor = GameConstants.menuTextColor,
    required Vector2 position,
    Vector2? size,
  }) : super(
    size: size ?? Vector2(200, 60), // Default fallback size
    position: position,
    anchor: Anchor.center,
  );

  @override
  void render(Canvas canvas) {
    // Button background with pressed state
    final bgColor = _isPressed
        ? buttonColor.withOpacity(0.8)
        : buttonColor;

    final backgroundPaint = Paint()..color = bgColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(10),
      ),
      backgroundPaint,
    );

    // Draw button text
    final fontSize = size.y * 0.3; // Scale font size with button height
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: fontSize,
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