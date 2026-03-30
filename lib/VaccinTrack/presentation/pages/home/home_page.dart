import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../core/utils/app_router.dart';
import '../../../domain/entities/child_entity.dart';
import '../../widgets/common/common_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChildEntity> _children = [];
  bool _loadingChildren = true;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final children = await LocalAppStorage.instance.getChildren();
    if (!mounted) return;
    setState(() {
      _children = children;
      _loadingChildren = false;
    });
  }

  String? get _primaryChildId =>
      _children.isNotEmpty ? _children.first.id : null;

  Future<void> _editChild(ChildEntity child) async {
    await context.push('/child-profile/edit/${child.id}');
    await _loadChildren();
  }

  Future<void> _deleteChild(ChildEntity child) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete child profile'),
        content: Text(
          'Are you sure you want to delete ${child.name} and all vaccination history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await LocalAppStorage.instance.deleteChild(child.id);
    if (!mounted) return;
    await _loadChildren();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${child.name} deleted')));
  }

  ChildEntity? get _nextDueChild {
    final withDate = _children
        .where((c) => c.nextVaccineDate != null && !c.isFullyProtected)
        .toList();
    if (withDate.isEmpty) return null;
    withDate.sort((a, b) => a.nextVaccineDate!.compareTo(b.nextVaccineDate!));
    return withDate.first;
  }

  String _dueLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(date.year, date.month, date.day);
    final days = due.difference(today).inDays;
    if (days <= 0) return 'today';
    if (days == 1) return 'tomorrow';
    return 'in $days days';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loadingChildren
            ? const Center(child: CircularProgressIndicator())
            : _buildChildrenTab(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.addChildProfile);
          await _loadChildren();
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) => handleMainBottomNavTap(
          context,
          index: index,
          currentIndex: 0,
          preferredChildId: _primaryChildId,
        ),
        items: kMainBottomNavItems,
      ),
    );
  }

  Widget _buildChildrenTab() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.md,
              AppSizes.md,
              AppSizes.md,
              0,
            ),
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: AppSizes.md),
                _buildSearchBar(),
                const SizedBox(height: AppSizes.lg),
                SectionHeader(
                  title: 'Your Children',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    child: Text(
                      '${_children.length} Profiles',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: AppSizes.fontSm,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSizes.md),
              ],
            ),
          ),
        ),
        if (_children.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Container(
                padding: const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.child_care_outlined,
                      size: 42,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSizes.sm),
                    const Text(
                      'No child profiles yet',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSizes.xs),
                    const Text(
                      'Tap the + button to create the first family child profile.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                0,
                AppSizes.md,
                AppSizes.md,
              ),
              child: _ChildCard(
                child: _children[index],
                onTap: () => context.push('/child/${_children[index].id}'),
                onEdit: () => _editChild(_children[index]),
                onDelete: () => _deleteChild(_children[index]),
              ),
            ),
            childCount: _children.length,
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
            child: _buildUpcomingCard(),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.child_care_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        const Text(
          'VacciTrack',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: AppSizes.fontXl,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.push(AppRoutes.notifications),
          child: const Icon(
            Icons.notifications_outlined,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSizes.md),
          const Icon(Icons.search, color: AppColors.textTertiary),
          const SizedBox(width: AppSizes.sm),
          Text(
            'Search children...',
            style: TextStyle(
              fontFamily: 'Nunito',
              color: AppColors.textTertiary,
              fontSize: AppSizes.fontMd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCard() {
    final next = _nextDueChild;
    final nextName = next?.name.split(' ').first ?? 'Your child';
    final nextDose = next?.nextVaccineName ?? 'next dose';
    final dueText = next?.nextVaccineDate != null
        ? _dueLabel(next!.nextVaccineDate!)
        : 'soon';

    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: const Icon(
                  Icons.event_note,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              const Text(
                'Upcoming Vaccination',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: AppSizes.fontLg,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$nextName is due for ',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: AppColors.textSecondary,
                  ),
                ),
                TextSpan(
                  text: nextDose,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(
                  text: ' $dueText. Would you like to set a reminder?',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          GestureDetector(
            onTap: () => context.push('/vaccine-schedule/$_primaryChildId'),
            child: const Text(
              'VIEW SCHEDULE →',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildEntity child;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildCard({
    required this.child,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  String _shortDate(DateTime date) {
    const m = [
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
    return '${m[date.month]} ${date.day}';
  }

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
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            AppAvatar(
              name: child.name,
              size: 64,
              hasActiveDot: !child.isFullyProtected,
            ),
            const SizedBox(width: AppSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          child.name,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: AppSizes.fontLg,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSizes.xs),
                      if (child.isFullyProtected)
                        const StatusBadge(
                          label: 'Fully\nProtected',
                          color: AppColors.success,
                        )
                      else if (child.nextVaccineDate != null)
                        Text(
                          'Next: ${_shortDate(child.nextVaccineDate!)}',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: AppSizes.fontSm,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    child.ageDisplay,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: AppSizes.fontSm,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PROGRESS',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '${child.completedVaccines}/${child.totalVaccines} VACCINES',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textTertiary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: LinearProgressIndicator(
                      value: child.progressPercent,
                      backgroundColor: AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(
                        child.isFullyProtected
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.textTertiary,
                  ),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem<String>(
                      value: 'edit',
                      child: Text('Edit profile'),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete profile'),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
