import 'package:flutter_test/flutter_test.dart';
import 'package:vastusign/src/features/analysis/data/starter_rule_repository.dart';

void main() {
  const rules = StarterRuleRepository();

  test('maps intermediate compass sectors to broad directions', () {
    expect(rules.evaluate('kitchen', 'ESE').score, 86);
    expect(rules.evaluate('master_bedroom', 'SSW').score, 86);
    expect(rules.evaluate('pooja_room', 'NNE').score, 86);
  });

  test('keeps rule results explainable and actionable', () {
    final result = rules.evaluate('toilet', 'NE');

    expect(result.score, 28);
    expect(result.explanation, contains('toilet'));
    expect(result.effects, isNotEmpty);
    expect(result.remedies, isNotEmpty);
  });

  test('publishes a stable rule version', () {
    expect(StarterRuleRepository.version, 'starter-rules-2026.09');
  });
}
