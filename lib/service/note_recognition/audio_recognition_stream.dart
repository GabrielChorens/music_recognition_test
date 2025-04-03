import 'package:buffered_list_stream/buffered_list_stream.dart';
import 'package:flutter/foundation.dart';
import 'package:pitch_detector_dart/pitch_detector.dart';
import 'package:pitch_detector_dart/pitch_detector_result.dart';
import 'package:record/record.dart';
import 'package:rxdart/rxdart.dart';

class AudioRecognitionStream {
  final AudioRecorder _audioRecorder = AudioRecorder();

  BehaviorSubject<double> pitchSubject = BehaviorSubject<double>.seeded(
    0,
  );

  void startMusicListening() async {
    pitchSubject = BehaviorSubject<double>.seeded(
      0,
    );

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
      PitchDetector.DEFAULT_BUFFER_SIZE * 2,
    );

    await for (var audioSample in audioSampleBufferedStream) {
      final intBuffer = Uint8List.fromList(audioSample);

      final detectedPitch = await _processAudioSample(intBuffer);

      if (detectedPitch.pitched &&
          detectedPitch.pitch > 250 &&
          detectedPitch.pitch < 500) {
        // print("Detected pitch: ${detectedPitch.pitch}");
        pitchSubject.add(detectedPitch.pitch);
      }
    }
  }

  void stopMusicListening() {
    _audioRecorder.stop();
  }
}

Future<PitchDetectorResult> _processAudioSample(Uint8List intBuffer) async {
  return await PitchDetector().getPitchFromIntBuffer(intBuffer);
}
