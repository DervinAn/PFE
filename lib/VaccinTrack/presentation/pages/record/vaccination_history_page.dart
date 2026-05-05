import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';
import '../../../domain/entities/user_entity.dart';
import '../../widgets/common/common_widgets.dart';

class VaccinationHistoryPage extends StatefulWidget {
  const VaccinationHistoryPage({super.key});

  @override
  State<VaccinationHistoryPage> createState() => _VaccinationHistoryPageState();
}

class _VaccinationHistoryPageState extends State<VaccinationHistoryPage> {
  int _filterIndex = 0;
  static const List<String> _filterValues = [
    'all',
    'year',
    'month',
  ];
  bool _loading = true;
  List<VaccinationRecordEntity> _records = const [];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final records = await LocalAppStorage.instance.getVaccinationHistory();
    if (!mounted) return;
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  List<VaccinationRecordEntity> get _filteredRecords {
    if (_filterIndex == 0) return _records;
    final now = DateTime.now();
    if (_filterIndex == 1) {
      return _records
          .where((r) => r.administeredDate.year == now.year)
          .toList();
    }
    return _records
        .where(
          (r) =>
              r.administeredDate.year == now.year &&
              r.administeredDate.month == now.month,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filterLabels = [
      l10n.allRecords,
      l10n.thisYear,
      l10n.thisMonth,
    ];
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back),
        ),
        title: Text(l10n.vaccinationHistoryTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: AppColors.primary),
            onPressed: () {
              context
                  .push(AppRoutes.recordVaccination)
                  .then((_) => _loadRecords());
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: AppSizes.md),
                        const Icon(Icons.search, color: AppColors.textTertiary),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          l10n.vaccinationRecords,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: AppColors.textTertiary,
                            fontSize: AppSizes.fontMd,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Row(
                    children: _filterValues.asMap().entries.map((entry) {
                      final index = entry.key;
                      final label = filterLabels[index];
                      final isActive = index == _filterIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _filterIndex = index),
                        child: Container(
                          margin: const EdgeInsets.only(right: AppSizes.sm),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                            vertical: AppSizes.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: AppSizes.fontSm,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
                Expanded(
                  child: _filteredRecords.isEmpty
                      ? Center(
                          child: Text(
                            '${l10n.noVaccinationHistoryYet}\n${l10n.usePlusToAddFirstRecord}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.md,
                          ),
                          itemCount: _filteredRecords.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSizes.md),
                          itemBuilder: (context, index) {
                            final item = _filteredRecords[index];
                            return _RecordCard(item: item);
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) =>
            handleMainBottomNavTap(context, index: index, currentIndex: 0),
        items: mainBottomNavItems(context),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  final VaccinationRecordEntity item;
  const _RecordCard({required this.item});

  String get _dateLabel =>
      '${item.administeredDate.day}/${item.administeredDate.month}/${item.administeredDate.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Icon(
                  Icons.vaccines_rounded,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.vaccineName,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.doseLabel,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.textSecondary,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: context.l10n.completed, color: AppColors.success),
            ],
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            '$_dateLabel • ${item.childName}',
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: AppColors.textTertiary,
              fontSize: AppSizes.fontSm,
            ),
          ),
          if ((item.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              item.notes!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textSecondary,
                fontSize: AppSizes.fontSm,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
