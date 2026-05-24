import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/game_state_provider.dart';
import '../services/websocket_service.dart';
import 'dashboard_page.dart';

class PairPage extends ConsumerStatefulWidget {
  const PairPage({super.key});

  @override
  ConsumerState<PairPage> createState() => _PairPageState();
}

class _PairPageState extends ConsumerState<PairPage> {
  final _ipCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _ws = VantaWebSocketService();

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  Future<void> _prefill() async {
    final saved = await _ws.loadPairing();
    _ipCtrl.text = saved['ip'] ?? '';
    _codeCtrl.text = saved['code'] ?? '';
    if (mounted) setState(() {});
  }

  Future<void> _connect() async {
    final ip = _ipCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    await _ws.savePairing(ip, code);

    await _ws.connect(
      ip: ip,
      code: code,
      onStatus: (status) => ref.read(gameStateProvider.notifier).setStatus(status),
      onTelemetry: (packet, pingMs) => ref.read(gameStateProvider.notifier).updateFromPacket(packet, pingMs),
    );

    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => DashboardPage(ws: _ws, ip: ip)));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Pair with VANTA LIVE')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ipCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Windows IP', hintText: '192.168.1.20'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Pairing Code', hintText: '4-digit code'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _connect, child: const Text('Connect')),
            ),
            const SizedBox(height: 12),
            Text('Status: ${state.connectionStatus}'),
          ],
        ),
      ),
    );
  }
}
