import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:productive_muslim/core/router/app_router.dart';
import 'package:productive_muslim/core/theme/app_colors_extension.dart';
import 'package:productive_muslim/core/widgets/app_pressable.dart';

class ProductiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final IconData? leadingIcon;
  final Widget? leading;
  final bool? showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;

  const ProductiveAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.leading,
    this.showBackButton,
    this.onBackPressed,
    this.actions,
    this.centerTitle = false,
    this.bottom,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPopRoute = Navigator.of(context).canPop() || context.canPop();
    final canPop = showBackButton ?? canPopRoute;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && canPop) {
      final backTooltip = MaterialLocalizations.of(context).backButtonTooltip;
      final isRtl = Directionality.of(context) == TextDirection.rtl;
      leadingWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 12),
        child: Center(
          child: Tooltip(
            message: backTooltip,
            child: AppPressable(
              onTap:
                  onBackPressed ??
                  () {
                    if (context.canPop()) {
                      context.pop();
                    } else if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      final fallback =
                          AppRouter.consumeNotificationFallbackLocation() ??
                          '/';
                      context.go(fallback);
                    }
                  },
              pressedScale: 0.88,
              haptic: AppHapticFeedback.selection,
              borderRadius: BorderRadius.circular(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : AppColors.primary.withValues(alpha: 0.07),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : AppColors.primary.withValues(alpha: 0.12),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      isRtl
                          ? Icons.arrow_forward_ios_rounded
                          : Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (leadingWidget == null && leadingIcon != null) {
      leadingWidget = Padding(
        padding: const EdgeInsetsDirectional.only(start: 16),
        child: Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryLight.withValues(alpha: 0.16)
                  : AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? AppColors.primaryLight.withValues(alpha: 0.25)
                    : AppColors.primary.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Icon(
              leadingIcon,
              size: 18,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
          ),
        ),
      );
    }

    final titleWidget = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: centerTitle
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 1),
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ],
      ],
    );

    final appBar = ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurface.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.88),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.08),
                width: 1,
              ),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: centerTitle,
            titleSpacing: leadingWidget != null ? 8 : 16,
            leading: leadingWidget,
            leadingWidth: leadingWidget != null ? 54 : 16,
            title: titleWidget,
            actions: actions != null
                ? [...actions!, const SizedBox(width: 8)]
                : null,
            bottom: bottom,
          ),
        ),
      ),
    );

    if (showBackButton == true && !canPopRoute) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            if (onBackPressed != null) {
              onBackPressed!();
            } else {
              final fallback =
                  AppRouter.consumeNotificationFallbackLocation() ?? '/';
              context.go(fallback);
            }
          }
        },
        child: appBar,
      );
    }

    return appBar;
  }
}

class ProductiveAppBarAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color? iconColor;
  final Widget? badge;

  const ProductiveAppBarAction({
    super.key,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.iconColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget button = AppPressable(
      onTap: onTap,
      pressedScale: 0.88,
      haptic: AppHapticFeedback.selection,
      borderRadius: BorderRadius.circular(20),
      child: Tooltip(
        message: tooltip,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          child: Center(
            child: Container(
              width: 38,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.primary.withValues(alpha: 0.07),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : AppColors.primary.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 19,
                color:
                    iconColor ??
                    (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );

    if (badge != null) {
      button = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          button,
          Positioned(top: 2, right: 4, child: badge!),
        ],
      );
    }

    return Center(child: button);
  }
}
