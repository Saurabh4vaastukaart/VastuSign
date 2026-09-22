import 'package:flutter_test/flutter_test.dart';
import 'package:vastusign/src/features/analysis/domain/direction_engine.dart';
import 'package:vastusign/src/features/analysis/domain/vastu_category.dart';

void main() {
  group('DirectionEngine.normalize', () {
    test('normalizes negative and wrapped angles', () {
      expect(DirectionEngine.normalize(-10), 350);
      expect(DirectionEngine.normalize(360), 0);
      expect(DirectionEngine.normalize(725), 5);
    });
  });

  group('16-direction classification', () {
    test('uses half-open boundaries around north', () {
      expect(DirectionEngine.classify16(0).label, 'N');
      expect(DirectionEngine.classify16(11.249).label, 'N');
      expect(DirectionEngine.classify16(11.25).label, 'NNE');
      expect(DirectionEngine.classify16(348.75).label, 'N');
    });

    test('classifies sample report angles consistently', () {
      expect(DirectionEngine.classify16(146.25).label, 'SSE');
      expect(DirectionEngine.classify16(236.25).label, 'WSW');
      expect(DirectionEngine.classify16(303.75).label, 'NW');
      expect(DirectionEngine.classify16(78.75).label, 'E');
    });
  });

  group('32-pada entrance classification', () {
    test('maps the sample S7 interval exactly', () {
      final start = DirectionEngine.classify(
        202.5,
        DirectionScheme.entrance32,
      );
      final inside = DirectionEngine.classifyEntrance32(213.749);
      final next = DirectionEngine.classifyEntrance32(213.75);

      expect(start.label, 'S7');
      expect(start.startAngle, 202.5);
      expect(start.endAngle, 213.75);
      expect(inside.label, 'S7');
      expect(next.label, 'S8');
    });

    test('maps north padas across zero degrees', () {
      expect(DirectionEngine.classifyEntrance32(348.75).label, 'N4');
      expect(DirectionEngine.classifyEntrance32(0).label, 'N5');
      expect(DirectionEngine.classifyEntrance32(33.75).label, 'N8');
    });
  });

  test('flags readings whose accuracy overlaps a boundary', () {
    final sector = DirectionEngine.classify16(146.4);
    expect(sector.isBoundaryUncertain(2.8), isTrue);
    expect(DirectionEngine.classify16(157.5).isBoundaryUncertain(2.8), isFalse);
  });
}

