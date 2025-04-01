sealed class GameState {
  const GameState();
}

class GameStateInitial extends GameState {
  const GameStateInitial();

  @override
  String toString() => 'GameStateInitial';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateInitial && runtimeType == other.runtimeType;
  @override
  int get hashCode => runtimeType.hashCode;
}

enum PlayingStatus {
  standBy,
  hearing,
  waiting,
  wronged,
  correct,
}

class GameStatePlaying extends GameState {
  final String text;
  final PlayingStatus status;

  const GameStatePlaying({
    required this.text,
    required this.status,
  });

  @override
  String toString() => 'GameStatePlaying { text: $text, status: $status }';

  GameStatePlaying copyWith({
    String? text,
    PlayingStatus? status,
  }) {
    return GameStatePlaying(
      text: text ?? this.text,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStatePlaying &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          status == other.status;

  @override
  int get hashCode => text.hashCode ^ status.hashCode;
}

enum FinishedStatus {
  success,
  failure,
}

class GameStateFinished extends GameState {
  final FinishedStatus status;

  const GameStateFinished({
    required this.status,
  });

  @override
  String toString() => 'GameStateFinished { status: $status }';
}
