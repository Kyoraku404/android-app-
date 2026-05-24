import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/coach_card.dart';

class GameState {
  final int kills;
  final int deaths;
  final int assists;
  final double headshotPct;
  final int aimScore;
  final int tiltLevel;
  final int fps;
  final int pingMs;
  final String connectionStatus;
  final List<CoachCard> coachCards;

  const GameState({
    this.kills = 0,
    this.deaths = 0,
    this.assists = 0,
    this.headshotPct = 0,
    this.aimScore = 0,
    this.tiltLevel = 0,
    this.fps = 0,
    this.pingMs = 0,
    this.connectionStatus = 'Disconnected',
    this.coachCards = const [],
  });

  GameState copyWith({
    int? kills,
    int? deaths,
    int? assists,
    double? headshotPct,
    int? aimScore,
    int? tiltLevel,
    int? fps,
    int? pingMs,
    String? connectionStatus,
    List<CoachCard>? coachCards,
  }) {
    return GameState(
      kills: kills ?? this.kills,
      deaths: deaths ?? this.deaths,
      assists: assists ?? this.assists,
      headshotPct: headshotPct ?? this.headshotPct,
      aimScore: aimScore ?? this.aimScore,
      tiltLevel: tiltLevel ?? this.tiltLevel,
      fps: fps ?? this.fps,
      pingMs: pingMs ?? this.pingMs,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      coachCards: coachCards ?? this.coachCards,
    );
  }
}

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier() : super(const GameState());

  void setStatus(String status) => state = state.copyWith(connectionStatus: status);

  void updateFromPacket(Map<String, dynamic> packet, int pingMs) {
    final payload = (packet['payload'] as Map<String, dynamic>? ?? <String, dynamic>{});
    final cardsRaw = payload['coach_cards'] as List<dynamic>? ?? [];
    state = state.copyWith(
      kills: (payload['kills'] ?? 0) as int,
      deaths: (payload['deaths'] ?? 0) as int,
      assists: (payload['assists'] ?? 0) as int,
      headshotPct: ((payload['headshot_pct'] ?? 0) as num).toDouble(),
      aimScore: (payload['aim_score'] ?? 0) as int,
      tiltLevel: (payload['tilt_level'] ?? 0) as int,
      fps: (payload['fps'] ?? 0) as int,
      pingMs: pingMs,
      connectionStatus: 'Connected',
      coachCards: cardsRaw
          .map((e) => CoachCard.fromJson((e as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>(
  (ref) => GameStateNotifier(),
);
