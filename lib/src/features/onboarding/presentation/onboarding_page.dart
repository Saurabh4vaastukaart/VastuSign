import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  var _currentPage = 0;

  static const _items = <_OnboardingItem>[
    _OnboardingItem(
      eyebrow: 'MEASURE WITH CONFIDENCE',
      title: 'Your space, read in the right direction.',
      description:
          'A guided compass experience checks calibration, stability, and sector boundaries before saving a reading.',
      icon: Icons.explore_rounded,
      accent: AppColors.gold,
    ),
    _OnboardingItem(
      eyebrow: 'SELF-ANALYSIS MADE SIMPLE',
      title: 'Capture every room, one clear step at a time.',
      description:
          'Choose a utility, stand at the recommended point, hold steady, and build your property analysis.',
      icon: Icons.home_work_outlined,
      accent: AppColors.emerald,
    ),
    _OnboardingItem(
      eyebrow: 'A REPORT YOU CAN ACT ON',
      title: 'Understand priorities, effects, and remedies.',
      description:
          'Receive an elegant, explainable report generated from approved, versioned Vastu rules.',
      icon: Icons.auto_awesome_outlined,
      accent: AppColors.sky,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage == _items.length - 1) {
      context.go('/home');
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PremiumScaffold(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const BrandMark(size: 38),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Skip'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) => _OnboardingPanel(item: _items[index]),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _items.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: index == _currentPage ? 30 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: index == _currentPage
                        ? AppColors.deepNavy
                        : AppColors.outline,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: _currentPage == _items.length - 1
                  ? 'Begin with ${AppConfig.appName}'
                  : 'Continue',
              icon: Icons.arrow_forward_rounded,
              onPressed: _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPanel extends StatelessWidget {
  const _OnboardingPanel({required this.item});

  final _OnboardingItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 230,
          height: 230,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [item.accent.withValues(alpha: 0.22), Colors.transparent],
            ),
          ),
          child: Center(
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color: AppColors.deepNavy,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.lightGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.25),
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Icon(item.icon, size: 58, color: item.accent),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          item.eyebrow,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w800,
            fontSize: 12,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 34),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Text(
            item.description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.muted,
                ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingItem {
  const _OnboardingItem({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });

  final String eyebrow;
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
}

