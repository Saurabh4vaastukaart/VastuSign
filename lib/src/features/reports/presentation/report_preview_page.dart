import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../../core/config/app_config.dart';
import '../../../core/data/local_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/primary_button.dart';
import '../../analysis/application/analysis_controller.dart';
import '../../analysis/domain/vastu_measurement.dart';
import '../../analysis/presentation/widgets/rating_pill.dart';
import '../data/demo_report_repository.dart';
import '../data/report_pdf_service.dart';
import '../domain/vastu_report.dart';

class ReportPreviewPage extends ConsumerWidget {
  const ReportPreviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurements = ref.watch(analysisControllerProvider).measurements;
    if (measurements.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Report preview')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.description_outlined, size: 62, color: AppColors.gold),
                const SizedBox(height: 18),
                Text('Measurements required', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text('Save at least one area before previewing your report.'),
                const SizedBox(height: 22),
                PrimaryButton(
                  expanded: false,
                  label: 'Start analysis',
                  onPressed: () => context.go('/analysis/categories'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final report = const DemoReportRepository().build(measurements);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 82,
            backgroundColor: AppColors.midnight,
            foregroundColor: Colors.white,
            leading: IconButton(
              tooltip: 'Back',
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: const Text('Report preview'),
            actions: [
              IconButton(
                tooltip: 'Report information',
                onPressed: () => _showReportInfo(context, report),
                icon: const Icon(Icons.info_outline_rounded),
              ),
            ],
          ),
          SliverToBoxAdapter(child: _ReportHero(report: report)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 130),
            sliver: SliverList.list(
              children: [
                const SectionHeading(
                  title: 'At a glance',
                  subtitle: 'A transparent summary of every captured area.',
                ),
                const SizedBox(height: 14),
                _SummaryMetrics(report: report),
                const SizedBox(height: 26),
                const SectionHeading(
                  title: 'Zonal compliance',
                  subtitle: 'Scores use a transparent, versioned starter rule set.',
                ),
                const SizedBox(height: 12),
                _ComplianceCard(report: report),
                const SizedBox(height: 26),
                const SectionHeading(
                  title: 'Detailed observations',
                  subtitle: 'Ordered from the most important correction.',
                ),
                const SizedBox(height: 12),
                ...report.observations.map(
                  (observation) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ObservationCard(observation: observation),
                  ),
                ),
                const SizedBox(height: 14),
                _ActionPlan(report: report),
                const SizedBox(height: 20),
                _ReportMetadata(report: report),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            color: AppColors.warmWhite,
            border: const Border(top: BorderSide(color: AppColors.outline)),
            boxShadow: [
              BoxShadow(
                color: AppColors.midnight.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: PrimaryButton(
            label: 'Save & share PDF report',
            icon: Icons.picture_as_pdf_outlined,
            onPressed: () => _saveAndShare(context, report),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAndShare(BuildContext context, VastuReport report) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(const SnackBar(content: Text('Creating your PDF report…')));
    try {
      final file = await const ReportPdfService().generateAndSave(report);
      await LocalDatabase.instance.saveReport(report, pdfPath: file.path);
      await Printing.sharePdf(
        bytes: await file.readAsBytes(),
        filename: '${report.id}.pdf',
      );
    } catch (error) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not create the PDF: $error')),
      );
    }
  }

  void _showReportInfo(BuildContext context, VastuReport report) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('About this preview', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            const Text(
              'This report uses a versioned starter rule set. Treat it as guidance, not structural or medical advice. A qualified Vastu expert can validate or replace the rules without changing the app flow.',
            ),
            const SizedBox(height: 14),
            Text('Rules: ${report.ruleSetVersion}'),
            Text('Template: ${report.templateVersion}'),
          ],
        ),
      ),
    );
  }
}

class _ReportHero extends StatelessWidget {
  const _ReportHero({required this.report});

