import 'package:flutter/material.dart';

import 'package:productive_muslim/core/constants/app_spacing.dart';
import 'package:productive_muslim/core/di/di.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/data/catalogs/adhkar_catalog.dart';
import 'package:productive_muslim/domain/models/dhikr.dart';
import 'package:productive_muslim/domain/repositories/adhkar_repository.dart';
import 'package:productive_muslim/l10n/app_localizations.dart';

class AdhkarLibraryPickerSheet extends StatefulWidget {
  final Set<String> alreadySelectedIds;
  final ValueChanged<DhikrItem> onItemSelected;
  final String? customTitle;
  final bool? includePendingReview;

  const AdhkarLibraryPickerSheet({
    super.key,
    this.alreadySelectedIds = const {},
    required this.onItemSelected,
    this.customTitle,
    this.includePendingReview,
  });

  @override
  State<AdhkarLibraryPickerSheet> createState() =>
      _AdhkarLibraryPickerSheetState();
}

class _AdhkarLibraryPickerSheetState extends State<AdhkarLibraryPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  AdhkarRepository? get _adhkarRepo =>
      getIt.isRegistered<AdhkarRepository>() ? getIt<AdhkarRepository>() : null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DhikrItem> get _availableItems {
    // Only approved, reviewed library entries are allowed in normal user-facing flows
    final includeReview =
        widget.includePendingReview ??
        (_adhkarRepo?.isReviewModeEnabled ?? false);
    final all = _adhkarRepo != null
        ? _adhkarRepo!.getAll(includePendingReview: includeReview)
        : AdhkarCatalog.all
              .where((d) => includeReview || d.isApproved)
              .toList();

    if (_query.trim().isEmpty) return all;

    final q = _query.toLowerCase();
    return all.where((item) {
      return item.arabic.contains(q) ||
          item.translationEn.toLowerCase().contains(q) ||
          item.translationAr.toLowerCase().contains(q) ||
          item.transliteration.toLowerCase().contains(q) ||
          item.titleEn.toLowerCase().contains(q) ||
          item.titleAr.toLowerCase().contains(q) ||
          item.category.name.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final items = _availableItems;
    final title = widget.customTitle ?? l10n.adhkarRoutineSelectAdhkar;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.primary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.adhkarRoutineSearchAdhkar,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: isDark ? AppColors.darkSurface : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              ),
              onChanged: (val) => setState(() => _query = val),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        l10n.adhkarSearchNoResultsTitle,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = widget.alreadySelectedIds.contains(
                        item.id,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: isSelected
                                ? null
                                : () {
                                    widget.onItemSelected(item);
                                    Navigator.pop(context);
                                  },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.secondary.withValues(
                                          alpha: 0.6,
                                        )
                                      : (isDark
                                            ? Colors.white.withValues(
                                                alpha: 0.08,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.06,
                                              )),
                                ),
                              ),
                              child: ListTile(
                                enabled: !isSelected,
                                title: Text(
                                  item.arabic,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  item.translationEn,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: isSelected
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          l10n.adhkarRoutineAlreadyAdded,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.add_circle_outline_rounded,
                                        color: AppColors.primary,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
