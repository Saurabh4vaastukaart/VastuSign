import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../analysis/application/analysis_controller.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analysis = ref.watch(analysisControllerProvider);

    return PremiumScaffold(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 30),
            sliver: SliverList.list(
              children: [
                Row(
                  children: [
                    const Expanded(child: BrandMark(size: 40)),
                    IconButton.filledTonal(
                      tooltip: 'Notifications',
                      onPressed: () => _showNotifications(context),
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                    const SizedBox(width: 8),
                    const CircleAvatar(
                      radius: 21,
                      backgroundColor: AppColors.deepNavy,
                      child: Text(
                        'SK',
                        style: TextStyle(
                          color: AppColors.lightGold,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'Namaste,',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.gold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Read your space\nwith confidence.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 38,
                      ),
                ),
                const SizedBox(height: 24),
                _AnalysisHero(
                  measurementCount: analysis.measurements.length,
                  onStart: () => context.push('/analysis/categories'),
                  onResume: analysis.measurements.isEmpty
                      ? null
                      : () => context.push('/analysis/measurements'),
                ),
                const SizedBox(height: 28),
                const SectionHeading(
                  title: 'Explore VastuSign',
                  subtitle: 'Everything you need for a guided self-analysis.',
                ),
                const SizedBox(height: 14),
                _QuickActionGrid(
                  onCompass: () => context.push('/analysis/categories'),
                  onReports: () => context.go('/reports'),
                  onGuide: () => _showGuide(context),
                  onExpert: () => _showExpertBooking(context),
                ),
                const SizedBox(height: 28),
                SectionHeading(
                  title: 'Recent activity',
                  trailing: TextButton(
                    onPressed: () => context.go('/reports'),
                    child: const Text('View all'),
                  ),
                ),
                const SizedBox(height: 12),
                _RecentActivityCard(
                  measurementCount: analysis.measurements.length,
                  onTap: analysis.measurements.isEmpty
                      ? () => context.push('/analysis/categories')
                      : () => context.push('/analysis/measurements'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 4, 24, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are all caught up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 8),
            Text('Calibration reminders and completed reports will appear here.'),
          ],
        ),
      ),
    );
  }

  void _showGuide(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 4, 24, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Before you measure', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            SizedBox(height: 14),
            Text('1. Remove magnetic covers and accessories.'),
            SizedBox(height: 8),
            Text('2. Stand at the property centre or instructed reference point.'),
            SizedBox(height: 8),
            Text('3. Keep the phone flat and wait for the Ready status.'),
          ],
        ),
      ),
    );
  }

  void _showExpertBooking(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Expert consultation'),
        content: const Text(
          'Consultation slots will connect to the booking and payment service in the commercial milestone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _AnalysisHero extends StatelessWidget {
  const _AnalysisHero({
    required this.measurementCount,
    required this.onStart,
    required this.onResume,
  });

  final int measurementCount;
  final VoidCallback onStart;
  final VoidCallback? onResume;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.midnight, AppColors.navy, Color(0xFF176177)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.midnight.withValues(alpha: 0.24),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: AppColors.emerald.withValues(alpha: 0.45)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sensors_rounded, size: 15, color: AppColors.emerald),
                      SizedBox(width: 6),
                      Text(
                        'READY',
                        style: TextStyle(
                          color: AppColors.emerald,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  measurementCount == 0 ? 'Start a new analysis' : 'Continue your analysis',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontSize: 26,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  measurementCount == 0
                      ? 'Measure rooms and create your personalised Vastu report.'
                      : '$measurementCount measurements saved. Add more or review your list.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  expanded: false,
                  light: true,
                  label: measurementCount == 0 ? 'Start analysis' : 'Add another',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onStart,
                ),
                if (onResume != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onResume,
                    style: TextButton.styleFrom(foregroundColor: AppColors.lightGold),
                    icon: const Icon(Icons.list_alt_rounded, size: 18),
                    label: const Text('Review saved measurements'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(flex: 4, child: _MiniCompass()),
        ],
      ),
    );
  }
}

class _MiniCompass extends StatelessWidget {
  const _MiniCompass();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.lightGold.withValues(alpha: 0.65), width: 1.5),
          gradient: RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.10), Colors.transparent],
          ),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.explore_rounded, color: AppColors.lightGold, size: 74),
            Positioned(top: 8, child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
          ],
        ),
      ),
    );
  }
}

class _QuickActionGrid extends StatelessWidget {
  const _QuickActionGrid({
    required this.onCompass,
    required this.onReports,
    required this.onGuide,
    required this.onExpert,
  });

  final VoidCallback onCompass;
  final VoidCallback onReports;
  final VoidCallback onGuide;
  final VoidCallback onExpert;

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionData('Compass', 'Quick direction check', Icons.explore_outlined, AppColors.gold, onCompass),
      _ActionData('Reports', 'View past analysis', Icons.description_outlined, AppColors.emerald, onReports),
      _ActionData('How it works', 'Measurement guide', Icons.menu_book_outlined, AppColors.sky, onGuide),
      _ActionData('Ask an expert', 'Book consultation', Icons.support_agent_rounded, AppColors.amber, onExpert),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemBuilder: (context, index) {
        final action = actions[index];
        return PremiumCard(
          onTap: action.onTap,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(action.icon, color: action.color),
              ),
              const Spacer(),
              Text(action.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(action.subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        );
      },
    );
  }
}

class _ActionData {
  const _ActionData(this.title, this.subtitle, this.icon, this.color, this.onTap);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.measurementCount, required this.onTap});

  final int measurementCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.home_work_outlined, color: AppColors.gold),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  measurementCount == 0 ? 'No analysis yet' : 'My Property',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  measurementCount == 0
                      ? 'Your saved work will appear here.'
                      : '$measurementCount measurements saved as draft',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            measurementCount == 0 ? Icons.add_circle_outline : Icons.chevron_right_rounded,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}
