class VastuRuleResult {
  const VastuRuleResult({
    required this.score,
    required this.effects,
    required this.remedies,
    required this.explanation,
  });

  final int score;
  final List<String> effects;
  final List<String> remedies;
  final String explanation;
}
