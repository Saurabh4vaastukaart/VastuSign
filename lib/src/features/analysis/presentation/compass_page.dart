import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/analysis_controller.dart';
import '../domain/compass_reading.dart';
import '../domain/direction_engine.dart';
import '../domain/vastu_category.dart';
import 'widgets/compass_dial.dart';

class CompassPage extends ConsumerStatefulWidget {
  const CompassPage({super.key});

  @override
  ConsumerState<CompassPage> createState() => _CompassPageState();
}

class _CompassPageState extends ConsumerState<CompassPage> {
  StreamSubscription<CompassEvent>? _compassSubscription;
  CameraController? _cameraController;
  var _cameraOn = false;
  var _cameraLoading = false;
  var _manualMode = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCompass());
  }

  void _startCompass() {
    final stream = FlutterCompass.events;
    if (stream == null) {
      ref
          .read(analysisControllerProvider.notifier)
          .setQuality(CompassQuality.unavailable, accuracy: 180);
      return;
    }
    _compassSubscription = stream.listen((event) {
      if (!mounted || _manualMode) return;
      final heading = event.heading;
      if (heading == null) {
        ref
            .read(analysisControllerProvider.notifier)
            .setQuality(CompassQuality.unavailable, accuracy: 180);
        return;
      }
      final accuracy = (event.accuracy ?? 12).abs().clamp(1, 180).toDouble();
      final quality = accuracy <= 15
          ? CompassQuality.ready
          : CompassQuality.calibrating;
      final controller = ref.read(analysisControllerProvider.notifier);
      controller.updateHeading(heading);
      controller.setQuality(quality, accuracy: accuracy);
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = ref.watch(analysisControllerProvider);
    final category = analysis.selectedCategory;
    if (category == null) {
      return Scaffold(
        body: Center(
          child: PrimaryButton(
            expanded: false,
            label: 'Select an area',
            onPressed: () => context.go('/analysis/categories'),
          ),
        ),
      );
    }

    final sector = DirectionEngine.classify(analysis.heading, category.scheme);
    final uncertain = sector.isBoundaryUncertain(analysis.accuracy);

    return PremiumScaffold(
      dark: true,
      appBar: AppBar(
        backgroundColor: AppColors.midnight,
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(category.name),
        actions: [
          IconButton(
            tooltip: _cameraOn ? 'Turn camera off' : 'Turn camera on',
            onPressed: _cameraLoading ? null : _toggleCamera,
            icon: _cameraLoading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_cameraOn ? Icons.videocam_rounded : Icons.videocam_off_outlined),
          ),
          IconButton(
            tooltip: 'Calibration help',
            onPressed: () => _showCalibrationHelp(context),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 28),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STEP 2 OF 3',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.lightGold,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
              ),
              _QualityPill(quality: analysis.quality, accuracy: analysis.accuracy),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            category.scheme == DirectionScheme.entrance32
                ? 'Aim through the centre\nof the main door.'
                : 'Point towards the centre\nof the ${category.name.toLowerCase()}.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 29,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Keep the phone flat and away from metal. Save only when the reading is stable.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: 24),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 390),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(195),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (_cameraOn && _cameraController?.value.isInitialized == true)
                        CameraPreview(_cameraController!)
                      else
                        Container(color: AppColors.midnight),
                      if (_cameraOn)
                        Container(color: Colors.black.withValues(alpha: 0.18)),
                      CompassDial(
                        heading: analysis.heading,
                        direction: sector.label,
                        transparent: _cameraOn,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),
          _DirectionSummary(
            category: category,
            direction: sector.label,
            broadDirection: sector.broadDirection,
            startAngle: sector.startAngle,
            endAngle: sector.endAngle,
            uncertain: uncertain,
          ),
          const SizedBox(height: 16),
          SegmentedButton<bool>(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.midnight
                    : Colors.white70,
              ),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.lightGold
                    : Colors.white.withValues(alpha: 0.06),
              ),
              side: const WidgetStatePropertyAll(BorderSide(color: Colors.white24)),
            ),
            segments: const [
              ButtonSegment(value: false, label: Text('Magnetic North')),
              ButtonSegment(
                value: true,
                enabled: false,
                label: Text('True North'),
                tooltip: 'True North needs location-based declination and is not enabled yet.',
              ),
            ],
            selected: {analysis.isTrueNorth},
            onSelectionChanged: (selection) => ref
                .read(analysisControllerProvider.notifier)
                .setNorthMode(trueNorth: selection.first),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _manualMode ? 'Manual direction override' : 'Live sensor reading',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    Text(
                      '${analysis.heading.toStringAsFixed(1)}°',
                      style: const TextStyle(color: AppColors.lightGold, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                Slider(
                  value: analysis.heading,
                  min: 0,
                  max: 359.9,
                  activeColor: AppColors.lightGold,
                  inactiveColor: Colors.white24,
                  onChangeStart: (_) => setState(() => _manualMode = true),
                  onChanged: (value) => ref
                      .read(analysisControllerProvider.notifier)
                      .updateHeading(value),
                ),
                if (_manualMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _manualMode = false),
                      icon: const Icon(Icons.sensors_rounded),
                      label: const Text('Use live compass'),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            light: true,
            label: uncertain ? 'Review boundary before saving' : 'Save this measurement',
            icon: uncertain ? Icons.warning_amber_rounded : Icons.check_rounded,
            onPressed: analysis.quality == CompassQuality.ready
                ? () => _capture(context, uncertain)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _capture(BuildContext context, bool uncertain) async {
    if (uncertain) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.amber, size: 34),
          title: const Text('Reading is near a boundary'),
          content: const Text(
            'Sensor uncertainty overlaps two sectors. Recalibrate and measure again for the most reliable report.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Re-measure')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save with warning')),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    String? photoPath;
    final camera = _cameraController;
    if (_cameraOn && camera?.value.isInitialized == true) {
      try {
        photoPath = (await camera!.takePicture()).path;
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Measurement saved without a photo.')),
          );
        }
      }
    }
    final result = ref
        .read(analysisControllerProvider.notifier)
        .capture(photoPath: photoPath);
    if (result != null && mounted) context.push('/analysis/measurements');
  }

  Future<void> _toggleCamera() async {
    if (_cameraOn) {
      await _cameraController?.dispose();
      _cameraController = null;
      if (mounted) setState(() => _cameraOn = false);
      return;
    }
    setState(() => _cameraLoading = true);
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw StateError('No camera is available.');
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _cameraController = controller;
      setState(() => _cameraOn = true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera unavailable: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _cameraLoading = false);
    }
  }

  void _showCalibrationHelp(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Improve compass accuracy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            const _CalibrationStep(icon: Icons.phone_android_rounded, text: 'Remove magnetic covers and hold the phone flat.'),
            const _CalibrationStep(icon: Icons.gesture_rounded, text: 'Move the phone slowly in a figure-eight pattern.'),
            const _CalibrationStep(icon: Icons.electrical_services_rounded, text: 'Step away from metal, appliances, and strong wiring.'),
            const SizedBox(height: 18),
            PrimaryButton(
              label: 'Start guided calibration',
              icon: Icons.sync_rounded,
              onPressed: () {
                Navigator.pop(sheetContext);
                _startCalibration();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startCalibration() async {
    ref
        .read(analysisControllerProvider.notifier)
        .setQuality(CompassQuality.calibrating, accuracy: 12);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Move your phone in a slow figure-eight pattern…')),
    );
    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calibration completed. Waiting for a stable sensor reading.')),
    );
  }
}

