import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localization.dart';
import '../../../core/storage/local_app_storage.dart';
import '../../../domain/entities/guidance_article_entity.dart';
import '../../widgets/common/common_widgets.dart';

class GuidePage extends StatefulWidget {
  const GuidePage({super.key});

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  static const String _emergencyPhoneNumber = '1021';

  List<Map<String, String>> _tabs(BuildContext context) => [
    {'label': context.l10n.sideEffects, 'value': 'side_effects'},
    {'label': context.l10n.advice, 'value': 'advice'},
    {'label': context.l10n.warningSigns, 'value': 'warning_signs'},
  ];

  int _tabIndex = 0;
  bool _loading = true;
  List<GuidanceArticleEntity> _articles = const [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() => _loading = true);
    final category = _tabs(context)[_tabIndex]['value']!;
    final articles = await LocalAppStorage.instance.getGuidanceArticles(
      category: category,
    );
    if (!mounted) return;
    setState(() {
      _articles = articles;
      _loading = false;
    });
  }

  Future<void> _addRemark(GuidanceArticleEntity article) async {
    final controller = TextEditingController();
    final text = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSizes.md,
            right: AppSizes.md,
            top: AppSizes.md,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSizes.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${context.l10n.addRemark} - ${article.title}',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: context.l10n.writeYourRemark,
                ),
              ),
              const SizedBox(height: AppSizes.sm),
              AppButton(
                label: context.l10n.saveRemark,
                onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              ),
            ],
          ),
        );
      },
    );
    if (text == null || text.trim().isEmpty) return;
    await LocalAppStorage.instance.addGuidanceRemark(
      articleId: article.id,
      text: text,
    );
    await _loadArticles();
  }

  Future<void> _callEmergency() async {
    final uri = Uri(scheme: 'tel', path: _emergencyPhoneNumber);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.openEmergencyDialerFailed)),
      );
    }
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
        title: Text(context.l10n.guideTitle),
      ),
      body: Column(
        children: [
          Container(
            color: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.md,
              vertical: AppSizes.sm,
            ),
            child: Row(
              children: _tabs(context).asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                final active = _tabIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSizes.sm),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _tabIndex = index);
                      _loadArticles();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.md,
                        vertical: AppSizes.sm,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.primary
                            : AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                      ),
                      child: Text(
                        tab['label']!,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w700,
                          color: active
                              ? AppColors.white
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _articles.isEmpty
                ? Center(
                    child: Text(
                      context.l10n.guideUnavailable,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.md),
                    itemCount: _articles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppSizes.md),
                    itemBuilder: (context, index) {
                      final article = _articles[index];
                      return _GuideCard(
                        article: article,
                        onAddRemark: () => _addRemark(article),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.md,
                0,
                AppSizes.md,
                AppSizes.sm,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _callEmergency,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.md,
                      vertical: AppSizes.md,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.call, size: 20),
                  label: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.callEmergency,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${context.l10n.emergencyHelpSubtitle} • $_emergencyPhoneNumber',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: AppSizes.fontXs,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AppBottomNav(
              currentIndex: 2,
              onTap: (index) =>
                  handleMainBottomNavTap(context, index: index, currentIndex: 2),
              items: mainBottomNavItems(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCard extends StatelessWidget {
  final GuidanceArticleEntity article;
  final VoidCallback onAddRemark;

  const _GuideCard({required this.article, required this.onAddRemark});

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
          Text(
            article.title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: AppSizes.fontLg,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.xs),
          Text(
            article.content,
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              const Icon(
                Icons.comment_outlined,
                size: 16,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.remarksCount(article.remarks.length),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textTertiary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onAddRemark,
                child: Text(context.l10n.addRemark),
              ),
            ],
          ),
          if (article.remarks.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                article.remarks.first.text,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: AppSizes.fontSm,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
