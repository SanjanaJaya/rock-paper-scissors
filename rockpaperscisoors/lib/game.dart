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

  int playerScore = 0;
  int computerScore = 0;
  final Random _random = Random();

  @override
  Color backgroundColor() => GameConstants.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add buttons
    final buttonSpacing = size.x / 4;
    final startY = size.y / 2;

    add(ChoiceButton(
      choice: GameChoice.rock,
      onPressed: () => makeChoice(GameChoice.rock),
      position: Vector2(buttonSpacing, startY),
    ));

    add(ChoiceButton(
      choice: GameChoice.paper,
      onPressed: () => makeChoice(GameChoice.paper),
      position: Vector2(buttonSpacing * 2, startY),
    ));

    add(ChoiceButton(
      choice: GameChoice.scissors,
      onPressed: () => makeChoice(GameChoice.scissors),
      position: Vector2(buttonSpacing * 3, startY),
    ));

    // Add score texts
    playerScoreText = TextComponent(
      text: 'Player: $playerScore',
      position: Vector2(50, 50),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 24,
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
        ),
      ),
    );

    resultText = TextComponent(
      text: 'Choose an option!',
      position: Vector2(size.x / 2, 100),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: GameConstants.textColor,
          fontSize: 32,
        ),
      ),
    );

    add(playerScoreText);
    add(computerScoreText);
    add(resultText);
  }

  void makeChoice(GameChoice playerChoice) {
    final computerChoice = getRandomChoice();
    final result = determineWinner(playerChoice, computerChoice);

    // Update scores and display result
    if (result == 1) {
      playerScore++;
      resultText.text = 'You win!';
    } else if (result == -1) {
      computerScore++;
      resultText.text = 'Computer wins!';
    } else {
      resultText.text = 'It\'s a tie!';
    }

    playerScoreText.text = 'Player: $playerScore';
    computerScoreText.text = 'Computer: $computerScore';
  }

  GameChoice getRandomChoice() {
    final random = _random.nextInt(3);
    return GameChoice.values[random];
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