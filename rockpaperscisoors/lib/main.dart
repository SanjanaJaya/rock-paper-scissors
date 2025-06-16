// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'game.dart';
import 'difficulty_screen.dart';
import 'constants.dart';
import 'menu_button.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rock Paper Scissors',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
      ),
      home: const MainMenuScreen(),
    );
  }
}

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late final RockPaperScissorsGame game;
  late final DifficultySelectionGame difficultyGame;

  @override
  void initState() {
    super.initState();
    game = RockPaperScissorsGame();
    difficultyGame = DifficultySelectionGame(
      onDifficultySelected: (difficulty) {
        game.setDifficulty(difficulty);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(game: game),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background_menu.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title Text
                Text(
                  'ROCK PAPER\nSCISSORS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 3,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                // Hand Icons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/rock_animation.png', width: 60),
                    SizedBox(width: 20),
                    Image.asset('assets/images/paper_animation.png', width: 60),
                    SizedBox(width: 20),
                    Image.asset('assets/images/scissors_animation.png', width: 60),
                  ],
                ),
                SizedBox(height: 50),
                // Buttons
                GameMenuButton(
                  text: 'PLAYER VS AI',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(game: difficultyGame),
                      ),
                    );
                  },
                ),
                GameMenuButton(
                  text: 'PLAYER VS PLAYER',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Multiplayer mode coming soon!')),
                    );
                  },
                ),
                GameMenuButton(
                  text: 'DEVELOPERS',
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Developers'),
                        content: const Text('This game was developed by your team.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GameMenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const GameMenuButton({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: 260,
        height: 60,
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

// Keep the existing _MainMenuGame class for compatibility (not used in new UI)
class _MainMenuGame extends FlameGame {
  final VoidCallback onSinglePlayer;
  final VoidCallback onMultiPlayer;
  final VoidCallback onDevelopers;

  _MainMenuGame({
    required this.onSinglePlayer,
    required this.onMultiPlayer,
    required this.onDevelopers,
  });

  @override
  Color backgroundColor() => GameConstants.backgroundColor;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Don't add UI components here - wait for layout
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    // Clear existing components when resizing
    removeAll(children.where((component) =>
    component is TextComponent || component is MenuButton).toList());
    _setupUI();
  }

  @override
  void onMount() {
    super.onMount();
    // Setup UI once the game is mounted and has layout
    if (hasLayout) {
      _setupUI();
    }
  }

  void _setupUI() {
    if (!hasLayout) return;

    final centerX = size.x / 2;
    final buttonWidth = size.x * GameConstants.menuButtonWidth;
    final buttonHeight = size.y * GameConstants.menuButtonHeight;
    final buttonSpacing = buttonHeight + 20;

    // Title
    add(TextComponent(
      text: 'Rock Paper Scissors',
      position: Vector2(centerX, size.y * 0.2),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: GameConstants.highlightColor,
          fontSize: size.y * 0.05, // 5% of screen height
          fontWeight: FontWeight.bold,
        ),
      ),
    ));

    // Single Player button
    add(MenuButton(
      text: 'Player vs AI',
      onPressed: onSinglePlayer,
      position: Vector2(centerX, size.y * 0.4),
      size: Vector2(buttonWidth, buttonHeight),
    ));

    // Multi Player button
    add(MenuButton(
      text: 'Player vs Player',
      onPressed: onMultiPlayer,
      position: Vector2(centerX, size.y * 0.4 + buttonSpacing),
      size: Vector2(buttonWidth, buttonHeight),
    ));

    // Developers button
    add(MenuButton(
      text: 'Developers',
      onPressed: onDevelopers,
      position: Vector2(centerX, size.y * 0.4 + buttonSpacing * 2),
      size: Vector2(buttonWidth, buttonHeight),
    ));
  }
}

class GameScreen extends StatelessWidget {
  final FlameGame game;

  const GameScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Rock Paper Scissors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF2A2A2A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GameWidget(game: game),
    );
  }
}