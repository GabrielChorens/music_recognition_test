// import 'dart:math';
// import 'dart:typed_data';
// import 'package:fftea/fftea.dart';
//
// // Convert a Uint8List of audio data into a list of PCM 16-bit samples
// List<double> decodePCM16(Uint8List audioData) {
//   List<double> pcmSamples = [];
//   for (int i = 0; i < audioData.length; i += 2) {
//     int sample = audioData[i] | (audioData[i + 1] << 8);
//     if (sample >= 0x8000) {
//       sample -= 0x10000; // Convert from unsigned to signed
//     }
//     pcmSamples.add(sample.toDouble());
//   }
//   return pcmSamples;
// }
//
// // Apply a Hamming window to the PCM samples
// List<double> applyHammingWindow(List<double> samples) {
//   int N = samples.length;
//   List<double> windowedSamples = List<double>.filled(N, 0.0);
//   for (int n = 0; n < N; n++) {
//     windowedSamples[n] = samples[n] * (0.54 - 0.46 * cos(2 * pi * n / (N - 1)));
//   }
//   return windowedSamples;
// }
//
// // Pad the input data to the next power of 2
// List<double> padToPowerOfTwo(List<double> data) {
//   int length = data.length;
//   int nextPowerOfTwo = pow(2, (log(length) / log(2)).ceil()).toInt();
//   return List<double>.from(data)
//     ..addAll(List<double>.filled(nextPowerOfTwo - length, 0.0));
// }
//
// // Calculate the magnitude (sqrt(real^2 + imag^2))
// double decodeFloat64x2ToDouble(Float64x2 complex) {
//   return sqrt((complex.x * complex.x + complex.y * complex.y));
// }
//
// // Detect if a note is present
// bool detectNote(Uint8List audioData, double targetFrequency, double threshold) {
//   // Decode PCM
//   List<double> pcmSamples = decodePCM16(audioData);
//
//   // Apply Hamming window
//   List<double> windowedSamples = applyHammingWindow(pcmSamples);
//
//   // Pad the PCM data to the next power of 2
//   List<double> paddedData = padToPowerOfTwo(windowedSamples);
//
//   // Create FFT object with the appropriate size
//   FFT fft = FFT(paddedData.length);
//
//   // Calculate FFT
//   Float64x2List spectrum = fft.realFft(paddedData);
//
//   // Find the target frequency in the spectrum
//   int sampleRate = 16000; // Sampling rate
//   int targetIndex = (targetFrequency / sampleRate * paddedData.length).round();
//
//   // Ensure the target index is within the spectrum range
//   if (targetIndex < 0 || targetIndex >= spectrum.length) {
//     print("Target index out of range");
//     return false;
//   }
//
//   final Float64x2 frequency = spectrum[targetIndex];
//
//   // Calculate the magnitude of the frequency component
//   final double doubleFrequency = decodeFloat64x2ToDouble(frequency);
//
//   // Print the detected frequency magnitude
//   print('Detected Frequency Magnitude: $doubleFrequency');
//
//   return (doubleFrequency > threshold);
// }