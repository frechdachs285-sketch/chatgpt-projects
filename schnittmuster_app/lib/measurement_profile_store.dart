import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'pattern_models.dart';

class MeasurementProfile {
  final String name;
  final Measurements measurements;

  const MeasurementProfile({required this.name, required this.measurements});

  Map<String, dynamic> toJson() => {
        'name': name,
        'waist': measurements.waist,
        'hip': measurements.hip,
        'hipDepth': measurements.hipDepth,
        'skirtLength': measurements.skirtLength,
      };

  factory MeasurementProfile.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num).toDouble();
    return MeasurementProfile(
      name: json['name'] as String,
      measurements: Measurements(
        waist: number('waist'),
        hip: number('hip'),
        hipDepth: number('hipDepth'),
        skirtLength: number('skirtLength'),
      ),
    );
  }
}

class MeasurementProfileStore {
  static const _storageKey = 'measurement_profiles_v1';

  Future<List<MeasurementProfile>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((item) => MeasurementProfile.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<MeasurementProfile> profiles) async {
    final preferences = await SharedPreferences.getInstance();
    final raw = jsonEncode(profiles.map((profile) => profile.toJson()).toList());
    await preferences.setString(_storageKey, raw);
  }

  Future<List<MeasurementProfile>> upsert(MeasurementProfile profile) async {
    final profiles = [...await load()];
    final index = profiles.indexWhere(
      (existing) => existing.name.toLowerCase() == profile.name.toLowerCase(),
    );
    if (index >= 0) {
      profiles[index] = profile;
    } else {
      profiles.add(profile);
    }
    await save(profiles);
    return profiles;
  }

  Future<List<MeasurementProfile>> delete(String name) async {
    final profiles = [...await load()]
      ..removeWhere((profile) => profile.name == name);
    await save(profiles);
    return profiles;
  }
}
