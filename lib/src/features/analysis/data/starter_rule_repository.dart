import '../domain/vastu_rule.dart';

/// Original starter rules for a testable first release.
///
/// They are deliberately isolated from the UI so a qualified Vastu expert can
/// replace or revise them without changing app screens or persisted reports.
class StarterRuleRepository {
  const StarterRuleRepository();

  static const version = 'starter-rules-2026.09';

  VastuRuleResult evaluate(String categoryId, String direction) {
    final broad = _toEightDirections(direction);
    final preference = _preferences[categoryId] ?? _defaultPreference;
    final score = preference.good.contains(broad)
        ? 86
        : preference.balanced.contains(broad)
            ? 68
            : preference.attention.contains(broad)
                ? 48
                : 28;

    final label = _categoryLabels[categoryId] ?? 'This area';
    final status = score >= 75
        ? 'supportive'
        : score >= 60
            ? 'generally balanced'
            : score >= 40
                ? 'worth reviewing'
                : 'a priority for expert review';

    return VastuRuleResult(
      score: score,
      explanation: '$label in $broad is $status under the starter rule set.',
      effects: [
        score >= 75
            ? 'This placement is traditionally considered supportive for the intended use of the space.'
            : 'This placement may not fully support the intended use of the space.',
        'The result depends on measurement accuracy, the property centre, and the complete floor layout.',
      ],
      remedies: [
        'Keep the area clean, bright, ventilated, and free from unnecessary clutter.',
        if (score < 60)
          'Confirm the reading and consult a qualified professional before making structural changes.'
        else
          'Maintain the current placement and recheck after major layout changes.',
      ],
    );
  }

  String _toEightDirections(String direction) {
    const map = <String, String>{
      'N': 'N', 'NNE': 'NE', 'NE': 'NE', 'ENE': 'E',
      'E': 'E', 'ESE': 'SE', 'SE': 'SE', 'SSE': 'S',
      'S': 'S', 'SSW': 'SW', 'SW': 'SW', 'WSW': 'W',
      'W': 'W', 'WNW': 'NW', 'NW': 'NW', 'NNW': 'N',
    };
    return map[direction] ?? direction;
  }
}

class _Preference {
  const _Preference({
    this.good = const {},
    this.balanced = const {},
    this.attention = const {},
  });

  final Set<String> good;
  final Set<String> balanced;
  final Set<String> attention;
}

const _defaultPreference = _Preference(
  good: {'N', 'NE', 'E'},
  balanced: {'NW', 'SE'},
  attention: {'W', 'S'},
);

const _preferences = <String, _Preference>{
  'main_entrance': _Preference(good: {'N', 'NE', 'E'}, balanced: {'NW'}, attention: {'SE', 'W'}),
  'kitchen': _Preference(good: {'SE'}, balanced: {'NW', 'E'}, attention: {'S', 'W'}),
  'master_bedroom': _Preference(good: {'SW'}, balanced: {'S', 'W'}, attention: {'NW'}),
  'bedroom': _Preference(good: {'SW', 'S', 'W'}, balanced: {'NW', 'E'}, attention: {'N'}),
  'toilet': _Preference(good: {'NW', 'W'}, balanced: {'S', 'SE'}, attention: {'N', 'E'}),
  'pooja_room': _Preference(good: {'NE', 'N', 'E'}, balanced: {'NW'}, attention: {'SE', 'W'}),
  'drawing_room': _Preference(good: {'N', 'NE', 'E'}, balanced: {'NW'}, attention: {'SE', 'S'}),
  'dining_room': _Preference(good: {'W', 'NW'}, balanced: {'E', 'N'}, attention: {'S'}),
  'study_room': _Preference(good: {'NE', 'E', 'N'}, balanced: {'NW'}, attention: {'W', 'S'}),
  'guest_room': _Preference(good: {'NW'}, balanced: {'N', 'W'}, attention: {'SE'}),
  'staircase': _Preference(good: {'S', 'SW', 'W'}, balanced: {'SE'}, attention: {'N', 'E'}),
  'office': _Preference(good: {'N', 'E', 'NE'}, balanced: {'NW', 'W'}, attention: {'S'}),
  'balcony': _Preference(good: {'N', 'NE', 'E'}, balanced: {'NW'}, attention: {'S', 'SW'}),
  'washing_area': _Preference(good: {'NW', 'W'}, balanced: {'SE'}, attention: {'NE'}),
  'underground_tank': _Preference(good: {'NE', 'N'}, balanced: {'E'}, attention: {'NW'}),
  'overhead_tank': _Preference(good: {'SW', 'W'}, balanced: {'S'}, attention: {'N', 'NE'}),
  'septic_tank': _Preference(good: {'NW', 'W'}, balanced: {'S'}, attention: {'E'}),
  'electrical': _Preference(good: {'SE'}, balanced: {'S'}, attention: {'N', 'NE'}),
  'store_room': _Preference(good: {'SW', 'W'}, balanced: {'S'}, attention: {'N', 'NE'}),
};

const _categoryLabels = <String, String>{
  'main_entrance': 'The main entrance',
  'kitchen': 'The kitchen',
  'master_bedroom': 'The master bedroom',
  'bedroom': 'The bedroom',
  'toilet': 'The toilet',
  'pooja_room': 'The pooja room',
  'drawing_room': 'The drawing room',
  'dining_room': 'The dining room',
  'study_room': 'The study room',
  'guest_room': 'The guest room',
  'staircase': 'The staircase',
  'office': 'The home office',
  'balcony': 'The balcony',
  'washing_area': 'The washing area',
  'underground_tank': 'The underground tank',
  'overhead_tank': 'The overhead tank',
  'septic_tank': 'The septic tank',
  'electrical': 'The electrical zone',
  'store_room': 'The store room',
};
