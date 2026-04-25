import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_texts.dart';
import '../../../../core/di/injection.dart';
import '../../domain/model/notification_item.dart';
import '../bloc/notification_bloc.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final bg = isDark ? AppColors.darkBackground : AppColors.white;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;

    return BlocProvider(
      create: (_) =>  sl<NotificationBloc>()..add(const LoadNotifications()),
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: cs.onSurface,
            ),
          ),
          centerTitle: true,
          title: Text(
            'notifications'.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: text,
            ),
          ),
        ),
        body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return _NotificationShimmer(isDark: isDark);
            }
            if (state is NotificationError) {
              return _EmptyState(isDark: isDark);
            }
            if (state is NotificationLoaded) {
              if (state.items.isEmpty) {
                return _EmptyState(isDark: isDark);
              }
              return _NotificationList(state: state, isDark: isDark);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  const _NotificationList({required this.state, required this.isDark});

  final NotificationLoaded state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scroll) {
        if (scroll.metrics.pixels > scroll.metrics.maxScrollExtent - 200) {
          context
              .read<NotificationBloc>()
              .add(const LoadMoreNotifications());
        }
        return false;
      },
      child: RefreshIndicator(
        color: AppColors.primary,
        displacement: 20,
        onRefresh: () async {
          context
              .read<NotificationBloc>()
              .add(const RefreshNotifications());
          await context
              .read<NotificationBloc>()
              .stream
              .firstWhere((s) =>
                  s is NotificationLoaded || s is NotificationError);
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            if (index == state.items.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            return _NotificationCard(
              key: ValueKey(state.items[index].id),
              item: state.items[index],
              isDark: isDark,
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({super.key, required this.item, required this.isDark});

  final NotificationItem item;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final card = isDark ? AppColors.darkSurface : AppColors.surface;
    final text = isDark ? AppColors.darkOnSurface : AppColors.onSurface;
    final subText = isDark
        ? AppColors.darkOnSurface.withValues(alpha: 0.55)
        : AppColors.grey500;
    final border = isDark ? AppColors.darkDivider : AppColors.divider;

    final hasImage = item.image != null && item.image!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (hasImage)
            CachedNetworkImage(
              imageUrl: item.image!,
              memCacheWidth: 800,
              width: double.infinity,
              height: 160,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                height: 160,
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.grey100,
              ),
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),

          // Content
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  item.title,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: text,
                    height: 1.3,
                  ),
                ),

                // Body
                if (item.body != null && item.body!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.body!,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: subText,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Date
                const SizedBox(height: 8),
                Text(
                  _formatDate(item.createdAt),
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: subText.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return AppTexts.timeNow.tr();
    if (diff.inMinutes < 60) return AppTexts.timeMinutesAgo.tr(args: ['${diff.inMinutes}']);
    if (diff.inHours < 24) return AppTexts.timeHoursAgo.tr(args: ['${diff.inHours}']);
    if (diff.inDays < 7) return AppTexts.timeDaysAgo.tr(args: ['${diff.inDays}']);

    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year}';
  }
}

class _EmptyState extends StatefulWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );

    _fadeAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final iconBg = widget.isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.primary.withValues(alpha: 0.08);
    final iconColor = widget.isDark
        ? AppColors.grey500
        : AppColors.primary.withValues(alpha: 0.7);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _ctrl,
              builder: (context, child) {
                return ScaleTransition(
                  scale: _pulseAnim,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: iconBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 48,
                        color: iconColor,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'noNotifications'.tr(),
              style: GoogleFonts.dmSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: widget.isDark
                    ? AppColors.darkOnSurface
                    : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'noNotificationsDesc'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: widget.isDark
                    ? AppColors.grey500
                    : AppColors.grey600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationShimmer extends StatefulWidget {
  const _NotificationShimmer({required this.isDark});
  final bool isDark;

  @override
  State<_NotificationShimmer> createState() => _NotificationShimmerState();
}

class _NotificationShimmerState extends State<_NotificationShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shimmer =
        widget.isDark ? AppColors.darkSurfaceVariant : AppColors.grey200;
    final card = widget.isDark ? AppColors.darkSurface : AppColors.surface;
    final border = widget.isDark ? AppColors.darkDivider : AppColors.divider;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: 4,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final op = (_anim.value - i * 0.05).clamp(0.1, 0.8);
            final showImage = i == 0 || i == 2;
            return Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showImage)
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: shimmer.withValues(alpha: op),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 180,
                          height: 14,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: shimmer.withValues(alpha: op),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 240,
                          height: 11,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            color: shimmer.withValues(alpha: op * 0.7),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: 70,
                          height: 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: shimmer.withValues(alpha: op * 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
