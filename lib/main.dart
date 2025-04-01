import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_notes/graphics/music-line.dart';
import 'package:music_test/game_cubit.dart';
import 'package:music_test/game_state.dart';
import 'package:music_test/score.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GameCubit gameCubit = GameCubit();

  @override
  void initState() {
    super.initState();
    var status = Permission.microphone.status;
    status.then((value) {
      if (value.isDenied) {
        Permission.microphone.request();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Piano Demo',
        home: BlocBuilder<GameCubit, GameState>(
            bloc: gameCubit,
            builder: (context, state) {
              return Scaffold(
                backgroundColor: () {
                  if (state is GameStateFinished) {
                    return state.status == FinishedStatus.success
                        ? Color.fromRGBO(230, 250, 235, 0.8)
                        : Color.fromRGBO(255, 217, 217, 0.8);
                  }
                  return Colors.white;
                }(),
                body: Column(children: [
                  Center(
                    child: ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxHeight: 200, maxWidth: 370),
                      child: MusicLine(
                        options: MusicLineOptions(
                          x,
                          36,
                          3,
                        ),
                      ),
                    ),
                  ),
                  BlocBuilder<GameCubit, GameState>(
                      bloc: gameCubit,
                      builder: (context, state) {
                        return gameStateWidget(state);
                      }),
                ]),
              );
            }));
  }

  Widget startGameButton(String text) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          gameCubit.startGame();
        },
        child: Text(text),
      ),
    );
  }

  Widget gameStateWidget(GameState state) {
    if (state is GameStatePlaying) {
      if (state.status == PlayingStatus.waiting) {
        return Placeholder.waiting();
      } else if (state.status == PlayingStatus.hearing ||
          state.status == PlayingStatus.standBy) {
        return Placeholder.hearing(text: state.text);
      } else if (state.status == PlayingStatus.wronged) {
        return Placeholder.wronged(text: state.text);
      } else if (state.status == PlayingStatus.correct) {
        return Placeholder.correct(text: state.text);
      }
    }
    if (state is GameStateFinished) {
      if (state.status == FinishedStatus.success) {
        return EndgameWidget(
          text: "You did it! \n You must be a great musician!",
          buttonText: "Play again",
          onPressed: () {
            gameCubit.startGame();
          },
          textColor: Colors.green,
        );
      } else {
        return EndgameWidget(
          text:
              "You failed! \n You must play the correct notes in the appropriate time!",
          buttonText: "Try again",
          onPressed: () {
            gameCubit.startGame();
          },
          textColor: Colors.white,
        );
      }
    }
    return ElevatedButton(
      onPressed: () {
        gameCubit.startGame();
      },
      child: Text('Let\'s play!'),
    );
  }
}

class EndgameWidget extends StatelessWidget {
  final String text;
  final String buttonText;
  final Function onPressed;
  final Color textColor;

  const EndgameWidget({
    super.key,
    required this.text,
    required this.buttonText,
    required this.onPressed,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => onPressed(),
          child: Text(buttonText),
        ),
      ],
    );
  }
}

class Placeholder extends StatelessWidget {
  const Placeholder(
      {super.key, required this.backgroundColor, required this.text});

  Placeholder.waiting({super.key})
      : backgroundColor = Colors.lightBlueAccent.withAlpha(100),
        text = "";

  const Placeholder.hearing({super.key, required this.text})
      : backgroundColor = Colors.blue;

  const Placeholder.wronged({super.key, required this.text})
      : backgroundColor = Colors.red;

  const Placeholder.correct({
    super.key,
    required this.text,
  }) : backgroundColor = Colors.green;

  final Color backgroundColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 250),
      width: 100,
      height: 100,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: backgroundColor,
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
