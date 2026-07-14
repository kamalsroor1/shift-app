import 'package:flutter/material.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';

/// NotificationsScreen — Real-time alerts & notifications feed for medical personnel
/// covering shift approvals, swap acceptances, and financial settlements.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = [
      {
        'id': 1,
        'title': 'موافقة على طلب التبادل 🤝',
        'message': 'وافق د. أحمد خالد على تغطية ورديتك ليوم الأحد القادم في قسم العناية المركزة.',
        'time': 'منذ ١٥ دقيقة',
        'is_read': false,
        'icon': Icons.swap_horizontal_circle_rounded,
        'color': AppColors.claimGreen,
      },
      {
        'id': 2,
        'title': 'تحديث جدول الورديات الشهري 📅',
        'message': 'تم اعتماد ونشر جدول شهر يوليو الرسمي من قبل إدارة التمريض بالطوارئ.',
        'time': 'منذ ساعتين',
        'is_read': false,
        'icon': Icons.calendar_month_rounded,
        'color': AppColors.primary,
      },
      {
        'id': 3,
        'title': 'تأكيد تسوية مطالبة مالية 💰',
        'message': 'تم تأكيد سداد مبلغ ٤٠٠ ج.م من قبل ممرضة سارة علي وأرشفة المعاملة.',
        'time': 'أمس، ٠٨:٣٠ م',
        'is_read': true,
        'icon': Icons.check_circle_rounded,
        'color': AppColors.secondaryLow,
      },
      {
        'id': 4,
        'title': 'تنبيه مناوبة قادمة ⏰',
        'message': 'تذكير: لديك وردية سهر ليلية (١٢ ساعة) تبدأ اليوم الساعة ٠٧:٣٠ مساءً.',
        'time': 'منذ يومين',
        'is_read': true,
        'icon': Icons.notifications_active_rounded,
        'color': AppColors.shiftNight,
      },
    ];
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['is_read'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم تحديد جميع الإشعارات كمقروءة.', style: AppTextStyles.bodySm.copyWith(color: AppColors.surface)),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['is_read'] == false).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('الطلبات والتنبيهات الحية', style: AppTextStyles.displayMd),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
              label: Text('قراءة الكل ($unreadCount)', style: AppTextStyles.label.copyWith(color: AppColors.primary)),
            ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxxl),
                child: Column(
                  children: [
                    const Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.surfaceAlt),
                    const SizedBox(height: AppSpacing.md),
                    Text('لا توجد أي إشعارات أو طلبات جديدة.', style: AppTextStyles.bodyMd),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final item = _notifications[index];
                final isRead = item['is_read'] == true;

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: InkWell(
                    onTap: () {
                      if (!isRead) {
                        setState(() => item['is_read'] = true);
                      }
                    },
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    child: AppCard(
                      accentColor: isRead ? AppColors.surfaceAlt : (item['color'] as Color),
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isRead ? AppColors.surfaceAlt.withOpacity(0.3) : (item['color'] as Color).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: isRead ? AppColors.secondaryLow : (item['color'] as Color),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title'] as String,
                                        style: AppTextStyles.headingSm.copyWith(
                                          fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    if (!isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  item['message'] as String,
                                  style: AppTextStyles.bodySm.copyWith(
                                    color: isRead ? AppColors.secondaryLow : AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  item['time'] as String,
                                  style: AppTextStyles.caption.copyWith(color: AppColors.secondaryLow),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
