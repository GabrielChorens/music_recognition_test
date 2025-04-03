import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_test/service/note_recognition/audio_recognition_stream.dart';
import 'package:music_test/service/note_recognition/domain/expected_notes.dart';
import 'package:rxdart/rxdart.dart';

import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameStateInitial()) {
    stream.listen((event) {
      if (event is GameStatePlaying && event.status == PlayingStatus.wronged) {
        endGame(false);
      }
    });
  }

  int _inTurnCounter = 0;
  Timer? _timer;
  final AudioRecognitionStream _audioRecognitionStream =
      AudioRecognitionStream();

  void startGame() {
    _inTurnCounter = 0;
    _audioRecognitionStream.startMusicListening();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      final discriminated = discriminate();
      if (discriminated != null) {
        increaseInTurnCounter();
        return emit(discriminated);
      } else {
        emit(switch (_inTurnCounter) {
          1 => GameStatePlaying(text: "1", status: PlayingStatus.standBy),
          3 => GameStatePlaying(text: "2", status: PlayingStatus.standBy),
          5 => GameStatePlaying(text: "3", status: PlayingStatus.standBy),
          7 => GameStatePlaying(text: "4", status: PlayingStatus.standBy),
          9 => GameStatePlaying(text: "C", status: PlayingStatus.hearing),
          11 => GameStatePlaying(text: "D", status: PlayingStatus.hearing),
          13 => GameStatePlaying(text: "E", status: PlayingStatus.hearing),
          15 => GameStatePlaying(text: "F", status: PlayingStatus.hearing),
          17 => GameStatePlaying(text: "E", status: PlayingStatus.hearing),
          19 => GameStatePlaying(text: "F", status: PlayingStatus.hearing),
          21 => GameStatePlaying(text: "E", status: PlayingStatus.hearing),
          23 => GameStatePlaying(text: "", status: PlayingStatus.waiting),
          25 => GameStatePlaying(text: "F", status: PlayingStatus.hearing),
          27 => GameStatePlaying(text: "", status: PlayingStatus.waiting),
          29 => GameStatePlaying(text: "E", status: PlayingStatus.hearing),
          31 => GameStatePlaying(text: "", status: PlayingStatus.waiting),
          33 => GameStatePlaying(text: "C", status: PlayingStatus.hearing),
          _ => _waiting()
        });
        increaseInTurnCounter();
      }
    });
  }

  GameState _waiting() {
    final state = this.state;
    if (state is GameStatePlaying) {
      return state.copyWith(status: PlayingStatus.waiting);
    }
    return state;
  }

  void endGame(bool success) {
    _timer?.cancel();
    _audioRecognitionStream.stopMusicListening();
    _inTurnCounter = 0;
    emit(GameStateFinished(
        status: success ? FinishedStatus.success : FinishedStatus.failure));
  }

  final _notePerTurn = {
    10: C4,
    12: D4,
    14: E4,
    16: F4,
    18: E4,
    20: F4,
    22: E4,
    26: F4,
    30: E4,
    34: C4,
  };

  GameState? discriminate() {
    final int turn = _inTurnCounter;
    final double? lastPlayedFrequency =
        _audioRecognitionStream.pitchSubject?.lastEventOrNull?.dataValueOrNull;

    print(
        "Discriminating... turn: $turn, lastPlayedFrequency: $lastPlayedFrequency");

    if (lastPlayedFrequency == null) {
      return null;
    }

    final note = _notePerTurn[turn];

    if (note == null) {
      return null;
    }

    print(
        "Discriminating... note: $note, lastPlayedFrequency: $lastPlayedFrequency, noteIsInRange: ${note.isInRange(lastPlayedFrequency)}");

    return note.isInRange(lastPlayedFrequency)
        ? GameStatePlaying(
            text: note.noteName,
            status: PlayingStatus.correct,
          )
        : GameStatePlaying(
            text: note.noteName,
            status: PlayingStatus.wronged,
          );
  }

  void increaseInTurnCounter() {
    _inTurnCounter++;
    if (_inTurnCounter == 37) {
      endGame(true);
    }
  }

  @override
  Future<void> close() async {
    super.close();
    _timer?.cancel();
    _audioRecognitionStream.stopMusicListening();
  }
}
