import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/treasury_repository.dart';
import '../../data/datasources/supabase_client.dart';
import '../../data/models/treasury_summary.dart';
import '../../core/network/lkgc_cache.dart';

part 'treasury_provider.g.dart';

// Provider for the repository
@riverpod
TreasuryRepository treasuryRepository(TreasuryRepositoryRef ref) {
  return TreasuryRepository(supabase);
}

@riverpod
Future<TreasurySummary> treasurySummary(TreasurySummaryRef ref) async {
  final repository = ref.watch(treasuryRepositoryProvider);

  try {
    final summary = await repository.getSummary();

    // Write new result to LKGC Cache
    await LkgcCache.put<TreasurySummary>('treasury_summary', summary);
    return summary;
  } catch (e) {
    // LAW-09: Offline Resilience
    final cachedSummary = LkgcCache.get<TreasurySummary>(
      'treasury_summary',
      (json) => TreasurySummary.fromJson(json)
    );

    if (cachedSummary != null) {
      return cachedSummary;
    }

    rethrow;
  }
}
