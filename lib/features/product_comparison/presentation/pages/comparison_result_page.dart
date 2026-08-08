import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComparisonResultPage extends ConsumerStatefulWidget {
  const ComparisonResultPage({super.key});

  @override
  ConsumerState<ComparisonResultPage> createState() => _ComparisonResultPageState();
}

class _ComparisonResultPageState extends ConsumerState<ComparisonResultPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Comparison Dashboard')),
    );
  }
}
