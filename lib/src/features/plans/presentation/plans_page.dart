import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  var _selectedId = 'standard';

  static const plans = <_PlanData>[
    _PlanData(
      id: 'basic',
      name: 'Basic',
      price: 799,
      subtitle: 'For one property check',
      features: ['1 detailed PDF report', '16/32 direction analysis', 'Report history'],
    ),
    _PlanData(
      id: 'standard',
      name: 'Standard',
      price: 1499,
      subtitle: 'For complete home analysis',
      features: ['3 detailed PDF reports', 'Priority action plan', 'Hindi and English reports', '30-day report access'],
      recommended: true,
    ),
    _PlanData(
      id: 'premium',
      name: 'Premium',
      price: 4999,
      subtitle: 'For families and professionals',
      features: ['Unlimited reports for one year', 'Expert-reviewed report', 'Consultation discount', 'Priority support'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selected = plans.firstWhere((plan) => plan.id == _selectedId);

    return PremiumScaffold(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
        children: [
          const BrandMark(size: 38),
          const SizedBox(height: 28),
          Text('Choose your report plan', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 35)),
          const SizedBox(height: 8),
          Text(
            'Start with the plan that matches the number of properties you want to analyse.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          ...plans.map(
            (plan) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PlanCard(
                plan: plan,
                selected: plan.id == _selectedId,
                onTap: () => setState(() => _selectedId = plan.id),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.28)),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: AppColors.gold),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Need an expert?', style: TextStyle(fontWeight: FontWeight.w700)),
                      SizedBox(height: 3),
                      Text('A one-to-one consultation can be added during checkout for ₹499.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 6, 6),
        child: PrimaryButton(
          label: 'Continue with ${selected.name} · ₹${selected.price}',
          icon: Icons.lock_outline_rounded,
          onPressed: () => _openCheckout(context, selected),
        ),
      ),
    );
  }

  void _openCheckout(BuildContext context, _PlanData plan) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _CheckoutSheet(plan: plan),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.selected, required this.onTap});

  final _PlanData plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: selected ? AppColors.deepNavy : AppColors.warmWhite,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? AppColors.gold : AppColors.outline, width: selected ? 1.5 : 1),
            boxShadow: [
              BoxShadow(
                color: AppColors.midnight.withValues(alpha: selected ? 0.18 : 0.04),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text(plan.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: selected ? Colors.white : AppColors.ink)),
                        if (plan.recommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(99)),
                            child: const Text('POPULAR', style: TextStyle(color: AppColors.midnight, fontSize: 9, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(selected ? Icons.check_circle_rounded : Icons.circle_outlined, color: selected ? AppColors.emerald : AppColors.muted),
                ],
              ),
              const SizedBox(height: 6),
              Text(plan.subtitle, style: TextStyle(color: selected ? Colors.white60 : AppColors.muted)),
              const SizedBox(height: 16),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '₹${plan.price}', style: TextStyle(color: selected ? AppColors.lightGold : AppColors.deepNavy, fontSize: 30, fontWeight: FontWeight.w800)),
                    TextSpan(text: '  including taxes', style: TextStyle(color: selected ? Colors.white54 : AppColors.muted, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ...plan.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_rounded, size: 17, color: AppColors.emerald),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature, style: TextStyle(color: selected ? Colors.white70 : AppColors.ink))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({required this.plan});

  final _PlanData plan;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  var _paymentMethod = 'upi';
  var _consultation = false;

  @override
  Widget build(BuildContext context) {
    final total = widget.plan.price + (_consultation ? 499 : 0);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(22, 4, 22, 20 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Secure checkout', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 5),
            Text('${widget.plan.name} report plan', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.ivory, borderRadius: BorderRadius.circular(18)),
              child: Column(
                children: [
                  _PriceRow(label: widget.plan.name, value: '₹${widget.plan.price}'),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    value: _consultation,
                    activeThumbColor: AppColors.emerald,
                    title: const Text('Add expert consultation'),
                    subtitle: const Text('One 10-minute session · ₹499'),
                    onChanged: (value) => setState(() => _consultation = value),
                  ),
                  const Divider(),
                  _PriceRow(label: 'Total', value: '₹$total', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text('Payment method', style: Theme.of(context).textTheme.titleMedium),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: 'upi',
              groupValue: _paymentMethod,
              title: const Text('UPI'),
              secondary: const Icon(Icons.qr_code_rounded),
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            RadioListTile<String>(
              contentPadding: EdgeInsets.zero,
              value: 'card',
              groupValue: _paymentMethod,
              title: const Text('Debit or credit card'),
              secondary: const Icon(Icons.credit_card_rounded),
              onChanged: (value) => setState(() => _paymentMethod = value!),
            ),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Review payment · ₹$total',
              icon: Icons.lock_rounded,
              onPressed: () => _showPaymentStatus(context),
            ),
            const SizedBox(height: 9),
            const Center(child: Text('No payment is charged in this development milestone.', style: TextStyle(fontSize: 11, color: AppColors.muted))),
          ],
        ),
      ),
    );
  }

  void _showPaymentStatus(BuildContext sheetContext) {
    final rootNavigator = Navigator.of(sheetContext, rootNavigator: true);
    Navigator.pop(sheetContext);
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!rootNavigator.mounted) return;
      showDialog<void>(
        context: rootNavigator.context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.verified_user_outlined, color: AppColors.emerald, size: 38),
          title: const Text('Checkout flow is ready'),
          content: const Text('The production milestone will connect this screen to Apple StoreKit and Google Play Billing.'),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      );
    });
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value, this.bold = false});

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w700 : FontWeight.w500))),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PlanData {
  const _PlanData({
    required this.id,
    required this.name,
    required this.price,
    required this.subtitle,
    required this.features,
    this.recommended = false,
  });

  final String id;
  final String name;
  final int price;
  final String subtitle;
  final List<String> features;
  final bool recommended;
}
