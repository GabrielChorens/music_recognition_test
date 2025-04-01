// import 'dart:ui';
//
// import 'package:simple_sheet_music/simple_sheet_music.dart';
//
// List<Measure> score(int selectedIndex, bool wronged) => [
//       Measure([
//         Clef(ClefType.treble),
//         KeySignature(KeySignatureType.cMajor),
//         Note(Pitch.c4,
//             color: getColor(0, selectedIndex, wronged),
//             noteDuration: NoteDuration.quarter),
//         Note(Pitch.d4,
//             color: getColor(1, selectedIndex, wronged),
//             noteDuration: NoteDuration.quarter),
//         Note(Pitch.e4,
//             color: getColor(2, selectedIndex, wronged),
//             noteDuration: NoteDuration.quarter),
//         Note(Pitch.f4,
//             color: getColor(3, selectedIndex, wronged),
//             noteDuration: NoteDuration.quarter),
//
//       ]),
//       Measure([
//         Note(Pitch.e4,
//             color: getColor(4, selectedIndex, wronged),
//             noteDuration: NoteDuration.quarter),
//         Note(Pitch.f4,
//             color: getColor(5, selectedIndex, wronged),
//             noteDuration: NoteDuration.quarter),
//         Note(Pitch.e4,
//             color: getColor(6, selectedIndex, wronged),
//             noteDuration: NoteDuration.half),
//       ]),
//       Measure([
//         Note(Pitch.f4,
//             color: getColor(7, selectedIndex, wronged),
//             noteDuration: NoteDuration.half),
//         Note(Pitch.e4,
//             color: getColor(8, selectedIndex, wronged),
//             noteDuration: NoteDuration.half),
//       ]),
//       Measure([
//         Note(Pitch.c4,
//             color: getColor(9, selectedIndex, wronged),
//             noteDuration: NoteDuration.whole),
//       ])
//     ];
//
// Color getColor(int noteIndex, int selectedIndex, bool wronged) {
//   if (noteIndex < selectedIndex) {
//     return const Color.fromARGB(255, 0, 255, 0);
//   }
//   if (noteIndex == selectedIndex) {
//     if (wronged) {
//       return const Color.fromARGB(255, 255, 0, 0);
//     } else {
//       return const Color.fromARGB(255, 0, 0, 255);
//     }
//   }
//   return const Color.fromARGB(255, 0, 0, 0);
// }

import 'package:music_notes/graphics/render-functions/staff.dart';
import 'package:music_notes/musicXML/data.dart';

final x = Score([
  Part([
    Measure([
      Attributes(1, MusicalKey(0, null), 0, [Clef(1, Clefs.G)], Time(4, 4)),
      quarterNote(BaseTones.C),
      quarterNote(BaseTones.D),
      quarterNote(BaseTones.E),
      quarterNote(BaseTones.F),
    ]),
    Measure([
      quarterNote(BaseTones.E),
      quarterNote(BaseTones.F),
      halfNote(BaseTones.E),
    ]),
    Measure([
      halfNote(BaseTones.F),
      halfNote(BaseTones.E),
    ]),
    Measure([wholeNote(BaseTones.C), Barline(BarLineTypes.repeatLeft)]),
  ])
]);

PitchNote quarterNote(BaseTones baseTone) {
  return _parser(baseTone, NoteLength.quarter);
}

PitchNote halfNote(BaseTones baseTone) {
  return _parser(baseTone, NoteLength.half);
}

PitchNote wholeNote(BaseTones baseTone) {
  return _parser(baseTone, NoteLength.whole);
}

PitchNote _parser(BaseTones baseTone, NoteLength noteLength) {
  return PitchNote(
      1,
      1,
      1,
      [],
      Pitch(
        baseTone,
        2,
      ),
      noteLength,
      StemValue.up,
      []);
}
