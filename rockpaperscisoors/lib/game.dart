// game.dart
import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
import 'package:flame/sprite.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'components/choice_button.dart';
import 'constants.dart';

class RockPaperScissorsGame extends FlameGame with HasKeyboardHandlerComponents, HasCollisionDetection {
  late TextComponent playerScoreText;
  late TextComponent computerScoreText;
  late TextComponent resultText;
  late TextComponent playerChoiceText;
  late TextComponent computerChoiceText;
  late TextComponent gameStatusText;
  late TextComponent restartText;
  late SpriteComponent background;
  late RectangleComponent restartArea;

  int playerScore = 0;
  int computerScore = 0;
  final Random _random = Random();
  bool gameEnded = false;
  bool isAnimating = false;
  static const int winningScore = 5;
  List<SpriteComponent> playerStars = [];
  List<SpriteComponent> computerStars = [];

  // Difficulty system properties
  Difficulty difficulty = Difficulty.medium;
  GameChoice? lastPlayerChoice;

  @override
  Color backgroundColor() => GameConstants.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add background image
    background = SpriteComponent(
      sprite: await Sprite.load(GameConstants.backgroundAsset),
      size: size,
    );
    add(background);

    // Calculate dynamic sizes
    final buttonWidth = size.x * GameConstants.buttonWidth;
    final buttonHeight = size.x * GameConstants.buttonHeight;
    final buttonSpacing = size.x * GameConstants.buttonSpacing;
    final buttonBottomMargin = size.y * GameConstants.buttonBottomMargin;

    // Add buttons - positioned in a row at the bottom
    final totalButtonsWidth = (buttonWidth * 3) + (buttonSpacing * 2);
    final startX = (size.x - totalButtonsWidth) / 2;
    final buttonY = size.y - buttonHeight - buttonBottomMargin;

    add(ChoiceButton(
      choice: GameChoice.rock,
      onPressed: () => makeChoice(GameChoice.rock),
      position: Vector2(startX, buttonY),
      size: Vector2(buttonWidth, buttonHeight),
    ));

    add(ChoiceButton(
      choice: GameChoice.paper,
      onPressed: () => makeChoice(GameChoice.paper),
      position: Vector2(startX + buttonWidth + buttonSpacing, buttonY),
      size: Vector2(buttonWidth, buttonHeight),
    ));

    add(ChoiceButton(
      choice: GameChoice.scissors,
      onPressed: () => makeChoice(GameChoice.scissors),
      position: Vector2(startX + (buttonWidth + buttonSpacing) * 2, buttonY),
      size: Vector2(buttonWidth, buttonHeight),
    ));

    // Add score texts
    playerScoreText = TextComponent(
      text: 'YOU: $playerScore',
      position: Vector2(40, 40),
      textRenderer: TextPaint(
        style: TextStyle(
          color: GameConstants.textColor,
          fontSize: size.y * 0.03, // 3% of screen height
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );

    computerScoreText = TextComponent(
      text: 'AI: $computerScore',
      position: Vector2(size.x - 80, 40),
      textRenderer: TextPaint(
        style: TextStyle(
          color: GameConstants.textColor,
          fontSize: size.y * 0.03,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );

    // Game status text
    gameStatusText = TextComponent(
      text: 'First to $winningScore wins!',
      position: Vector2(size.x / 2, size.y * 0.1),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: GameConstants.highlightColor,
          fontSize: size.y * 0.025,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );

    resultText = TextComponent(
      text: 'Choose Rock, Paper, or Scissors!',
      position: Vector2(size.x / 2, size.y * 0.5),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: GameConstants.resultTextColor,
          fontSize: size.y * 0.03,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );

    // Player and Computer choice display
    playerChoiceText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y * 0.7),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: GameConstants.textColor,
          fontSize: size.y * 0.025,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );

    computerChoiceText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y * 0.3),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: GameConstants.textColor,
          fontSize: size.y * 0.025,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );

