class Note {
  final double lowerBoundFrequency;
  final double upperBoundFrequency;

  final String noteName;

  const Note({
    required this.lowerBoundFrequency,
    required this.upperBoundFrequency,
    required this.noteName,
  });

  bool isInRange(double frequency) {
    return frequency >= lowerBoundFrequency && frequency <= upperBoundFrequency;
  }

  @override
  String toString() {
    return noteName;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Note &&
        other.lowerBoundFrequency == lowerBoundFrequency &&
        other.upperBoundFrequency == upperBoundFrequency &&
        other.noteName == noteName;
  }

  @override
  int get hashCode {
    return lowerBoundFrequency.hashCode ^
        upperBoundFrequency.hashCode ^
        noteName.hashCode;
  }
}
