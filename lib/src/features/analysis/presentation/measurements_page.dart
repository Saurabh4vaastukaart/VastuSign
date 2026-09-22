import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/analysis_controller.dart';
import '../domain/direction_engine.dart';
import '../domain/vastu_measurement.dart';
import 'widgets/rating_pill.dart';

class MeasurementsPage extends ConsumerWidget {
  const MeasurementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurements = ref.watch(analysisControllerProvider).measurements;
    final uncertainCount = measurements.where((item) => item.isBoundaryUncertain).length;

    return PremiumScaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Review measurements'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                'STEP 3 OF 3',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
              ),
            ),
          ),
        ],
      ),
      child: measurements.isEmpty
          ? _EmptyMeasurements(onAdd: () => context.go('/analysis/categories'))
          : ListView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 140),
              children: [
                Text(
                  'Your property\nis taking shape.',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 34),
                ),
                const SizedBox(height: 8),
                Text(
                  '${measurements.length} areas measured. Review every angle before creating the report.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                ),
                if (uncertainCount > 0) ...[
                  const SizedBox(height: 18),
                  _BoundaryWarning(count: uncertainCount),
                ],
                const SizedBox(height: 22),
                SectionHeading(
                  title: 'Saved readings',
                  trailing: TextButton.icon(
                    onPressed: () => context.push('/analysis/categories'),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add area'),
                  ),
                ),
                const SizedBox(height: 12),
                ...measurements.map(
                  (measurement) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MeasurementCard(
                      measurement: measurement,
                      onEdit: () => _editMeasurement(context, ref, measurement),
                      onDelete: () => _deleteMeasurement(context, ref, measurement),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: () => context.push('/analysis/categories'),
                  icon: const Icon(Icons.add_home_work_outlined),
                  label: const Text('Measure another area'),
                ),
              ],
            ),
      floatingActionButton: measurements.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 6, 6),
              child: PrimaryButton(
                label: 'Preview Vastu report',
                icon: Icons.auto_awesome_rounded,
                onPressed: () => context.push('/report/preview'),
              ),
            ),
    );
  }

  Future<void> _editMeasurement(
    BuildContext context,
    WidgetRef ref,
    VastuMeasurement measurement,
  ) async {
    var draftAngle = measurement.angle;
    final updated = await showDialog<double>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final sector = DirectionEngine.classify(draftAngle, measurement.category.scheme);
          return AlertDialog(
            title: Text('Edit ${measurement.category.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${draftAngle.toStringAsFixed(1)}° · ${sector.label}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 14),
                Slider(
                  value: draftAngle,
                  min: 0,
                  max: 359.9,
                  onChanged: (value) => setState(() => draftAngle = value),
                ),
                Text(
                  'Manual edits are recorded separately in the production audit trail.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(context, draftAngle), child: const Text('Save angle')),
            ],
          );
        },
      ),
    );
    if (updated != null) {
      ref
          .read(analysisControllerProvider.notifier)
          .updateMeasurement(measurement.id, updated);
    }
  }

  Future<void> _deleteMeasurement(
    BuildContext context,
    WidgetRef ref,
    VastuMeasurement measurement,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove measurement?'),
        content: Text('${measurement.category.name} will be removed from this analysis.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(analysisControllerProvider.notifier).removeMeasurement(measurement.id);
    }
  }
}

class _MeasurementCard extends StatelessWidget {
  const _MeasurementCard({
    required this.measurement,
    required this.onEdit,
    required this.onDelete,
  });

  final VastuMeasurement measurement;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = RatingPill.colorFor(measurement.rating);
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(measurement.category.icon, color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        measurement.category.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    RatingPill(rating: measurement.rating, compact: true),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${measurement.angle.toStringAsFixed(1)}° · ${measurement.direction}'
                  '${measurement.direction == measurement.broadDirection ? '' : ' (${measurement.broadDirection})'}',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.blue),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Icon(
                      measurement.isBoundaryUncertain
                          ? Icons.warning_amber_rounded
                          : Icons.verified_rounded,
                      size: 14,
                      color: measurement.isBoundaryUncertain ? AppColors.amber : AppColors.emerald,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      measurement.isBoundaryUncertain
                          ? 'Saved with boundary warning'
                          : 'Accuracy ±${measurement.accuracy.toStringAsFixed(1)}°',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            tooltip: 'Measurement options',
            onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit angle'))),
              PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Remove'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _BoundaryWarning extends StatelessWidget {
  const _BoundaryWarning({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.amber.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz_rounded, color: AppColors.amber),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$count ${count == 1 ? 'reading is' : 'readings are'} close to a direction boundary. The report will show this uncertainty.',
              style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyMeasurements extends StatelessWidget {
  const _EmptyMeasurements({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.explore_off_outlined, size: 62, color: AppColors.gold),
            const SizedBox(height: 18),
            Text('No measurements yet', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Choose an area and save your first compass reading.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              expanded: false,
              label: 'Choose an area',
              icon: Icons.add_rounded,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

