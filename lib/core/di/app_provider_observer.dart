import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AppProviderObserver extends ProviderObserver {
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    developer.log(
      '[INFO] Provider added: ${context.provider.name ?? context.provider.runtimeType} | Value: $value',
      name: 'RIVERPOD',
    );
  }

  @override
  void didUpdateProvider(ProviderObserverContext context, Object? previousValue, Object? newValue) {
    developer.log(
      '[INFO] Provider updated: ${context.provider.name ?? context.provider.runtimeType} | New Value: $newValue',
      name: 'RIVERPOD',
    );
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    developer.log(
      '[INFO] Provider disposed: ${context.provider.name ?? context.provider.runtimeType}',
      name: 'RIVERPOD',
    );
  }
}
