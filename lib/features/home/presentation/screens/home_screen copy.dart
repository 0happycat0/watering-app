import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/home/data/models/article_model.dart';
import 'package:watering_app/features/home/presentation/widgets/artical_item_card.dart';
import 'package:watering_app/features/home/presentation/widgets/info_card.dart';
import 'package:watering_app/features/home/presentation/widgets/schedule_item_card.dart';
import 'package:watering_app/features/home/providers/home_provider.dart';
import 'package:watering_app/features/home/providers/home_state.dart'
    as home_state;
import 'package:watering_app/theme/theme.dart';
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ref.read(getUserLocalProvider.notifier).getUserLocal();
      await ref.read(quantitiesProvider.notifier).getQuantities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(getUserLocalProvider);
    final username = userState is auth_state.Success
        ? userState.user?.username ?? ''
        : '';

    final statusHeight = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Header
                _buildHeader(statusHeight, username, theme),
              ],
            ),

            _buildScheduleSection(theme),

            _buildArticlesSection(theme),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double statusHeight, String username, ThemeData theme) {
    return Container(
      height: 290,
      padding: EdgeInsets.fromLTRB(16, statusHeight + 10, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.secondaryGreen[200],
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(80),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Xin chào,',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            username,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          SizedBox(height: 20),
          //Info card
          InfoCard(),
        ],
      ),
    );
  }

  // Widget build phần "Lịch tưới"
  Widget _buildScheduleSection(ThemeData theme) {
    // Mock data for schedule
    final devices = [
      Device(
        nextSchedule: Schedule(
          duration: 600,
          startTime: '11:00:00',
          runAfter: 3600,
        ),
      ),
      Device(
        nextSchedule: Schedule(
          duration: 600,
          startTime: '11:00:00',
          runAfter: 3600,
        ),
      ),
      Device(
        nextSchedule: Schedule(
          duration: 600,
          startTime: '11:00:00',
          runAfter: 3600,
        ),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _SectionHeader(
            title: 'Lịch tưới sắp tới',
            onSeeAll: () {},
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              return ScheduleItemCard(theme: theme, device: device, onTap: () {},);
            },
          ),
        ],
      ),
    );
  }

  // Widget build phần "Bài viết"
  Widget _buildArticlesSection(ThemeData theme) {
    // Mock data for articles
    final articles = [
      {
        'category': 'Chăm sóc',
        'title': 'Cách chăm sóc cây trong nhà hiệu quả',
        'description':
            'Những mẹo đơn giản để cây cảnh trong nhà phát triển xanh tốt...',
        'readTime': '3 phút đọc',
        'color': Colors.green,
      },
      {
        'category': 'Kỹ thuật',
        'title': 'Lịch tưới nước hợp lý cho vườn rau',
        'description':
            'Khám phá cách tưới nước tiết kiệm nhưng vẫn đảm bảo hiệu quả...',
        'readTime': '7 phút đọc',
        'color': Colors.blue,
      },
      {
        'category': 'Hướng dẫn',
        'title': 'Top 10 loại rau dễ trồng tại nhà',
        'description':
            'Danh sách các loại rau củ dễ trồng và chăm sóc cho người mới...',
        'readTime': '6 phút đọc',
        'color': Colors.orange,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _SectionHeader(
            title: 'Bài viết về cây trồng',
            seeAllText: 'Xem thêm',
            onSeeAll: () {},
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final article = articles[index];
              return ArticleItemCard(theme: theme, article: Article());
            },
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS CON ---

// Tiêu đề của một khu vực (vd: "Lịch tưới...")
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.seeAllText = 'Xem tất cả',
    required this.onSeeAll,
  });

  final String title;
  final String seeAllText;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: Text(
            seeAllText,
            style: TextStyle(color: AppColors.secondaryGreen[300]),
          ),
        ),
      ],
    );
  }
}
