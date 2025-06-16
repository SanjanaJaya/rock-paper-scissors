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

// Flutter widget version of the menu button for consistent styling
class FlutterMenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double? width;
  final double? height;

  const FlutterMenuButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.width = 260,
    this.height = 60,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/button.png'),
            fit: BoxFit.fill,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 2,
                color: Colors.black,
              )
            ],
          ),
        ),
      ),
    );
  }
}