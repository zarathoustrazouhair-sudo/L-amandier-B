import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:amandier_b_syndic/data/models/treasury_summary.dart';
import 'package:amandier_b_syndic/data/repositories/treasury_repository.dart';
import 'package:amandier_b_syndic/domain/providers/treasury_provider.dart';
import 'package:amandier_b_syndic/core/network/lkgc_cache.dart';

class MockFailingTreasuryRepository implements TreasuryRepository {
  @override
  Future<TreasurySummary> getSummary() async {
    throw const SocketException('Network is unreachable');
  }
}

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test_prov');
    Hive.init(tempDir.path);
    await Hive.openBox<String>(LkgcCache.boxName);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('Treasury Provider returns LKGC cache on network error (LAW-09)', () async {
    const cachedSummary = TreasurySummary(
      soldeTotal: 999.0,
      soldeCaisse: 0,
      soldeBanque: 999.0,
      totalEntrees: 999.0,
      totalSorties: 0,
      impayesCount: 0,
      impayesMontant: 0,
      tauxRecouvrement: 100,
      runwayMois: 1,
      runwayStatus: RunwayStatus.green,
    );

    // Pre-populate cache
    await LkgcCache.put<TreasurySummary>('treasury_summary', cachedSummary);

    final container = ProviderContainer(
      overrides: [
        treasuryRepositoryProvider.overrideWithValue(MockFailingTreasuryRepository()),
      ],
    );

    final result = await container.read(treasurySummaryProvider.future);

    expect(result.soldeTotal, 999.0);
    expect(result.runwayStatus, RunwayStatus.green);
  });
}
