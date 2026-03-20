import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

class LkgcCache {
  static const String boxName = 'lkgc_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(boxName);
  }

  static Future<void> put<T>(String key, T value) async {
    final box = Hive.box<String>(boxName);
    // Assuming value has a toJson() method if it's a model
    final dynamic jsonMap = (value as dynamic).toJson();
    final jsonString = jsonEncode(jsonMap);
    await box.put(key, jsonString);
  }

  static T? get<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    final box = Hive.box<String>(boxName);
    final jsonString = box.get(key);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  // Box getter for tests or advanced usage
  static Box<String> get box => Hive.box<String>(boxName);
}
