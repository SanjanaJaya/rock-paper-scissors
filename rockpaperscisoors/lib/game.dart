import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/events.dart';
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
  late RectangleComponent restartArea;

  int playerScore = 0;
  int computerScore = 0;
  final Random _random = Random();
  bool gameEnded = false;
  static const int winningScore = 5;

  // Difficulty system properties
  Difficulty difficulty = Difficulty.medium;
  GameChoice? lastPlayerChoice;

  @override
  Color backgroundColor() => GameConstants.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add buttons
    final buttonSpacing = size.x / 4;
    final startY = size.y * 0.6;

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
      text: 'Player: $playerScore',
      position: Vector2(50, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    computerScoreText = TextComponent(
      text: 'Computer: $computerScore',
      position: Vector2(size.x - 200, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    // Game status text (first to 5 wins)
    gameStatusText = TextComponent(
      text: 'First to $winningScore wins!',
      position: Vector2(size.x / 2, 100),
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
      position: Vector2(size.x / 2, 150),
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
      text: 'You: -',
      position: Vector2(size.x / 4, 250),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 20,
        ),
      ),
    );

    computerChoiceText = TextComponent(
      text: 'Computer: -',
      position: Vector2(size.x * 3/4, 250),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 20,
        ),
      ),
    );

    // Restart instruction text (initially hidden)
    restartText = TextComponent(
      text: '',
      position: Vector2(size.x / 2, size.y - 100),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.highlightColor,
          fontSize: 18,
        ),
      ),
    );

    // Invisible restart area that covers the whole screen
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
  }

  void setDifficulty(Difficulty newDifficulty) {
    difficulty = newDifficulty;
  }

  void makeChoice(GameChoice playerChoice) {
    if (gameEnded) return;

    lastPlayerChoice = playerChoice;
    final computerChoice = getRandomChoice();
    final result = determineWinner(playerChoice, computerChoice);

    // Update choice displays
    playerChoiceText.text = 'You: ${getChoiceName(playerChoice)}';
    computerChoiceText.text = 'Computer: ${getChoiceName(computerChoice)}';

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
      resultText.text = 'Computer wins this round!';
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

    playerScoreText.text = 'Player: $playerScore';
    computerScoreText.text = 'Computer: $computerScore';

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
      resultText.text = '💻 COMPUTER WINS! 💻';
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
  }

  void resetGame() {
    playerScore = 0;
    computerScore = 0;
    gameEnded = false;
    lastPlayerChoice = null;

    playerScoreText.text = 'Player: $playerScore';
    computerScoreText.text = 'Computer: $computerScore';
    gameStatusText.text = 'First to $winningScore wins!';
    resultText.text = 'Choose Rock, Paper, or Scissors!';
    resultText.textRenderer = TextPaint(
      style: const TextStyle(
        color: GameConstants.textColor,
        fontSize: 24,
      ),
    );
    playerChoiceText.text = 'You: -';
    computerChoiceText.text = 'Computer: -';
    restartText.text = '';

    // Remove any restart buttons
    children.whereType<RestartButton>().forEach((button) {
      button.removeFromParent();
    });
  }

  String getChoiceName(GameChoice choice) {
    switch (choice) {
      case GameChoice.rock:
        return '🪨 Rock';
      case GameChoice.paper:
        return '📄 Paper';
      case GameChoice.scissors:
        return '✂️ Scissors';
    }
  }

  GameChoice getRandomChoice() {
    switch (difficulty) {
      case Difficulty.easy:
      // Easy - more predictable choices
        if (_random.nextDouble() < 0.7) {
          // 70% chance to choose the losing option
          return getLosingChoice(lastPlayerChoice ?? getRandomBaseChoice());
        }
        return getRandomBaseChoice();
      case Difficulty.medium:
      // Medium - balanced
        return getRandomBaseChoice();
      case Difficulty.hard:
      // Hard - more likely to win
        if (_random.nextDouble() < 0.7) {
          // 70% chance to choose the winning option
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