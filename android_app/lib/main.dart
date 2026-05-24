import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/pair_page.dart';
import 'theme/vanta_theme.dart';

void main() {
  runApp(const ProviderScope(child: VantaApp()));
}

class VantaApp extends StatelessWidget {
  const VantaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VANTA LIVE',
      debugShowCheckedModeBanner: false,
      theme: VantaTheme.theme,
      home: const PairPage(),
    );
  }
}
