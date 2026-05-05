import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/platform/android_settings_channel.dart';
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
  String _languageCode = 'en';
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
    final languageCode = await LocalAppStorage.instance.getLanguageCode();
    if (!mounted) return;
    setState(() {
      _fullName = user['name'] ?? 'Parent';
      _email = user['email'] ?? 'No email saved';
      _phone = user['phone'] ?? 'No phone saved';
      _notificationsEnabled = notificationsEnabled;
      _languageCode = languageCode;
      _notificationTestHint = context.l10n.testNotificationHint;
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
        title: Text(context.l10n.profileTitle),
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
              label: context.l10n.account,
              children: [
                _SettingsTile(
                  icon: Icons.person_outline,
                  title: context.l10n.personalInformation,
                  subtitle: '$_fullName • $_phone',
                  onTap: _editPersonalInfo,
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.group_outlined,
                  title: context.l10n.childrenManagement,
                  subtitle: context.l10n.childrenManagementSubtitle,
                  onTap: () => context.push(AppRoutes.childrenProfiles),
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.badge_outlined,
                  title: context.l10n.vaccinationCard,
                  subtitle: context.l10n.vaccinationCardSubtitle,
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
              label: context.l10n.preferences,
              children: [
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: context.l10n.notifications,
                  subtitle: _notificationsEnabled
                      ? context.l10n.enabled
                      : context.l10n.disabled,
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (v) async {
                      setState(() => _notificationsEnabled = v);
                      await LocalAppStorage.instance.setNotificationsEnabled(v);
                      await LocalNotificationService.instance
                          .resyncVaccineReminders();
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.settings_outlined,
                  title: context.l10n.openNotificationSettings,
                  subtitle: context.l10n.notificationsHelpBody,
                  onTap: _openNotificationSettings,
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.schedule_outlined,
                  title: context.l10n.exactAlarmSettings,
                  subtitle: context.l10n.notificationSettingsSavedHint,
                  onTap: _openExactAlarmSettings,
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.schedule_outlined,
                  title: context.l10n.testNotification,
                  subtitle: _notificationTestHint,
                  onTap: _scheduleTestNotification,
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.notification_important_outlined,
                  title: context.l10n.sendTestNow,
                  subtitle: context.l10n.testNotificationHint,
                  onTap: _sendNowTestNotification,
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.translate_outlined,
                  title: context.l10n.language,
                  subtitle:
                      '${context.l10n.languageEnglish}, ${context.l10n.languageArabic}, ${context.l10n.languageFrench}',
                  trailing: GestureDetector(
                    onTap: () => _showLanguagePicker(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.languageNameFor(_languageCode),
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
              label: context.l10n.appInformation,
              children: [
                _SettingsTile(
                  icon: Icons.shield_outlined,
                  title: context.l10n.privacyPolicyTitle,
                  onTap: _showPrivacyPolicy,
                ),
                const Divider(height: 1, indent: 60),
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: context.l10n.aboutAppTitle,
                  subtitle: context.l10n.appVersionLabel,
                  onTap: _showAbout,
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
                  label: Text(
                    context.l10n.logout,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                      fontSize: AppSizes.fontLg,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.3),
                    ),
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
        items: mainBottomNavItems(context),
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
          children: const ['en', 'ar', 'fr'].map((code) {
            final isSelected = code == _languageCode;
            return ListTile(
              title: Text(
                context.l10n.languageNameFor(code),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () async {
                final navigator = Navigator.of(ctx);
                setState(() => _languageCode = code);
                await AppLocaleController.instance.setLanguageCode(code);
                await _loadUser();
                await LocalNotificationService.instance
                    .resyncVaccineReminders();
                navigator.pop();
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
    final l10n = context.l10n;
    final timeLabel = time.format(context);
    final dateLabel = '${date.day}/${date.month}/${date.year}';
    final messenger = ScaffoldMessenger.of(context);

    if (!scheduledAt.isAfter(now)) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.futureDate)));
      return;
    }

    try {
      final id = await LocalNotificationService.instance
          .scheduleTestNotification(
            scheduledAt: scheduledAt,
            title: l10n.testReminderTitle,
            body: '${l10n.scheduledTest}: $timeLabel $dateLabel',
          );
      final pendingCount = await LocalNotificationService.instance
          .getPendingCount();
      final exactEnabled = await LocalNotificationService.instance
          .canScheduleExactAlarms();
      if (!mounted) return;
      setState(() {
        _notificationTestHint =
            '${l10n.scheduledTest}: $dateLabel $timeLabel (${l10n.pendingScheduledNotifications}: $pendingCount)';
      });
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            exactEnabled == false
                ? '${l10n.scheduledTest} #$id ($pendingCount). ${l10n.notificationSettingsSavedHint}'
                : '${l10n.scheduledTest} #$id. ${l10n.pendingScheduledNotifications}: $pendingCount',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is StateError ? error.message : error.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _sendNowTestNotification() async {
    await LocalNotificationService.instance.showNowTestNotification(
      body:
          '${context.l10n.immediateTestAt} ${TimeOfDay.now().format(context)}',
    );
    final pendingCount = await LocalNotificationService.instance
        .getPendingCount();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${context.l10n.immediateTestSent}. ${context.l10n.pendingScheduledNotifications}: $pendingCount',
        ),
      ),
    );
  }

  Future<void> _openNotificationSettings() async {
    final opened = await AndroidSettingsChannel.openNotificationSettings();
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.settingsUnavailable)));
    }
  }

  Future<void> _openExactAlarmSettings() async {
    final opened = await AndroidSettingsChannel.openExactAlarmSettings();
    if (!mounted) return;
    if (!opened) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.settingsUnavailable)));
    }
  }

  Future<void> _editPersonalInfo() async {
    final nameController = TextEditingController(text: _fullName);
    final phoneController = TextEditingController(
      text: _phone == 'No phone saved' ? '' : _phone,
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.editPersonalInformation),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: context.l10n.fullName),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: context.l10n.phoneNumber),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.save),
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
    ).showSnackBar(SnackBar(content: Text(context.l10n.profileUpdated)));
  }

  Future<void> _showPrivacyPolicy() async {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.privacyPolicyTitle),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.privacyIntro),
              const SizedBox(height: AppSizes.md),
              Text(
                context.l10n.privacyDataTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(context.l10n.privacyDataBody),
              const SizedBox(height: AppSizes.md),
              Text(
                context.l10n.privacyUseTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(context.l10n.privacyUseBody),
              const SizedBox(height: AppSizes.md),
              Text(
                context.l10n.privacyContactTitle,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(context.l10n.privacyContactBody),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _showAbout() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    showAboutDialog(
      context: context,
      applicationName: context.l10n.appName,
      applicationVersion: packageInfo.version,
      applicationLegalese: context.l10n.aboutBody,
      children: [
        const SizedBox(height: AppSizes.sm),
        Text(context.l10n.notificationsHelpBody),
      ],
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        ),
        title: Text(
          context.l10n.confirmLogoutTitle,
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
        ),
        content: Text(context.l10n.confirmLogoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await LocalAppStorage.instance.logout();
              if (!mounted) return;
              context.go(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text(
              context.l10n.logout,
              style: const TextStyle(color: AppColors.white),
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
