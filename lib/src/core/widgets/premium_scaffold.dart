import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PremiumScaffold extends StatelessWidget {
  const PremiumScaffold({
    required this.child,
    super.key,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.dark = false,
    this.safeTop = true,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool dark;
  final bool safeTop;

  @override
  Widget build(BuildContext context) {
    final colors = dark
        ? const [AppColors.midnight, AppColors.deepNavy]
        : const [AppColors.warmWhite, AppColors.ivory];

    return Scaffold(
      backgroundColor: colors.last,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
          Positioned(
            right: -90,
            top: -70,
            child: _GlowOrb(
              size: 240,
              color: AppColors.gold.withValues(alpha: dark ? 0.15 : 0.10),
            ),
          ),
          Positioned(
            left: -110,
            bottom: 40,
            child: _GlowOrb(
              size: 260,
              color: AppColors.sky.withValues(alpha: dark ? 0.08 : 0.09),
            ),
          ),
          SafeArea(top: safeTop, child: child),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class PremiumCard extends StatelessWidget {
  const PremiumCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.dark = false,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool dark;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? AppColors.deepNavy : AppColors.warmWhite,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor ?? (dark ? Colors.white12 : AppColors.outline),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.midnight.withValues(alpha: dark ? 0.22 : 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: card,
      ),
    );
  }
}