    // Restart instruction text
    restartText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y - (buttonBottomMargin / 2)),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: GameConstants.highlightColor,
          fontSize: size.y * 0.025,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 5,
              offset: Offset(2, 2),
            ),
          ],
        ),
      ),
    );

    // Invisible restart area
    restartArea = RectangleComponent(
      size: size,
      position: Vector2.zero(),
      paint: Paint()..color = Colors.transparent,
    );

    add(playerScoreText);
    add(computerScoreText);
    add(gameStatusText);
    add(resultText);
    add(playerChoiceText);
    add(computerChoiceText);
    add(restartText);

    // Initialize stars
    await _initializeStars();
  }

  Future<void> _initializeStars() async {
    final starSize = size.y * 0.04; // 4% of screen height
    final starSpacing = size.x * 0.05; // 5% of screen width
    final startX = size.x / 2 - (winningScore * starSpacing) / 2;

    // Clear existing stars
    for (final star in playerStars) {
      star.removeFromParent();
    }
    for (final star in computerStars) {
      star.removeFromParent();
    }
    playerStars.clear();
    computerStars.clear();

    // Create new stars
    for (int i = 0; i < winningScore; i++) {
      final playerStar = SpriteComponent(
        sprite: await Sprite.load(GameConstants.emptyStarAsset),
        size: Vector2.all(starSize),
        position: Vector2(startX + i * starSpacing, size.y * 0.15),
      );
      playerStars.add(playerStar);
      add(playerStar);

      final computerStar = SpriteComponent(
        sprite: await Sprite.load(GameConstants.emptyStarAsset),
        size: Vector2.all(starSize),
        position: Vector2(startX + i * starSpacing, size.y * 0.2),
      );
      computerStars.add(computerStar);
      add(computerStar);
    }
  }

  Future<void> _updateStars() async {
    for (int i = 0; i < winningScore; i++) {
      if (i < playerScore) {
        playerStars[i].sprite = await Sprite.load(GameConstants.starAsset);
      } else {
        playerStars[i].sprite = await Sprite.load(GameConstants.emptyStarAsset);
      }

      if (i < computerScore) {
        computerStars[i].sprite = await Sprite.load(GameConstants.starAsset);
      } else {
        computerStars[i].sprite = await Sprite.load(GameConstants.emptyStarAsset);
      }
    }
  }

  void setDifficulty(Difficulty newDifficulty) {
    difficulty = newDifficulty;
  }

  Future<void> makeChoice(GameChoice playerChoice) async {
    if (gameEnded || isAnimating) return;

    isAnimating = true;
    lastPlayerChoice = playerChoice;

    try {
      // Show player choice animation
      final playerAnimation = await _createChoiceAnimation(playerChoice, false);
      add(playerAnimation);
      playerChoiceText.text = 'You chose ${getChoiceName(playerChoice)}';

      await Future.delayed(const Duration(milliseconds: 800));

      // Computer makes choice
      final computerChoice = getRandomChoice();
      final computerAnimation = await _createChoiceAnimation(computerChoice, true);
      add(computerAnimation);
      computerChoiceText.text = 'AI chose ${getChoiceName(computerChoice)}';

      await Future.delayed(const Duration(milliseconds: 800));

      // Remove animations
      playerAnimation.removeFromParent();
      computerAnimation.removeFromParent();

      // Determine winner
      final result = determineWinner(playerChoice, computerChoice);

      // Update scores and display result
      if (result == 1) {
        playerScore++;
        resultText.text = 'You win this round!';
        resultText.textRenderer = TextPaint(
          style: TextStyle(
            color: GameConstants.winColor,
            fontSize: size.y * 0.03,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
        );
      } else if (result == -1) {
        computerScore++;
        resultText.text = 'AI wins this round!';
        resultText.textRenderer = TextPaint(
          style: TextStyle(
            color: GameConstants.loseColor,
            fontSize: size.y * 0.03,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
        );
      } else {
        resultText.text = 'It\'s a tie!';
        resultText.textRenderer = TextPaint(
          style: TextStyle(
            color: Colors.yellow,
            fontSize: size.y * 0.03,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
        );
      }

      playerScoreText.text = 'YOU: $playerScore';
      computerScoreText.text = 'AI: $computerScore';
      await _updateStars();

      // Check for game end
      if (playerScore >= winningScore) {
        gameEnded = true;
        resultText.text = '🎉 YOU WON THE GAME! 🎉';
        resultText.textRenderer = TextPaint(
          style: TextStyle(
            color: GameConstants.winColor,
            fontSize: size.y * 0.035,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
        );
        gameStatusText.text = 'VICTORY!';
        restartText.text = 'Tap anywhere to play again!';
        add(RestartButton(onPressed: resetGame, size: size));
      } else if (computerScore >= winningScore) {
        gameEnded = true;
        resultText.text = '💻 AI WINS! 💻';
        resultText.textRenderer = TextPaint(
          style: TextStyle(
            color: GameConstants.loseColor,
            fontSize: size.y * 0.035,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 5,
                offset: Offset(2, 2),
              ),
            ],
          ),
        );
        gameStatusText.text = 'GAME OVER!';
        restartText.text = 'Tap anywhere to play again!';
        add(RestartButton(onPressed: resetGame, size: size));
      }
    } catch (e) {
      debugPrint('Error in makeChoice: $e');
    } finally {
      isAnimating = false;
    }
  }

  Future<SpriteComponent> _createChoiceAnimation(GameChoice choice, bool isComputer) async {
    String assetPath;
    switch (choice) {
      case GameChoice.rock:
        assetPath = GameConstants.rockAnimationAsset;
        break;
      case GameChoice.paper:
        assetPath = GameConstants.paperAnimationAsset;
        break;
      case GameChoice.scissors:
        assetPath = GameConstants.scissorsAnimationAsset;
        break;
    }

    final sprite = await Sprite.load(assetPath);
    final animationSize = size.x * GameConstants.choiceAnimationSize;
    return SpriteComponent(
      sprite: sprite,
      size: Vector2.all(animationSize),
      position: Vector2(
        size.x / 2 - animationSize / 2,
        isComputer ? size.y * 0.25 : size.y * 0.6,
      ),
    )..opacity = 0.0
      ..add(OpacityEffect.fadeIn(EffectController(duration: 0.3)));
  }

  Future<void> resetGame() async {
    playerScore = 0;
    computerScore = 0;
    gameEnded = false;
    lastPlayerChoice = null;
    isAnimating = false;

    playerScoreText.text = 'YOU: $playerScore';
    computerScoreText.text = 'AI: $computerScore';
    gameStatusText.text = 'First to $winningScore wins!';
    resultText.text = 'Choose Rock, Paper, or Scissors!';
    resultText.textRenderer = TextPaint(
      style: TextStyle(
        color: GameConstants.resultTextColor,
        fontSize: size.y * 0.03,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black,
            blurRadius: 5,
            offset: Offset(2, 2),
          ),
        ],
      ),
    );
    playerChoiceText.text = '';
    computerChoiceText.text = '';
    restartText.text = '';
    await _updateStars();

    // Remove any restart buttons
    children.whereType<RestartButton>().forEach((button) {
      button.removeFromParent();
    });
  }

  String getChoiceName(GameChoice choice) {
    switch (choice) {
      case GameChoice.rock:
        return 'Rock';
      case GameChoice.paper:
        return 'Paper';
      case GameChoice.scissors:
        return 'Scissors';
    }
  }

  GameChoice getRandomChoice() {
    switch (difficulty) {
      case Difficulty.easy:
        if (_random.nextDouble() < 0.7) {
          return getLosingChoice(lastPlayerChoice ?? getRandomBaseChoice());
        }
        return getRandomBaseChoice();
      case Difficulty.medium:
        return getRandomBaseChoice();
      case Difficulty.hard:
        if (_random.nextDouble() < 0.7) {
          return getWinningChoice(lastPlayerChoice ?? getRandomBaseChoice());
        }
        return getRandomBaseChoice();
    }
  }

  GameChoice getRandomBaseChoice() {
    final random = _random.nextInt(3);
    return GameChoice.values[random];
  }

  GameChoice getWinningChoice(GameChoice against) {
    switch (against) {
      case GameChoice.rock:
        return GameChoice.paper;
      case GameChoice.paper:
        return GameChoice.scissors;
      case GameChoice.scissors:
        return GameChoice.rock;
    }
  }

  GameChoice getLosingChoice(GameChoice against) {
    switch (against) {
      case GameChoice.rock:
        return GameChoice.scissors;
      case GameChoice.paper:
        return GameChoice.rock;
      case GameChoice.scissors:
        return GameChoice.paper;
    }
  }

  int determineWinner(GameChoice player, GameChoice computer) {
    if (player == computer) return 0;

    switch (player) {
      case GameChoice.rock:
        return computer == GameChoice.scissors ? 1 : -1;
      case GameChoice.paper:
        return computer == GameChoice.rock ? 1 : -1;
      case GameChoice.scissors:
        return computer == GameChoice.paper ? 1 : -1;
    }
  }
}

class RestartButton extends RectangleComponent with TapCallbacks {
  final VoidCallback onPressed;

  RestartButton({
    required this.onPressed,
    required Vector2 size,
  }) : super(
    size: size,
    position: Vector2.zero(),
    paint: Paint()..color = Colors.transparent,
  );

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
    super.onTapDown(event);
  }
}