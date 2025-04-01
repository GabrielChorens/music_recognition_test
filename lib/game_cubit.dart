import 'dart:async';
import 'dart:typed_data';

import 'package:buffered_list_stream/buffered_list_stream.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:record/record.dart';

import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameStateInitial()) {
    startMusicListening();
  }

  int _inTurnCounter = 0;
  Timer? _timer;

  final AudioRecorder _audioRecorder = AudioRecorder();
  final PitchDetector _pitchDetectorDart = PitchDetector();

  void startGame() {
    _inTurnCounter = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
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
        22 => GameStatePlaying(text: "E", status: PlayingStatus.hearing),
        23 => GameStatePlaying(text: "", status: PlayingStatus.waiting),
        25 => GameStatePlaying(text: "F", status: PlayingStatus.hearing),
        26 => GameStatePlaying(text: "F", status: PlayingStatus.hearing),
        27 => GameStatePlaying(text: "", status: PlayingStatus.waiting),
        29 => GameStatePlaying(text: "E", status: PlayingStatus.hearing),
        30 => GameStatePlaying(text: "E", status: PlayingStatus.hearing),
        31 => GameStatePlaying(text: "", status: PlayingStatus.waiting),
        33 => GameStatePlaying(text: "C", status: PlayingStatus.hearing),
        34 => GameStatePlaying(text: "C", status: PlayingStatus.hearing),
        _ => _waiting()
      });
      increaseInTurnCounter();
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
    _inTurnCounter = 0;
    emit(GameStateFinished(
        status: success ? FinishedStatus.success : FinishedStatus.failure));
  }

  void startMusicListening() async {
    final recordStream = await _audioRecorder.startStream(const RecordConfig(
      encoder: AudioEncoder.pcm16bits,
      numChannels: 1,
      bitRate: 128000,
      sampleRate: PitchDetector.DEFAULT_SAMPLE_RATE,
    ));

    var audioSampleBufferedStream = bufferedListStream(
      recordStream.map((event) {
        return event.toList();
      }),
      //The library converts a PCM16 to 8bits internally. So we need twice as many bytes
      PitchDetector.DEFAULT_BUFFER_SIZE * 2,
    );

    await for (var audioSample in audioSampleBufferedStream) {
      final intBuffer = Uint8List.fromList(audioSample);

      _pitchDetectorDart.getPitchFromIntBuffer(intBuffer).then((detectedPitch) {
        final state = this.state;
        if (detectedPitch.pitched &&
            detectedPitch.pitch > 250 &&
            detectedPitch.pitch < 500) {
          print("Detected pitch: ${detectedPitch.pitch}");
          if (state is GameStatePlaying) {
            if (state.status == PlayingStatus.hearing) {
              if (acceptanceHandler(state.text, detectedPitch.pitch)) {
                emit(state.copyWith(status: PlayingStatus.correct));
              } else {
                print(
                    "Going to end the game state: ${state}, pitch: ${detectedPitch.pitch} acceptanceHandler: ${acceptanceHandler(state.text, detectedPitch.pitch)}");
                endGame(false);
              }
            } else if (state.text.isEmpty) {
              emit(state.copyWith(status: PlayingStatus.wronged));
            }
          }
        }
      });
    }
  }

  bool acceptanceHandler(String note, double frequency) {
    return switch (note) {
      "C" => frequency > 258 && frequency < 265, // C4
      "D" => frequency > 288 && frequency < 302, // D4
      "E" => frequency > 325 && frequency < 334, // E4
      "F" => frequency > 345 && frequency < 356, // F4
      _ => false,
    };
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
    await _audioRecorder.stop();
  }
}
