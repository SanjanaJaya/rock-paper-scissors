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
  late RectangleComponent gameBackground;
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

    // Add game background
    gameBackground = RectangleComponent(
      size: Vector2(size.x, size.y * 0.7),
      position: Vector2(0, size.y * 0.15),
      paint: Paint()..color = GameConstants.gameBackgroundColor,
    );
    add(gameBackground);

    // Add buttons
    final buttonSpacing = size.x / 4;
    final startY = size.y * 0.8;

    add(ChoiceButton(
      choice: GameChoice.rock,
      onPressed: () => makeChoice(GameChoice.rock),
      position: Vector2(buttonSpacing - GameConstants.buttonWidth/2, startY),
    ));

    add(ChoiceButton(
      choice: GameChoice.paper,
      onPressed: () => makeChoice(GameChoice.paper),
      position: Vector2(buttonSpacing * 2 - GameConstants.buttonWidth/2, startY),
    ));

    add(ChoiceButton(
      choice: GameChoice.scissors,
      onPressed: () => makeChoice(GameChoice.scissors),
      position: Vector2(buttonSpacing * 3 - GameConstants.buttonWidth/2, startY),
    ));

    // Add score texts
    playerScoreText = TextComponent(
      text: 'YOU: $playerScore',
      position: Vector2(50, size.y * 0.2),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    computerScoreText = TextComponent(
      text: 'AI: $computerScore',
      position: Vector2(size.x - 100, size.y * 0.2),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Game status text
    gameStatusText = TextComponent(
      text: 'First to $winningScore wins!',
      position: Vector2(size.x / 2, size.y * 0.1),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.highlightColor,
          fontSize: 20,
        ),
      ),
    );

    resultText = TextComponent(
      text: 'Choose Rock, Paper, or Scissors!',
      position: Vector2(size.x / 2, size.y * 0.5),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 24,
        ),
      ),
    );

    // Player and Computer choice display
    playerChoiceText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y * 0.7),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 20,
        ),
      ),
    );

    computerChoiceText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y * 0.3),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 20,
        ),
      ),
    );

    // Restart instruction text
    restartText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y - 50),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.highlightColor,
          fontSize: 18,
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
    final starSize = 30.0;
    final starSpacing = 40.0;
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
        position: Vector2(startX + i * starSpacing, size.y * 0.6),
      );
      playerStars.add(playerStar);
      add(playerStar);

      final computerStar = SpriteComponent(
        sprite: await Sprite.load(GameConstants.emptyStarAsset),
        size: Vector2.all(starSize),
        position: Vector2(startX + i * starSpacing, size.y * 0.4),
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
          style: const TextStyle(
            color: GameConstants.highlightColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
      } else if (result == -1) {
        computerScore++;
        resultText.text = 'AI wins this round!';
        resultText.textRenderer = TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        );
      } else {
        resultText.text = 'It\'s a tie!';
        resultText.textRenderer = TextPaint(
          style: const TextStyle(
            color: Colors.yellow,
            fontSize: 24,
            fontWeight: FontWeight.bold,
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
          style: const TextStyle(
            color: GameConstants.highlightColor,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        );
        gameStatusText.text = 'VICTORY!';
        restartText.text = 'Tap anywhere to play again!';
        add(RestartButton(onPressed: resetGame, size: size));
      } else if (computerScore >= winningScore) {
        gameEnded = true;
        resultText.text = '💻 AI WINS! 💻';
        resultText.textRenderer = TextPaint(
          style: const TextStyle(
            color: Colors.red,
            fontSize: 28,
            fontWeight: FontWeight.bold,
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
    return SpriteComponent(
      sprite: sprite,
      size: Vector2.all(GameConstants.choiceAnimationSize),
      position: Vector2(
        size.x / 2 - GameConstants.choiceAnimationSize / 2,
        isComputer ? size.y * 0.25 : size.y * 0.55,
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
      style: const TextStyle(
        color: GameConstants.textColor,
        fontSize: 24,
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