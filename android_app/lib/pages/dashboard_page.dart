import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/coach_card.dart';
import '../providers/game_state_provider.dart';
import '../services/websocket_service.dart';

class DashboardPage extends ConsumerStatefulWidget {
  final VantaWebSocketService? ws;
  final String ip;

  const DashboardPage({super.key, this.ws, this.ip = ''});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  bool simulatorOn = true;

  Color _severityColor(String severity) {
    switch (severity) {
      case 'critical':
        return const Color(0xFFFF4655);
      case 'warning':
      case 'tactical':
        return Colors.orangeAccent;
      default:
        return const Color(0xFF00F5D4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('VANTA LIVE Dashboard')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0B0E14), Color(0xFF141A24)]),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Status: ${game.connectionStatus}  |  Ping: ${game.pingMs}ms  |  FPS: ${game.fps}'),
            const SizedBox(height: 8),
            Text('K/D/A: ${game.kills}/${game.deaths}/${game.assists}', style: const TextStyle(fontSize: 20)),
            Text('HS%: ${game.headshotPct.toStringAsFixed(1)} | Aim: ${game.aimScore} | Tilt: ${game.tiltLevel}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.ws == null || widget.ip.isEmpty
                  ? null
                  : () async {
                      simulatorOn = !simulatorOn;
                      await widget.ws!.setSimulator(widget.ip, simulatorOn);
                      if (mounted) setState(() {});
                    },
              child: Text(simulatorOn ? 'Stop Simulator' : 'Start Simulator'),
            ),
            const SizedBox(height: 16),
            const Text('Live Coaching Cards', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...game.coachCards.map((c) => _card(c)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _card(CoachCard card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _severityColor(card.severity), width: 1.2),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(card.title, style: TextStyle(color: _severityColor(card.severity), fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(card.message),
        ],
      ),
    );
  }
}
