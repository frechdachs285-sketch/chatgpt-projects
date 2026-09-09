import 'package:flutter_test/flutter_test.dart';
import 'package:schnittmuster_app/trouser_size_rules.dart';

void main() {
  test('size 6-8 rules', () {
    for (final size in [6, 8]) {
      final rules = TrouserSizeRules.forSizeCode(size);
      expect(rules.frontCrotchGuideCm, 2.75);
      expect(rules.backCrotchGuideCm, 4.0);
      expect(rules.kneeOuterIncrementCm, 1.3);
    }
  });

  test('size 10-14 rules', () {
    for (final size in [10, 12, 14]) {
      final rules = TrouserSizeRules.forSizeCode(size);
      expect(rules.frontCrotchGuideCm, 3.0);
      expect(rules.backCrotchGuideCm, 4.25);
      expect(rules.kneeOuterIncrementCm, 1.3);
    }
  });

  test('size 16-20 rules', () {
    for (final size in [16, 18, 20]) {
      final rules = TrouserSizeRules.forSizeCode(size);
      expect(rules.frontCrotchGuideCm, 3.25);
      expect(rules.backCrotchGuideCm, 4.5);
      expect(rules.kneeOuterIncrementCm, 1.5);
    }
  });

  test('size 22-24 rules', () {
    for (final size in [22, 24]) {
      final rules = TrouserSizeRules.forSizeCode(size);
      expect(rules.frontCrotchGuideCm, 3.5);
      expect(rules.backCrotchGuideCm, 4.75);
      expect(rules.kneeOuterIncrementCm, 1.7);
    }
  });

  test('unsupported sizes stay blocked', () {
    expect(() => TrouserSizeRules.forSizeCode(4), throwsArgumentError);
    expect(() => TrouserSizeRules.forSizeCode(26), throwsArgumentError);
  });
}
