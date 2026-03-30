import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/local_notification_service.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';
import '../../widgets/common/common_widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _notificationsEnabled = true;
  String _language = 'English';
  String _fullName = 'Parent';
  String _email = 'No email saved';
  String _phone = 'No phone saved';
  String _notificationTestHint = 'Pick a date and time to test popup';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await LocalAppStorage.instance.getSignedInUser();
    final notificationsEnabled = await LocalAppStorage.instance
        .getNotificationsEnabled();
    if (!mounted) return;
    setState(() {
      _fullName = user['name'] ?? 'Parent';
      _email = user['email'] ?? 'No email saved';
      _phone = user['phone'] ?? 'No phone saved';
      _notificationsEnabled = notificationsEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: const Icon(Icons.arrow_back),
        ),
        title: const Text('Profile & Settings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppSizes.lg),
            // Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                AppAvatar(name: _fullName, size: 90),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: AppColors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Text(
              _fullName,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSizes.xs),
            Text(
              _email,
              style: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSizes.xl),

            // Account section
            _SettingsSection(
              label: 'ACCOUNT',
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Personal Information',
                  subtitle: '$_fullName • $_phone',
                  onTap: _editPersonalInfo,
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.group_outlined,
                  title: 'Children Management',
                  subtitle: 'Add or edit children profiles',
                  onTap: () => context.push(AppRoutes.childrenProfiles),
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.badge_outlined,
                  title: 'Vaccination Card',
                  subtitle: 'Open, print or share official card',
                  onTap: () async {
                    final childId = await LocalAppStorage.instance
                        .getPreferredChildId();
                    if (!context.mounted) return;
                    if (childId == null || childId.isEmpty) {
                      context.push(AppRoutes.addChildProfile);
                      return;
                    }
                    context.push('/vaccination-card/$childId');
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // Preferences section
            _SettingsSection(
              label: 'PREFERENCES',
              children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (v) async {
                      setState(() => _notificationsEnabled = v);
                      await LocalAppStorage.instance.setNotificationsEnabled(v);
                    },
                    activeColor: AppColors.primary,
                  ),
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.schedule_outlined,
                  title: 'Test Notification',
                  subtitle: _notificationTestHint,
                  onTap: _scheduleTestNotification,
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.notification_important_outlined,
                  title: 'Send Test Now',
                  subtitle: 'Show an immediate test notification',
                  onTap: _sendNowTestNotification,
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.translate_outlined,
                  title: 'Language',
                  subtitle: 'English, Arabic, French',
                  trailing: GestureDetector(
                    onTap: () => _showLanguagePicker(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _language,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSizes.md),

            // App info section
            _SettingsSection(
              label: 'APP INFORMATION',
              children: [
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: 'Privacy Policy',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About VacciTrack',
                  subtitle: 'Version 2.4.0',
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: AppSizes.xl),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: SizedBox(
                width: double.infinity,
                height: AppSizes.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmLogout(),
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                      fontSize: AppSizes.fontLg,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withOpacity(0.3)),
                    backgroundColor: AppColors.errorLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.xxl),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) =>
            handleMainBottomNavTap(context, index: index, currentIndex: 3),
        items: kMainBottomNavItems,
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['English', 'Arabic', 'French'].map((lang) {
            final isSelected = lang == _language;
            return ListTile(
              title: Text(
                lang,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() => _language = lang);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _scheduleTestNotification() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 1))),
    );
    if (time == null || !mounted) return;

    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (!scheduledAt.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a future date & time.')),
      );
      return;
    }

    try {
      final id = await LocalNotificationService.instance
          .scheduleTestNotification(
        scheduledAt: scheduledAt,
        title: 'VacciTrack Test Reminder',
        body:
            'Scheduled for ${time.format(context)} on ${date.day}/${date.month}/${date.year}',
      );
      final pendingCount = await LocalNotificationService.instance
          .getPendingCount();
      final exactEnabled = await LocalNotificationService.instance
          .canScheduleExactAlarms();
      if (!mounted) return;
      setState(() {
        _notificationTestHint =
            'Scheduled for ${date.day}/${date.month}/${date.year} at ${time.format(context)} (pending: $pendingCount)';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            exactEnabled == false
                ? 'Scheduled test #$id (pending: $pendingCount). Exact alarm is off on this phone, so timing may be delayed.'
                : 'Scheduled test #$id. Pending notifications: $pendingCount',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is StateError ? error.message : error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _sendNowTestNotification() async {
    await LocalNotificationService.instance.showNowTestNotification(
      body: 'Immediate test at ${TimeOfDay.now().format(context)}',
    );
    final pendingCount = await LocalNotificationService.instance
        .getPendingCount();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Immediate test sent. Pending scheduled notifications: $pendingCount',
        ),
      ),
    );
  }

  Future<void> _editPersonalInfo() async {
    final nameController = TextEditingController(text: _fullName);
    final phoneController = TextEditingController(
      text: _phone == 'No phone saved' ? '' : _phone,
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Personal Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    await LocalAppStorage.instance.updateSignedInUser(
      fullName: nameController.text.trim(),
      phone: phoneController.text.trim(),
    );
    await _loadUser();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: const Text(
          'Logout',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await LocalAppStorage.instance.logout();
              if (!mounted) return;
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String label;
  final List<Widget> children;

  const _SettingsSection({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.xs,
              bottom: AppSizes.sm,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: AppSizes.fontXs,
                fontWeight: FontWeight.w700,
                color: AppColors.textTertiary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontSize: AppSizes.fontMd,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: AppSizes.fontSm,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.textTertiary)
              : null),
      onTap: onTap,
    );
  }
}
