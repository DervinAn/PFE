import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';

// ─── App Button ──────────────────────────────────────────────
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Widget? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.foregroundColor,
    this.icon,
    this.width,
    this.height = AppSizes.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.white,
            ),
          )
        : icon != null
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon!,
              const SizedBox(width: AppSizes.sm),
              Text(label),
            ],
          )
        : Text(label);

    if (isOutlined) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? AppColors.primary,
            side: BorderSide(color: foregroundColor ?? AppColors.primary),
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: foregroundColor ?? AppColors.white,
        ),
        child: child,
      ),
    );
  }
}

// ─── App Text Field ──────────────────────────────────────────
class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.keyboardType,
    this.prefixIcon,
    this.validator,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: AppSizes.fontMd,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.sm),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscure,
          keyboardType: widget.keyboardType,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          validator: widget.validator,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: AppSizes.fontMd,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: widget.prefixIcon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                    ),
                    child: widget.prefixIcon,
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 48),
            suffixIcon: widget.isPassword
                ? GestureDetector(
                    onTap: () => setState(() => _obscure = !_obscure),
                    child: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                      size: AppSizes.iconMd,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

// ─── Status Badge ────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? backgroundColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.sm, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: AppSizes.fontXs,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ─── Section Header ──────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
        if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: AppSizes.fontMd,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Avatar Widget ───────────────────────────────────────────
class AppAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  final bool hasActiveDot;
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 56,
    this.hasActiveDot = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight, width: 2),
              color: AppColors.primaryLight,
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitials(),
                    )
                  : _buildInitials(),
            ),
          ),
          if (hasActiveDot)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: size * 0.22,
                height: size * 0.22,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    final initials = name.trim().isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: size * 0.32,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── Shimmer Loader ──────────────────────────────────────────
class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppSizes.radiusMd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ─── Bottom Nav Bar ──────────────────────────────────────────
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<BottomNavItem> items;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AppSizes.bottomNavHeight,
          child: Row(
            children: items.asMap().entries.map((e) {
              final isActive = e.key == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(e.key),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive ? e.value.activeIcon : e.value.icon,
                        color: isActive
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        e.value.label,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const List<BottomNavItem> kMainBottomNavItems = [
  BottomNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home,
    label: 'Home',
  ),
  BottomNavItem(
    icon: Icons.calendar_today_outlined,
    activeIcon: Icons.calendar_today,
    label: 'Schedule',
  ),
  BottomNavItem(
    icon: Icons.notifications_outlined,
    activeIcon: Icons.notifications,
    label: 'Alerts',
  ),
  BottomNavItem(
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: 'Profile',
  ),
];

Future<void> handleMainBottomNavTap(
  BuildContext context, {
  required int index,
  required int currentIndex,
  String? preferredChildId,
}) async {
  if (index == currentIndex) return;

  if (index == 0) {
    context.go(AppRoutes.home);
    return;
  }
  if (index == 1) {
    var childId = preferredChildId;
    if (childId == null || childId.trim().isEmpty) {
      childId = await LocalAppStorage.instance.getPreferredChildId();
    }
    if (!context.mounted) return;
    if (childId == null || childId.trim().isEmpty) {
      context.push(AppRoutes.addChildProfile);
    } else {
      context.go('/vaccine-schedule/$childId');
    }
    return;
  }
  if (index == 2) {
    context.go(AppRoutes.notifications);
    return;
  }
  context.go(AppRoutes.profile);
}
