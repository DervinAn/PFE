import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/vaccine_entity.dart';
import '../../widgets/common/common_widgets.dart';

class VaccineSchedulePage extends StatefulWidget {
  final String childId;
  const VaccineSchedulePage({super.key, required this.childId});

  @override
  State<VaccineSchedulePage> createState() => _VaccineSchedulePageState();
}

class _VaccineSchedulePageState extends State<VaccineSchedulePage> {
  final List<Map<String, String>> _filters = const [
    {'label': 'All Vaccines', 'value': 'all'},
    {'label': 'Mandatory', 'value': 'mandatory'},
    {'label': 'Optional', 'value': 'optional'},
    {'label': 'Travel', 'value': 'travel'},
  ];

  int _selectedFilter = 0;
  bool _loading = true;
  String _activeChildId = '';
  ChildEntity? _child;
  List<VaccineScheduleGroup> _schedule = const [];

  @override
  void initState() {
    super.initState();
    _activeChildId = widget.childId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final children = await LocalAppStorage.instance.getChildren();
    if (children.isEmpty) {
      if (!mounted) return;
      setState(() {
        _child = null;
        _schedule = const [];
        _loading = false;
      });
      return;
    }

    final exists = children.any((c) => c.id == _activeChildId);
    if (!exists) _activeChildId = children.first.id;
    await LocalAppStorage.instance.setActiveChildId(_activeChildId);
    final child = children.firstWhere((c) => c.id == _activeChildId);
    final filter = _filters[_selectedFilter]['value']!;
    final schedule = await LocalAppStorage.instance.getComputedSchedule(
      _activeChildId,
      filter: filter,
    );

    if (!mounted) return;
    setState(() {
      _child = child;
      _schedule = schedule;
      _loading = false;
    });
  }

  Color _groupColor(VaccineStatus status) {
    switch (status) {
      case VaccineStatus.done:
        return AppColors.success;
      case VaccineStatus.overdue:
        return AppColors.error;
      case VaccineStatus.dueSoon:
        return AppColors.warning;
      case VaccineStatus.upcoming:
        return AppColors.info;
      default:
        return AppColors.textTertiary;
    }
  }

  void _openRecord(VaccineEntity vaccine) {
    context
        .push(
          '${AppRoutes.recordVaccination}?childId=$_activeChildId&doseId=${vaccine.plannedDoseId ?? vaccine.id}',
        )
        .then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _child == null
            ? _buildNoChildState()
            : _buildContent(),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) => handleMainBottomNavTap(
          context,
          index: index,
          currentIndex: 1,
          preferredChildId: _activeChildId,
        ),
        items: kMainBottomNavItems,
      ),
    );
  }

  Widget _buildNoChildState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.child_care_outlined,
              size: 52,
              color: AppColors.primary,
            ),
            const SizedBox(height: AppSizes.sm),
            const Text(
              'No child profile found',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: AppSizes.fontXl,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            const Text(
              'Add a child profile first to generate the vaccination calendar.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.md),
            AppButton(
              label: 'Add Child Profile',
              onPressed: () => context.push(AppRoutes.addChildProfile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final child = _child!;
    return Column(
      children: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: const Icon(Icons.arrow_back, size: 18),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Vaccination Calendar',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: AppSizes.fontXl,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push(AppRoutes.notifications),
                child: const Icon(Icons.notifications_outlined),
              ),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: Row(
                      children: [
                        AppAvatar(name: child.name, size: 64),
                        const SizedBox(width: AppSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                child.name,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: AppSizes.fontXl,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: AppSizes.xs),
                              Text(
                                '${child.ageDisplay} old',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                  child: Row(
                    children: _filters.asMap().entries.map((entry) {
                      final index = entry.key;
                      final f = entry.value;
                      final isActive = index == _selectedFilter;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilter = index);
                          _loadData();
                        },
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
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          child: Text(
                            f['label']!,
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
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSizes.md)),
              if (_schedule.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.md),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      ),
                      child: const Text(
                        'No doses available for this filter.',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final group = _schedule[index];
                    return _TimelineGroup(
                      group: group,
                      color: _groupColor(group.groupStatus),
                      onConfirm: _openRecord,
                    );
                  }, childCount: _schedule.length),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineGroup extends StatelessWidget {
  final VaccineScheduleGroup group;
  final Color color;
  final ValueChanged<VaccineEntity> onConfirm;

  const _TimelineGroup({
    required this.group,
    required this.color,
    required this.onConfirm,
  });

  String _statusLabel(VaccineEntity vaccine) {
    if (vaccine.windowMissed) return 'MISSED WINDOW';
    final s = vaccine.status;
    switch (s) {
      case VaccineStatus.done:
        return 'DONE';
      case VaccineStatus.overdue:
        return 'OVERDUE';
      case VaccineStatus.dueSoon:
        return 'DUE SOON';
      case VaccineStatus.upcoming:
        return 'UPCOMING';
      default:
        return '';
    }
  }

  IconData _statusIcon(VaccineEntity vaccine) {
    if (vaccine.windowMissed) return Icons.block;
    final s = vaccine.status;
    switch (s) {
      case VaccineStatus.done:
        return Icons.check_circle;
      case VaccineStatus.overdue:
        return Icons.warning_rounded;
      case VaccineStatus.dueSoon:
        return Icons.access_time;
      case VaccineStatus.upcoming:
        return Icons.hourglass_bottom;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 14,
            height: 14,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      group.ageGroup,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      group.dateLabel,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.textTertiary,
                        fontSize: AppSizes.fontSm,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.sm),
                ...group.vaccines.map((v) {
                  final canConfirm =
                      v.status != VaccineStatus.done && v.canAdminister;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.sm),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.md),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: Border(
                          left: BorderSide(color: color, width: 3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  v.name,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  v.disease,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    color: AppColors.textSecondary,
                                    fontSize: AppSizes.fontSm,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Icon(_statusIcon(v), color: color, size: 18),
                              const SizedBox(height: 2),
                              Text(
                                _statusLabel(v),
                                style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: AppSizes.fontXs,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              ),
                              if (canConfirm)
                                TextButton(
                                  onPressed: () => onConfirm(v),
                                  style: TextButton.styleFrom(
                                    minimumSize: const Size(0, 30),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 0,
                                    ),
                                  ),
                                  child: const Text('Confirm'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