  final VastuReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.midnight, AppColors.deepNavy, Color(0xFF16566B)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(size: 34, onDark: true),
          const SizedBox(height: 26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      report.propertyLabel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        '${report.observations.length} AREAS ANALYSED',
                        style: const TextStyle(
                          color: AppColors.lightGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _ScoreRing(score: report.overallScore),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final color = score >= 75
        ? AppColors.emerald
        : score >= 55
            ? AppColors.amber
            : AppColors.coral;
    return SizedBox.square(
      dimension: 112,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.square(
            dimension: 104,
            child: CircularProgressIndicator(
              value: score / 100,
              strokeWidth: 8,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: Colors.white12,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                    ),
              ),
              const Text('OUT OF 100', style: TextStyle(color: Colors.white54, fontSize: 8, letterSpacing: 0.6)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({required this.report});

  final VastuReport report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MetricCard(value: report.criticalCount, label: 'Critical', color: AppColors.coral, icon: Icons.warning_rounded)),
        const SizedBox(width: 9),
        Expanded(child: _MetricCard(value: report.attentionCount, label: 'Review', color: AppColors.amber, icon: Icons.error_rounded)),
        const SizedBox(width: 9),
        Expanded(child: _MetricCard(value: report.positiveCount, label: 'Positive', color: AppColors.emerald, icon: Icons.check_circle_rounded)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label, required this.color, required this.icon});

  final int value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 19),
          const SizedBox(height: 7),
          Text('$value', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: color)),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard({required this.report});

  final VastuReport report;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: report.observations.indexed.map((entry) {
          final index = entry.$1;
          final measurement = entry.$2.measurement;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: RatingPill.colorFor(measurement.rating).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(measurement.category.icon, size: 20, color: RatingPill.colorFor(measurement.rating)),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(measurement.category.name, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                          Text('${measurement.angle.toStringAsFixed(1)}° · ${measurement.direction}', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text('${measurement.score}', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(width: 10),
                    RatingPill(rating: measurement.rating, compact: true),
                  ],
                ),
              ),
              if (index != report.observations.length - 1) const Divider(height: 1, indent: 65),
            ],
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({required this.observation});

  final ReportObservation observation;

  @override
  Widget build(BuildContext context) {
    final measurement = observation.measurement;
    final color = RatingPill.colorFor(measurement.rating);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.warmWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.outline),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(16, 10, 14, 10),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        shape: const Border(),
        collapsedShape: const Border(),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.11),
          foregroundColor: color,
          child: Icon(measurement.category.icon, size: 20),
        ),
        title: Text(measurement.category.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('Priority ${observation.priority} · ${measurement.direction} · Score ${measurement.score}'),
        trailing: RatingPill(rating: measurement.rating, compact: true),
        children: [
          _ObservationSection(title: 'Possible impact', items: observation.effects, color: color),
          const SizedBox(height: 16),
          _ObservationSection(title: 'Recommended action', items: observation.remedies, color: AppColors.emerald),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _SmallInfo(label: 'Difficulty', value: observation.difficulty.label)),
              const SizedBox(width: 10),
              Expanded(child: _SmallInfo(label: 'Accuracy', value: '±${measurement.accuracy.toStringAsFixed(1)}°')),
            ],
          ),
          if (measurement.isBoundaryUncertain) ...[
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 17, color: AppColors.amber),
                SizedBox(width: 7),
                Expanded(child: Text('This direction was saved with a boundary warning.', style: TextStyle(fontSize: 12))),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ObservationSection extends StatelessWidget {
  const _ObservationSection({required this.title, required this.items, required this.color});

  final String title;
  final List<String> items;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
        const SizedBox(height: 9),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 7),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 9),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallInfo extends StatelessWidget {
  const _SmallInfo({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.ivory,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ActionPlan extends StatelessWidget {
  const _ActionPlan({required this.report});

  final VastuReport report;

  @override
  Widget build(BuildContext context) {
    final priorities = report.observations.take(3).toList(growable: false);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.deepNavy, AppColors.navy]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.route_rounded, color: AppColors.lightGold),
              SizedBox(width: 9),
              Text('Recommended action plan', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          ...priorities.indexed.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.lightGold,
                    foregroundColor: AppColors.midnight,
                    child: Text('${entry.$1 + 1}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.$2.measurement.category.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(entry.$2.remedies.first, style: const TextStyle(color: Colors.white60, height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportMetadata extends StatelessWidget {
  const _ReportMetadata({required this.report});

  final VastuReport report;

  @override
  Widget build(BuildContext context) {
    final date = report.generatedAt;
    final formattedDate = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text('Preview generated $formattedDate · ${report.id}', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(
          'Vastu guidance is traditional in nature and is not a substitute for structural, medical, financial, or safety advice.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
