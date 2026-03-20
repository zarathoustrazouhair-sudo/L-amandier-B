import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:amandier_b_syndic/data/models/treasury_summary.dart';
import 'package:amandier_b_syndic/core/network/lkgc_cache.dart';

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox<String>(LkgcCache.boxName);
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('LKGC Cache stores and retrieves TreasurySummary accurately', () async {
    const summary = TreasurySummary(
      soldeTotal: 15000.50,
      soldeCaisse: 5000.00,
      soldeBanque: 10000.50,
      totalEntrees: 25000.00,
      totalSorties: 10000.00,
      impayesCount: 2,
      impayesMontant: 500.00,
      tauxRecouvrement: 85.5,
      runwayMois: 4.5,
      runwayStatus: RunwayStatus.green,
    );

    await LkgcCache.put<TreasurySummary>('treasury_summary', summary);

    final retrieved = LkgcCache.get<TreasurySummary>(
      'treasury_summary',
      (json) => TreasurySummary.fromJson(json),
    );

    expect(retrieved, isNotNull);
    expect(retrieved?.soldeTotal, 15000.50);
    expect(retrieved?.runwayStatus, RunwayStatus.green);
  });
}