class _QualityPill extends StatelessWidget {
  const _QualityPill({required this.quality, required this.accuracy});

  final CompassQuality quality;
  final double accuracy;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (quality) {
      CompassQuality.ready => ('READY ±${accuracy.toStringAsFixed(1)}°', AppColors.emerald, Icons.check_circle_rounded),
      CompassQuality.calibrating => ('CALIBRATING', AppColors.amber, Icons.sync_rounded),
      CompassQuality.interference => ('INTERFERENCE', AppColors.coral, Icons.warning_rounded),
      CompassQuality.unstable => ('HOLD STEADY', AppColors.amber, Icons.screen_rotation_rounded),
      CompassQuality.unavailable => ('NO SENSOR', AppColors.coral, Icons.sensors_off_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.7),
          ),
        ],
      ),
    );
  }
}

class _DirectionSummary extends StatelessWidget {
  const _DirectionSummary({
    required this.category,
    required this.direction,
    required this.broadDirection,
    required this.startAngle,
    required this.endAngle,
    required this.uncertain,
  });

  final VastuCategory category;
  final String direction;
  final String broadDirection;
  final double startAngle;
  final double endAngle;
  final bool uncertain;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: uncertain
            ? AppColors.amber.withValues(alpha: 0.11)
            : Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: uncertain ? AppColors.amber : Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              uncertain ? Icons.swap_horiz_rounded : Icons.explore_rounded,
              color: uncertain ? AppColors.amber : AppColors.lightGold,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.scheme == DirectionScheme.entrance32
                      ? '$direction pada · $broadDirection zone'
                      : '$direction direction',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 3),
                Text(
                  uncertain
                      ? 'Accuracy overlaps a sector boundary.'
                      : '${startAngle.toStringAsFixed(2)}° to ${endAngle.toStringAsFixed(2)}°',
                  style: TextStyle(color: uncertain ? AppColors.amber : Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalibrationStep extends StatelessWidget {
  const _CalibrationStep({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
