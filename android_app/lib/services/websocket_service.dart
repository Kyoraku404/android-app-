import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VantaWebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  int _lastPingAt = 0;

  Future<void> savePairing(String ip, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vanta_ip', ip);
    await prefs.setString('vanta_code', code);
  }

  Future<Map<String, String>> loadPairing() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'ip': prefs.getString('vanta_ip') ?? '',
      'code': prefs.getString('vanta_code') ?? '',
    };
  }

  Future<void> connect({
    required String ip,
    required String code,
    required void Function(Map<String, dynamic> packet, int pingMs) onTelemetry,
    required void Function(String status) onStatus,
  }) async {
    onStatus('Connecting...');
    await _subscription?.cancel();
    await _channel?.sink.close();

    _channel = WebSocketChannel.connect(Uri.parse('ws://$ip:8000/ws?code=$code'));
    onStatus('Connected');
    _lastPingAt = DateTime.now().millisecondsSinceEpoch;
    _channel!.sink.add(jsonEncode({'type': 'ping', 'ts': _lastPingAt}));

    _subscription = _channel!.stream.listen(
      (event) {
        final parsed = jsonDecode(event as String) as Map<String, dynamic>;
        final now = DateTime.now().millisecondsSinceEpoch;
        final pingMs = now - _lastPingAt;
        _lastPingAt = now;
        _channel?.sink.add(jsonEncode({'type': 'ping', 'ts': _lastPingAt}));
        onTelemetry(parsed, pingMs);
      },
      onError: (_) => onStatus('Connection error'),
      onDone: () => onStatus('Disconnected'),
    );
  }

  Future<bool> setSimulator(String ip, bool enabled) async {
    final endpoint = enabled ? 'start' : 'stop';
    final res = await http.post(Uri.parse('http://$ip:8000/simulator/$endpoint'));
    return res.statusCode == 200;
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _channel?.sink.close();
  }
}
