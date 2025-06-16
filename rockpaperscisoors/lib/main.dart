// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'game.dart';
import 'constants.dart';
import 'developers_screen.dart';

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

class _MainMenuScreenState extends State<MainMenuScreen> with WidgetsBindingObserver {
  late final RockPaperScissorsGame game;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    game = RockPaperScissorsGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    FlameAudio.bgm.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        FlameAudio.bgm.resume();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        FlameAudio.bgm.pause();
        break;
      case AppLifecycleState.hidden:
        FlameAudio.bgm.pause();
        break;
    }
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 300,
            height: 400,
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'SELECT DIFFICULTY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
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
                GameMenuButton(
                  text: 'EASY',
                  onTap: () {
                    Navigator.pop(context);
                    game.setDifficulty(Difficulty.easy);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(game: game),
                      ),
                    );
                  },
                ),
                GameMenuButton(
                  text: 'MEDIUM',
                  onTap: () {
                    Navigator.pop(context);
                    game.setDifficulty(Difficulty.medium);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(game: game),
                      ),
                    );
                  },
                ),
                GameMenuButton(
                  text: 'HARD',
                  onTap: () {
                    Navigator.pop(context);
                    game.setDifficulty(Difficulty.hard);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreen(game: game),
                      ),
                    );
                  },
                ),
              ],
            ),
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
                  onTap: _showDifficultyDialog,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DevelopersScreen(),
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