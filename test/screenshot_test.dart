import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
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

Future<ThemeData> loadScreenshotTheme() async {
  const regularFontPath =
      '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf';
  const boldFontPath =
      '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf';

  Future<ByteData> fontBytes(String path) {
    final bytes = File(path).readAsBytesSync();
    return Future<ByteData>.value(ByteData.sublistView(bytes));
  }

  final textFontLoader = FontLoader('VastuScreenshotSans')
    ..addFont(fontBytes(regularFontPath))
    ..addFont(fontBytes(boldFontPath));
  await textFontLoader.load().timeout(const Duration(seconds: 15));

  // Material icons are present in the test asset bundle, but widget tests do
  // not load them automatically. Loading them here avoids tofu squares in the
  // generated screenshots.
  String? materialIconsPath =
      Platform.environment['VASTUSIGN_MATERIAL_ICONS_FONT'];
  var searchDirectory = File(Platform.resolvedExecutable).parent;
  for (var index = 0;
      (materialIconsPath == null || materialIconsPath.isEmpty) && index < 8;
      index += 1) {
    final candidate = File(
      '${searchDirectory.path}/bin/cache/artifacts/material_fonts/'
      'MaterialIcons-Regular.otf',
    );
    if (candidate.existsSync()) {
      materialIconsPath = candidate.path;
      break;
    }
    searchDirectory = searchDirectory.parent;
  }
  if (materialIconsPath == null || materialIconsPath.isEmpty) {
    throw StateError('VASTUSIGN_MATERIAL_ICONS_FONT is not configured.');
  }
  final iconFontLoader = FontLoader('MaterialIcons')
    ..addFont(fontBytes(materialIconsPath));
  await iconFontLoader.load().timeout(const Duration(seconds: 15));

  final base = AppTheme.light;
  return base.copyWith(
    textTheme: base.textTheme.apply(fontFamily: 'VastuScreenshotSans'),
    primaryTextTheme:
        base.primaryTextTheme.apply(fontFamily: 'VastuScreenshotSans'),
  );
}

Widget screenshotApp(Widget child, ThemeData theme) {
  return ProviderScope(
    overrides: [
      analysisControllerProvider.overrideWith(
        ScreenshotAnalysisController.new,
      ),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
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

    final screenshotTheme = await loadScreenshotTheme();

    await tester.pumpWidget(
      screenshotApp(const OnboardingPage(), screenshotTheme),
    );
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

    await tester.pumpWidget(screenshotApp(const HomePage(), screenshotTheme));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/04-home.png'),
    );

    await tester.pumpWidget(
      screenshotApp(const CategoryPage(), screenshotTheme),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/05-categories.png'),
    );
  });
}
