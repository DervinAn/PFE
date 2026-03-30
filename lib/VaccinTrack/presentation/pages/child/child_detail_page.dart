import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';
import '../../../domain/entities/child_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/vaccine_entity.dart';
import '../../widgets/common/common_widgets.dart';

class ChildDetailPage extends StatefulWidget {
  final String? childId;
  const ChildDetailPage({super.key, this.childId});

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  String _parentName = 'Parent';
  List<ChildEntity> _children = const [];
  String _activeChildId = '';
  bool _hasUnreadAlerts = false;
  _UrgentTask? _urgentTask;
  List<_ActivityEntry> _recentActivities = const [];

  ChildEntity? get _activeChild {
    for (final c in _children) {
      if (c.id == _activeChildId) return c;
    }
    if (_children.isEmpty) return null;
    return _children.first;
  }

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  @override
  void didUpdateWidget(covariant ChildDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.childId != widget.childId) {
      _loadDashboardData();
    }
  }

  Future<void> _loadDashboardData() async {
    final user = await LocalAppStorage.instance.getSignedInUser();
    final children = await LocalAppStorage.instance.getChildren();
    final notifications = await LocalAppStorage.instance.getNotifications();
    final history = await LocalAppStorage.instance.getVaccinationHistory();
    final hasUnreadAlerts = notifications.any((n) => !n.isRead);
    final preferredId = widget.childId?.trim();
    final storedPreferredId = await LocalAppStorage.instance
        .getPreferredChildId();
    var activeChildId = '';
    if (children.isNotEmpty) {
      if (preferredId != null &&
          preferredId.isNotEmpty &&
          children.any((c) => c.id == preferredId)) {
        activeChildId = preferredId;
      } else if (storedPreferredId != null &&
          children.any((c) => c.id == storedPreferredId)) {
        activeChildId = storedPreferredId;
      } else {
        activeChildId = children.first.id;
      }
      await LocalAppStorage.instance.setActiveChildId(activeChildId);
    }
    final urgentTask = activeChildId.isEmpty
        ? null
        : await _resolveUrgentTask(activeChildId);
    final recentActivities = history
        .take(5)
        .map(_activityFromRecord)
        .toList(growable: false);

    if (!mounted) return;
    setState(() {
      _parentName = user['name'] ?? 'Parent';
      _children = children;
      _activeChildId = activeChildId;
      _hasUnreadAlerts = hasUnreadAlerts;
      _urgentTask = urgentTask;
      _recentActivities = recentActivities;
    });
  }

  Future<_UrgentTask?> _resolveUrgentTask(String childId) async {
    final schedule = await LocalAppStorage.instance.getComputedSchedule(childId);
    final candidates = <VaccineEntity>[];
    for (final group in schedule) {
      for (final vaccine in group.vaccines) {
        if (vaccine.status != VaccineStatus.overdue &&
            vaccine.status != VaccineStatus.dueSoon) {
          continue;
        }
        if (vaccine.recommendedAgeMonths == 0 && vaccine.windowMissed) {
          continue;
        }
        candidates.add(vaccine);
      }
    }
    if (candidates.isEmpty) return null;

    int statusWeight(VaccineStatus status) {
      if (status == VaccineStatus.overdue) return 0;
      if (status == VaccineStatus.dueSoon) return 1;
      return 2;
    }

    candidates.sort((a, b) {
      final byStatus = statusWeight(a.status).compareTo(
        statusWeight(b.status),
      );
      if (byStatus != 0) return byStatus;
      final aDate = a.scheduledDate ?? DateTime.now();
      final bDate = b.scheduledDate ?? DateTime.now();
      return aDate.compareTo(bDate);
    });

    final target = candidates.first;
    final scheduled = target.scheduledDate ?? DateTime.now();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduleDay = DateTime(scheduled.year, scheduled.month, scheduled.day);
    final daysFromToday = scheduleDay.difference(today).inDays;

    return _UrgentTask(
      childId: childId,
      plannedDoseId: target.plannedDoseId ?? target.id,
      vaccineLabel: '${target.name} (Dose ${target.doseNumber})',
      scheduledDate: scheduled,
      daysFromToday: daysFromToday,
      status: target.status,
    );
  }

  _ActivityEntry _activityFromRecord(VaccinationRecordEntity record) {
    final firstName = record.childName.split(' ').first;
    final clinic = (record.clinicName != null && record.clinicName!.isNotEmpty)
        ? ' at ${record.clinicName}'
        : '';
    return _ActivityEntry(
      icon: Icons.check_circle,
      iconColor: AppColors.primary,
      title: '${record.vaccineName} completed',
      subtitle: '$firstName received ${record.doseLabel.toLowerCase()}$clinic',
      timeAgo: _timeAgo(record.administeredDate),
    );
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 30) {
      final months = (diff.inDays / 30).floor();
      return '$months MONTH${months > 1 ? 'S' : ''} AGO';
    }
    if (diff.inDays >= 7) {
      final weeks = (diff.inDays / 7).floor();
      return '$weeks WEEK${weeks > 1 ? 'S' : ''} AGO';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays} DAY${diff.inDays > 1 ? 'S' : ''} AGO';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} HOUR${diff.inHours > 1 ? 'S' : ''} AGO';
    }
    return 'JUST NOW';
  }

  void _onBottomNavTap(int i) {
    handleMainBottomNavTap(
      context,
      index: i,
      currentIndex: 0,
      preferredChildId: _activeChildId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: _buildHomeTab()),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: _onBottomNavTap,
        items: kMainBottomNavItems,
      ),
    );
  }

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting header
                Row(
                  children: [
                    AppAvatar(name: _parentName, size: 44),
                    const SizedBox(width: AppSizes.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $_parentName 👋',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: AppSizes.fontXl,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _activeChild != null
                                ? "Ready for ${_activeChild!.name.split(' ').first}'s checkup?"
                                : 'Ready for checkup?',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: AppSizes.fontSm,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await context.push(AppRoutes.notifications);
                            await _loadDashboardData();
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        if (_hasUnreadAlerts)
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.md),

                // Child selector strip
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ..._children.asMap().entries.map((entry) {
                        final c = entry.value;
                        final nameParts = c.name.split(' ');
                        final label =
                            '${nameParts.first}, ${c.ageDisplay.split(' ').first}${c.ageDisplay.contains('year') ? 'y' : 'm'}';
                        final isActive =
                            c.id == _activeChildId ||
                            (_activeChildId.isEmpty && entry.key == 0);
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSizes.md),
                          child: _ChildChip(
                            name: label,
                            avatarName: c.name,
                            isActive: isActive,
                            badge: isActive
                                ? 'NEXT: ${c.nextVaccineName ?? 'Check'}'
                                : null,
                            onTap: () async {
                              setState(() {
                                _activeChildId = c.id;
                              });
                              await LocalAppStorage.instance.setActiveChildId(
                                c.id,
                              );
                              if (!mounted) return;
                              context.go('/child/${c.id}');
                            },
                          ),
                        );
                      }),
                      GestureDetector(
                        onTap: () async {
                          final result = await context.push(
                            AppRoutes.addChildProfile,
                          );
                          if (result != null) {
                            await _loadDashboardData();
                          }
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.divider,
                                  width: 1.5,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Add Child',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: AppSizes.fontXs,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSizes.lg),

                // Urgent task card
                _UrgentTaskCard(
                  task: _urgentTask,
                  onConfirm: () async {
                    final task = _urgentTask;
                    if (task == null) return;
                    final uri = Uri(
                      path: AppRoutes.recordVaccination,
                      queryParameters: {
                        'childId': task.childId,
                        'doseId': task.plannedDoseId,
                      },
                    );
                    await context.push(uri.toString());
                    await _loadDashboardData();
                  },
                  onOpenSchedule: () {
                    if (_activeChildId.isEmpty) {
                      context.push(AppRoutes.addChildProfile);
                      return;
                    }
                    context.push('/vaccine-schedule/$_activeChildId');
                  },
                ),
                const SizedBox(height: AppSizes.lg),

                // Quick actions grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: AppSizes.md,
                  mainAxisSpacing: AppSizes.md,
                  childAspectRatio: 1.4,
                  children: [
                    _QuickAction(
                      icon: Icons.calendar_today_rounded,
                      iconBg: AppColors.primaryLight,
                      iconColor: AppColors.primary,
                      label: 'Calendar',
                      onTap: () {
                        if (_activeChildId.isEmpty) {
                          context.push(AppRoutes.addChildProfile);
                          return;
                        }
                        context.push('/vaccine-schedule/$_activeChildId');
                      },
                    ),
                    _QuickAction(
                      icon: Icons.add_circle_outline,
                      iconBg: AppColors.successLight,
                      iconColor: AppColors.success,
                      label: 'Record Vaccine',
                      onTap: () => context.push(AppRoutes.recordVaccination),
                    ),
                    _QuickAction(
                      icon: Icons.history_rounded,
                      iconBg: const Color(0xFFEDE7F6),
                      iconColor: const Color(0xFF7C3AED),
                      label: 'History',
                      onTap: () => context.push(AppRoutes.vaccinationHistory),
                    ),
                    _QuickAction(
                      icon: Icons.menu_book_rounded,
                      iconBg: AppColors.errorLight,
                      iconColor: AppColors.error,
                      label: 'Guide',
                      onTap: () => context.push(AppRoutes.guide),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.lg),

                // Recent activity
                SectionHeader(
                  title: 'Recent Activity',
                  actionLabel: 'View All',
                  onAction: () => context.push(AppRoutes.vaccinationHistory),
                ),
                const SizedBox(height: AppSizes.md),
                if (_recentActivities.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                    child: const Text(
                      'No activity yet. Record a vaccine to see updates here.',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      for (int i = 0; i < _recentActivities.length; i++) ...[
                        _ActivityItem(
                          icon: _recentActivities[i].icon,
                          iconColor: _recentActivities[i].iconColor,
                          title: _recentActivities[i].title,
                          subtitle: _recentActivities[i].subtitle,
                          timeAgo: _recentActivities[i].timeAgo,
                        ),
                        if (i != _recentActivities.length - 1)
                          const Divider(height: AppSizes.xl, indent: 44),
                      ],
                    ],
                  ),
                const SizedBox(height: AppSizes.xxl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChildChip extends StatelessWidget {
  final String name;
  final String avatarName;
  final bool isActive;
  final String? badge;
  final VoidCallback? onTap;

  const _ChildChip({
    required this.name,
    required this.avatarName,
    required this.isActive,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: AppAvatar(name: avatarName, size: 52),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: AppSizes.fontXs,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UrgentTaskCard extends StatelessWidget {
  final _UrgentTask? task;
  final VoidCallback onConfirm;
  final VoidCallback onOpenSchedule;

  const _UrgentTaskCard({
    required this.task,
    required this.onConfirm,
    required this.onOpenSchedule,
  });

  Color get _accentColor =>
      task?.status == VaccineStatus.overdue ? AppColors.error : AppColors.accent;

  String _formatDate(DateTime date) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month]} ${date.day}, ${date.year}';
  }

  String get _countTopLabel {
    if (task == null) return '';
    if (task!.status == VaccineStatus.overdue) return 'LATE';
    if (task!.daysFromToday <= 0) return 'TODAY';
    return 'IN';
  }

  String get _countValue {
    if (task == null) return '';
    if (task!.daysFromToday <= 0) return '0';
    return '${task!.daysFromToday.abs()}';
  }

  String get _countBottomLabel {
    if (task == null) return '';
    if (task!.daysFromToday == 1) return 'DAY';
    return 'DAYS';
  }

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.success.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_outlined, color: AppColors.success),
            const SizedBox(width: AppSizes.sm),
            Expanded(
              child: Text(
                'No urgent task right now. Vaccines are on track.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: AppSizes.fontMd,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: _accentColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: Text(
                        'URGENT TASK',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w700,
                          color: _accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSizes.sm),
                    Text(
                      task!.vaccineLabel,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: AppSizes.fontXxl,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(task!.scheduledDate),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: AppSizes.fontSm,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _accentColor,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _countTopLabel,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: AppSizes.fontXs,
                        color: AppColors.white,
                      ),
                    ),
                    Text(
                      _countValue,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                        height: 1,
                      ),
                    ),
                    Text(
                      _countBottomLabel,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: AppSizes.fontXs,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                      ),
                    ),
                    child: Text(
                      task!.status == VaccineStatus.overdue
                          ? 'Record Now'
                          : 'Confirm Appointment',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              GestureDetector(
                onTap: onOpenSchedule,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    border: Border.all(color: _accentColor, width: 1.5),
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                  child: Icon(Icons.map_outlined, color: _accentColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.md),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: AppSizes.sm),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String timeAgo;

  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: AppSizes.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: AppSizes.fontXs,
                  color: AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UrgentTask {
  final String childId;
  final String plannedDoseId;
  final String vaccineLabel;
  final DateTime scheduledDate;
  final int daysFromToday;
  final VaccineStatus status;

  const _UrgentTask({
    required this.childId,
    required this.plannedDoseId,
    required this.vaccineLabel,
    required this.scheduledDate,
    required this.daysFromToday,
    required this.status,
  });
}

class _ActivityEntry {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String timeAgo;

  const _ActivityEntry({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.timeAgo,
  });
}
