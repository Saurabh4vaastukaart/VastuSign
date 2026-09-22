import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/premium_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../application/analysis_controller.dart';
import '../data/demo_categories.dart';
import '../domain/vastu_category.dart';

class CategoryPage extends ConsumerStatefulWidget {
  const CategoryPage({super.key});

  @override
  ConsumerState<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends ConsumerState<CategoryPage> {
  var _query = '';

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(analysisControllerProvider).selectedCategory;
    final filtered = demoCategories.where((category) {
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          category.name.toLowerCase().contains(query) ||
          category.hindiName.contains(_query.trim());
    }).toList(growable: false);

    return PremiumScaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Back',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Select an area'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                'STEP 1 OF 3',
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What would you like\nto measure?',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 34),
                ),
                const SizedBox(height: 10),
                Text(
                  'Choose one room or utility. You can add the others after saving this reading.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 18),
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search rooms and utilities',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 120),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.76,
              ),
              itemBuilder: (context, index) {
                final category = filtered[index];
                return _CategoryCard(
                  category: category,
                  selected: selected?.id == category.id,
                  onTap: () => ref
                      .read(analysisControllerProvider.notifier)
                      .selectCategory(category),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(22, 0, 6, 6),
        child: PrimaryButton(
          label: selected == null ? 'Select an area to continue' : 'Measure ${selected.name}',
          icon: Icons.arrow_forward_rounded,
          onPressed: selected == null ? null : () => context.push('/analysis/compass'),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final VastuCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? AppColors.deepNavy : AppColors.warmWhite,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? AppColors.gold : AppColors.outline,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.midnight.withValues(alpha: selected ? 0.16 : 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.10)
                          : AppColors.gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      category.icon,
                      color: selected ? AppColors.lightGold : AppColors.gold,
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: selected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            key: ValueKey('selected'),
                            color: AppColors.emerald,
                          )
                        : const SizedBox.square(
                            key: ValueKey('not-selected'),
                            dimension: 24,
                          ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                category.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? Colors.white : AppColors.ink,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                category.hindiName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected ? Colors.white60 : AppColors.muted,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                category.scheme == DirectionScheme.entrance32
                    ? '32 entrance padas'
                    : '16 direction zones',
                style: TextStyle(
                  color: selected ? AppColors.lightGold : AppColors.blue,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
