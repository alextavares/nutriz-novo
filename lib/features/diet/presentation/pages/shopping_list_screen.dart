import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/monetization/promo_offer.dart';
import '../../../../core/platform/platform_share.dart';
import '../../../premium/presentation/providers/subscription_provider.dart';
import '../../domain/models/diet_meal.dart';
import '../../domain/models/diet_plan.dart';
import '../../domain/services/shopping_list_builder.dart';
import '../providers/diet_providers.dart';

enum ShoppingListScope { day, week }

class ShoppingListScreen extends ConsumerStatefulWidget {
  const ShoppingListScreen({super.key});

  @override
  ConsumerState<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends ConsumerState<ShoppingListScreen> {
  ShoppingListScope? _scope;

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(subscriptionProvider).isPro;
    final weekAsync = ref.watch(dietWeekProvider);
    final catalogAsync = ref.watch(dietCatalogProvider);
    final selectedDay = ref.watch(dietSelectedDayProvider);

    final today = DateUtils.dateOnly(DateTime.now());
    final effectiveDay = isPro ? DateUtils.dateOnly(selectedDay) : today;

    final scope = _scope ?? (isPro ? ShoppingListScope.week : ShoppingListScope.day);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de compras'),
        actions: [
          IconButton(
            tooltip: 'Copiar',
            onPressed: () async {
              final text = await _buildText(scope, effectiveDay);
              if (text == null) return;
              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Lista copiada.')),
              );
            },
            icon: const Icon(Icons.copy_all_rounded),
          ),
          IconButton(
            tooltip: 'WhatsApp',
            onPressed: () async {
              final text = await _buildText(scope, effectiveDay);
              if (text == null) return;
              final ok = await PlatformShare.shareWhatsApp(text);
              if (ok) return;
              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copiado. Abra o WhatsApp e cole para enviar.'),
                ),
              );
            },
            icon: const Icon(Icons.chat_rounded),
          ),
          IconButton(
            tooltip: 'Compartilhar',
            onPressed: () async {
              final text = await _buildText(scope, effectiveDay);
              if (text == null) return;
              final ok = await PlatformShare.shareText(text);
              if (ok) return;
              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copiado para compartilhar.')),
              );
            },
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: weekAsync.when(
        data: (week) {
          final catalog = catalogAsync.asData?.value ?? const <DietMeal>[];
          final byId = {for (final m in catalog) m.id: m};

          final ingredients = <String>[];
          final mealCount = _collectIngredients(
            week: week,
            byId: byId,
            scope: scope,
            day: effectiveDay,
            out: ingredients,
          );

          final items = ShoppingListBuilder(ingredients).build();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _ScopeToggle(
                scope: scope,
                isPro: isPro,
                onChange: (next) {
                  if (next == ShoppingListScope.week && !isPro) {
                    _openPaywall(context);
                    return;
                  }
                  setState(() => _scope = next);
                },
              ),
              const SizedBox(height: 12),
              _SummaryCard(
                scope: scope,
                day: effectiveDay,
                itemCount: items.length,
                mealCount: mealCount,
              ),
              const SizedBox(height: 12),
              if (!isPro && scope == ShoppingListScope.week)
                _LockedWeekCard(onTap: () => _openPaywall(context)),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Center(child: Text('Sem itens para listar.')),
                ),
              for (final item in items) _ShoppingItemTile(item: item),
              const SizedBox(height: 12),
              Text(
                'Dica: revise os itens e ajuste quantidades conforme sua porção.',
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }

  Future<String?> _buildText(ShoppingListScope scope, DateTime day) async {
    final week = await ref.read(dietWeekProvider.future);
    final catalog = await ref.read(dietCatalogProvider.future);
    final byId = {for (final m in catalog) m.id: m};
    final ingredients = <String>[];
    final mealCount = _collectIngredients(
      week: week,
      byId: byId,
      scope: scope,
      day: day,
      out: ingredients,
    );
    final items = ShoppingListBuilder(ingredients).build();
    if (items.isEmpty) return null;

    final title = scope == ShoppingListScope.week
        ? 'Lista de compras da semana'
        : 'Lista de compras do dia ${day.day}/${day.month}';

    final lines = <String>[
      title,
      'Refeições consideradas: $mealCount',
      '',
      for (final i in items) '- ${i.displayName} (x${i.count})',
      '',
      'Gerado no NutriZ',
    ];
    return lines.join('\n');
  }

  void _openPaywall(BuildContext context) {
    ref.read(promoOfferProvider.notifier).ensureActive(
      duration: const Duration(minutes: 10),
      discountPercent: 75,
      source: 'shopping_list_locked',
    );
    context.push('/premium');
  }

  int _collectIngredients({
    required DietPlanWeek week,
    required Map<String, DietMeal> byId,
    required ShoppingListScope scope,
    required DateTime day,
    required List<String> out,
  }) {
    Iterable<DietPlanDay> days = week.days;
    if (scope == ShoppingListScope.day) {
      days = days.where((d) => DateUtils.isSameDay(d.date, day));
    }

    var mealCount = 0;
    for (final d in days) {
      for (final type in DietMealType.values) {
        final id = d.mealIdsByType[type];
        if (id == null || id.isEmpty) continue;
        final meal = byId[id];
        if (meal == null) continue;
        mealCount += 1;
        out.addAll(meal.ingredients);
      }
    }
    return mealCount;
  }
}

class _ScopeToggle extends StatelessWidget {
  final ShoppingListScope scope;
  final bool isPro;
  final ValueChanged<ShoppingListScope> onChange;

  const _ScopeToggle({
    required this.scope,
    required this.isPro,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ShoppingListScope>(
      segments: const [
        ButtonSegment(
          value: ShoppingListScope.day,
          label: Text('Hoje'),
          icon: Icon(Icons.today),
        ),
        ButtonSegment(
          value: ShoppingListScope.week,
          label: Text('Semana'),
          icon: Icon(Icons.calendar_view_week),
        ),
      ],
      selected: {scope},
      showSelectedIcon: false,
      onSelectionChanged: (set) => onChange(set.first),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ShoppingListScope scope;
  final DateTime day;
  final int itemCount;
  final int mealCount;

  const _SummaryCard({
    required this.scope,
    required this.day,
    required this.itemCount,
    required this.mealCount,
  });

  @override
  Widget build(BuildContext context) {
    final title = scope == ShoppingListScope.week
        ? 'Semana'
        : 'Dia ${day.day}/${day.month}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          Text(
            '$itemCount itens • $mealCount refeições',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _LockedWeekCard extends StatelessWidget {
  final VoidCallback onTap;

  const _LockedWeekCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        ),
        child: const Row(
          children: [
            Expanded(
              child: Text(
                'Desbloqueie a lista da semana no Premium.',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            Icon(Icons.lock, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}

class _ShoppingItemTile extends StatelessWidget {
  final ShoppingListItem item;

  const _ShoppingItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final subtitle =
        item.examples.isEmpty ? null : item.examples.take(2).join(' • ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
      ),
      child: ListTile(
        dense: true,
        title: Text(
          item.displayName,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            'x${item.count}',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

