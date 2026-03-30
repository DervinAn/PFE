import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';
import '../../../domain/entities/user_entity.dart';
import '../../widgets/common/common_widgets.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _tabIndex = 0;
  bool _loading = true;
  List<NotificationEntity> _notifications = const [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final list = await LocalAppStorage.instance.getNotifications();
    if (!mounted) return;
    setState(() {
      _notifications = list;
      _loading = false;
    });
  }

  List<NotificationEntity> get _visible {
    if (_tabIndex == 0) return _notifications;
    if (_tabIndex == 1) return _notifications.where((n) => !n.isRead).toList();
    return _notifications.where((n) => n.isRead).toList();
  }

  Future<void> _markRead(NotificationEntity n) async {
    await LocalAppStorage.instance.markNotificationRead(n.id);
    await _loadNotifications();
  }

  Future<void> _dismiss(NotificationEntity n) async {
    await LocalAppStorage.instance.dismissNotification(n.id);
    await _loadNotifications();
  }

  Future<void> _openSchedule(NotificationEntity n) async {
    await _markRead(n);
    if (!mounted) return;
    final parts = n.id.split('|');
    final childId = parts.isNotEmpty && parts.first.isNotEmpty
        ? parts.first
        : await LocalAppStorage.instance.getPreferredChildId();
    if (!mounted) return;
    if (childId == null || childId.isEmpty) {
      context.push(AppRoutes.addChildProfile);
      return;
    }
    context.push('/vaccine-schedule/$childId');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Alerts'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.md,
                    vertical: AppSizes.sm,
                  ),
                  child: Row(
                    children: [
                      _TabChip(
                        label: 'All',
                        active: _tabIndex == 0,
                        onTap: () => setState(() => _tabIndex = 0),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      _TabChip(
                        label: 'Unread',
                        active: _tabIndex == 1,
                        onTap: () => setState(() => _tabIndex = 1),
                      ),
                      const SizedBox(width: AppSizes.sm),
                      _TabChip(
                        label: 'History',
                        active: _tabIndex == 2,
                        onTap: () => setState(() => _tabIndex = 2),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: _visible.isEmpty
                      ? const Center(
                          child: Text(
                            'No alerts to show',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppSizes.md),
                          itemCount: _visible.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: AppSizes.md),
                          itemBuilder: (context, index) {
                            final item = _visible[index];
                            return _AlertCard(
                              item: item,
                              onOpen: () => _openSchedule(item),
                              onDismiss: () => _dismiss(item),
                            );
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 2,
        onTap: (index) =>
            handleMainBottomNavTap(context, index: index, currentIndex: 2),
        items: kMainBottomNavItems,
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final NotificationEntity item;
  final VoidCallback onOpen;
  final VoidCallback onDismiss;

  const _AlertCard({
    required this.item,
    required this.onOpen,
    required this.onDismiss,
  });

  Color get _priorityColor {
    switch (item.priority) {
      case NotificationPriority.urgent:
        return AppColors.error;
      case NotificationPriority.dueSoon:
        return AppColors.warning;
      case NotificationPriority.info:
        return AppColors.info;
      case NotificationPriority.success:
        return AppColors.success;
    }
  }

  String get _badge {
    switch (item.priority) {
      case NotificationPriority.urgent:
        return 'URGENT';
      case NotificationPriority.dueSoon:
        return 'DUE SOON';
      case NotificationPriority.info:
        return 'INFO';
      case NotificationPriority.success:
        return 'DONE';
    }
  }

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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _priorityColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.notifications_active,
                  color: _priorityColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      item.body,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: AppSizes.fontSm,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: _badge, color: _priorityColor),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onOpen,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _priorityColor,
                  ),
                  child: const Text('Open Schedule'),
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              OutlinedButton(
                onPressed: onDismiss,
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
