import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/data/local_database.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../analysis/application/analysis_controller.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurements = ref.watch(analysisControllerProvider).measurements;

    return PremiumScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
        children: [
          const BrandMark(size: 38),
          const SizedBox(height: 28),
          Text('Your reports', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            'Drafts, completed reports, and consultant reviews will stay organised by property.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 24),
          if (measurements.isNotEmpty)
            _DraftReportCard(
              count: measurements.length,
              onOpen: () => context.push('/report/preview'),
              onContinue: () => context.push('/analysis/categories'),
            )
          else
            _EmptyReports(onStart: () => context.push('/analysis/categories')),
          const SizedBox(height: 26),
          const SectionHeading(title: 'Completed reports'),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, Object?>>>(
            future: LocalDatabase.instance.listReports(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final reports = snapshot.data ?? const [];
              if (reports.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.warmWhite,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.description_outlined, color: AppColors.gold),
                      SizedBox(width: 12),
                      Expanded(child: Text('Saved PDF reports will appear here.')),
                    ],
                  ),
                );
              }
              return Column(
                children: reports.map((row) {
                  final payload = jsonDecode(row['report_json'] as String)
                      as Map<String, dynamic>;
                  final generated = DateTime.parse(row['generated_at'] as String);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PremiumCard(
                      onTap: () => _shareSavedReport(context, row),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.emerald.withValues(alpha: 0.12),
                          foregroundColor: AppColors.emerald,
                          child: const Icon(Icons.picture_as_pdf_outlined),
                        ),
                        title: Text(payload['propertyLabel'] as String? ?? 'My Property'),
                        subtitle: Text(
                          '${generated.day}/${generated.month}/${generated.year} · ${payload['observations'] is List ? (payload['observations'] as List).length : 0} areas',
                        ),
                        trailing: Text(
                          '${row['overall_score']}/100',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  );
                }).toList(growable: false),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _shareSavedReport(
    BuildContext context,
    Map<String, Object?> row,
  ) async {
    final path = row['pdf_path'] as String?;
    if (path == null || !await File(path).exists()) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The saved PDF file is no longer available.')),
      );
      return;
    }
    final file = File(path);
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: path.split(Platform.pathSeparator).last,
    );
  }
}

class _DraftReportCard extends StatelessWidget {
  const _DraftReportCard({required this.count, required this.onOpen, required this.onContinue});

  final int count;
  final VoidCallback onOpen;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.midnight, AppColors.navy]),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.home_work_outlined, color: AppColors.lightGold),
              _DraftPill(),
            ],
          ),
          const SizedBox(height: 18),
          Text('My Property', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
          const SizedBox(height: 6),
          Text('$count measurements ready for review', style: const TextStyle(color: Colors.white60)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: PrimaryButton(label: 'Preview', light: true, onPressed: onOpen)),
              const SizedBox(width: 10),
              IconButton.outlined(
                tooltip: 'Add another area',
                style: IconButton.styleFrom(foregroundColor: AppColors.lightGold, side: const BorderSide(color: Colors.white24)),
                onPressed: onContinue,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DraftPill extends StatelessWidget {
  const _DraftPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(color: AppColors.amber.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(99)),
      child: const Text('DRAFT', style: TextStyle(color: AppColors.amber, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome_outlined, size: 48, color: AppColors.gold),
          const SizedBox(height: 14),
          Text('Your first report starts here', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 7),
          Text('Measure the important areas of your property to create a personalised preview.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          PrimaryButton(label: 'Start self-analysis', icon: Icons.explore_rounded, onPressed: onStart),
        ],
      ),
    );
  }
}
