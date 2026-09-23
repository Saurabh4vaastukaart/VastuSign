import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vastusign/src/core/theme/app_theme.dart';
import 'package:vastusign/src/features/analysis/application/analysis_controller.dart';
import 'package:vastusign/src/features/analysis/presentation/category_page.dart';
import 'package:vastusign/src/features/home/presentation/home_page.dart';
import 'package:vastusign/src/features/onboarding/presentation/onboarding_page.dart';

class ScreenshotAnalysisController extends AnalysisController {
  @override
  AnalysisState build() => const AnalysisState();
}

Widget screenshotApp(Widget child) {
  return ProviderScope(
    overrides: [
      analysisControllerProvider.overrideWith(
        ScreenshotAnalysisController.new,
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: child,
    ),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('capture representative VastuSign screens', (tester) async {
    // A modern 20:9 Android viewport (432 x 960 logical pixels at 3x).
    tester.view.physicalSize = const Size(1296, 2880);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(screenshotApp(const OnboardingPage()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/01-onboarding-compass.png'),
    );

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/02-onboarding-rooms.png'),
    );

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/03-onboarding-report.png'),
    );

    await tester.pumpWidget(screenshotApp(const HomePage()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/04-home.png'),
    );

    await tester.pumpWidget(screenshotApp(const CategoryPage()));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/05-categories.png'),
    );
  });
}
