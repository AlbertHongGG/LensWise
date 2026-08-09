import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lens_wise/core/router/app_router.dart';
import 'package:lens_wise/features/product_comparison/domain/models/comparison_result.dart';
import 'package:lens_wise/features/product_comparison/presentation/pages/comparison_result_args.dart';

class NavigationService {
  final GoRouter _router;

  NavigationService(this._router);

  void navigateToComparisonResult(ComparisonResult result, List<Uint8List> images) {
    final args = ComparisonResultArgs(result: result, rawImages: images);
    _router.pushReplacement('/result/comparison', extra: args);
  }
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService(ref.watch(routerProvider));
});
