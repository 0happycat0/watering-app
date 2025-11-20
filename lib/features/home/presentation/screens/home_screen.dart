import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
import 'package:watering_app/features/authentication/providers/auth_provider.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/presentation/screens/device_detail_screen.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_provider.dart';
import 'package:watering_app/features/home/data/models/article_model.dart';
import 'package:watering_app/features/home/presentation/screens/articles_screen.dart';
import 'package:watering_app/features/home/presentation/screens/incoming_schedule_screen.dart';
import 'package:watering_app/features/home/presentation/screens/webview_screen.dart';
import 'package:watering_app/features/home/presentation/widgets/article_item_card.dart';
import 'package:watering_app/features/home/presentation/widgets/info_card.dart';
import 'package:watering_app/features/home/presentation/widgets/schedule_item_card.dart';
import 'package:watering_app/features/home/providers/home_provider.dart';
import 'package:watering_app/theme/theme.dart';
import 'package:watering_app/features/home/providers/home_state.dart'
    as home_state;
import 'package:watering_app/features/authentication/providers/auth_state.dart'
    as auth_state;
import 'package:watering_app/features/devices/providers/all_devices/devices_state.dart'
    as devices_state;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _onSeeAllSchedules() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (ctx) => IncomingScheduleScreen()));
  }

  void _onSeeAllArticles() {
    Navigator.of(
      context,
    ).push(CupertinoPageRoute(builder: (ctx) => ArticlesScreen()));
  }

  void _onTapSchedule(Device device) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) =>
            DeviceDetailScreen(device: device, isNavigetedFromHome: true),
      ),
    );
  }

  void _onTapArticle(Article article) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => WebviewScreen(
          url: '${ApiPath.newsDetailsUrl}${article.url}',
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await ref.read(getUserLocalProvider.notifier).getUserLocal();
      await ref.read(quantitiesProvider.notifier).getQuantities();
      await ref.read(devicesProvider.notifier).getAllDevices();
      await ref.read(articlesProvider.notifier).getArticles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(getUserLocalProvider);
    final devicesState = ref.watch(devicesProvider);
    final articlesState = ref.watch(articlesProvider);
    final username = userState is auth_state.Success
        ? userState.user?.username ?? ''
        : '';

    final statusHeight = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primarySurface.withAlpha(200),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            _buildHeader(statusHeight, username, theme),
          ];
        },
        body: RefreshIndicator(
          onRefresh: () async {
            await ref.read(devicesProvider.notifier).getAllDevices();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              ..._buildScheduleSection(theme, devicesState),

              ..._buildArticlesSection(theme, articlesState),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double statusHeight, String username, ThemeData theme) {
    return SliverAppBar(
      pinned: true,

      expandedHeight: 240,
      collapsedHeight: 80,
      toolbarHeight: 60,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.light,
      ),

      backgroundColor: AppColors.secondaryGreen[200],
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      scrolledUnderElevation: 4,
      forceElevated: true,
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
          ],
        ),
      ),
      centerTitle: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: EdgeInsets.fromLTRB(16, statusHeight + 80, 16, 0),
            decoration: BoxDecoration(
              // color: Colors.amber,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: InfoCard(),
          ),
        ),
      ),
    );
  }

  // Widget build phần "Lịch tưới"
  List<Widget> _buildScheduleSection(
    ThemeData theme,
    devices_state.DevicesState devicesState,
  ) {
    final isLoading =
        devicesState is devices_state.Loading ||
        devicesState is devices_state.Initial;
    final isFailure = devicesState is devices_state.Failure;
    // Mock data for schedule
    List<Device> devices;
    if (isLoading) {
      devices = [
        Device(
          name: 'Tên thiết bị',
          nextSchedule: Schedule(
            duration: 50,
            startTime: '11:00:00',
            runAfter: 3600,
          ),
        ),
        Device(
          name: 'Tên thiết bị',
          nextSchedule: Schedule(
            duration: 10,
            startTime: '11:00:00',
            runAfter: 3600,
          ),
        ),
        Device(
          name: 'Tên thiết bị',
          nextSchedule: Schedule(
            duration: 20,
            startTime: '11:00:00',
            runAfter: 3600,
          ),
        ),
      ];
    } else if (isFailure) {
      devices = [];
    } else {
      devices = (devicesState as devices_state.Success).devicesList
          .where((device) => device.nextSchedule != null)
          .toList();
    }
    final numOfItemToDisplay = (devices.length < 3) ? devices.length : 3;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _SectionHeader(
            title: 'Lịch tưới sắp tới',
            onSeeAll: _onSeeAllSchedules,
          ),
        ),
      ),
      //Lỗi
      if (devices.isEmpty && devicesState is devices_state.Failure)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: Skeletonizer.sliver(
            enabled: isLoading,
            child: SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Symbols.event_busy,
                        size: 54,
                        weight: 700,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Lỗi khi tải lịch tưới',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      //Danh sách rỗng
      else if (devices.isEmpty)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: Skeletonizer.sliver(
            enabled: isLoading,
            child: SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.calendar_add_on_rounded,
                          size: 54,
                          weight: 700,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Không có lịch tưới sắp tới',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      //Thành công
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: Skeletonizer.sliver(
            enabled: isLoading,
            child: SliverList.builder(
              itemCount: numOfItemToDisplay,
              itemBuilder: (context, index) {
                final device = devices[index];
                return ScheduleItemCard(
                  theme: theme,
                  device: device,
                  onTap: () {
                    _onTapSchedule(device);
                  },
                );
              },
            ),
          ),
        ),
    ];
  }

  // Widget build phần "Bài viết"
  List<Widget> _buildArticlesSection(
    ThemeData theme,
    home_state.HomeState articlesState,
  ) {
    final isLoading =
        articlesState is home_state.Initial ||
        articlesState is home_state.Loading;
    final isFailure = articlesState is home_state.Failure;

    // Mock data for articles
    List<Article> articles;

    if (isLoading) {
      articles = [
        Article(title: BoneMock.title, description: BoneMock.paragraph),
        Article(title: BoneMock.title, description: BoneMock.paragraph),
        Article(title: BoneMock.title, description: BoneMock.paragraph),
      ];
    } else if (isFailure) {
      articles = [];
    } else {
      articles = (articlesState as home_state.Success).articlesList ?? [];
    }
    final numOfItemToDisplay = (articles.length < 3) ? articles.length : 3;

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: _SectionHeader(
            title: 'Tin tức cây trồng',
            seeAllText: 'Xem thêm',
            onSeeAll: _onSeeAllArticles,
          ),
        ),
      ),

      //Lỗi
      if (articles.isEmpty && isFailure)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: Skeletonizer.sliver(
            enabled: isLoading,
            child: SliverToBoxAdapter(
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Symbols.error_rounded,
                        size: 54,
                        weight: 700,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Lỗi khi tải tin tức',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        )
      //Danh sách rỗng
      else if (articles.isEmpty)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: Skeletonizer.sliver(
            enabled: isLoading,
            child: SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Symbols.newspaper, // Icon báo chí
                          size: 54,
                          weight: 700,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Không có tin tức nào',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      //Thành công
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: Skeletonizer.sliver(
            enabled: isLoading,
            child: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final article = articles[index];
                  return ArticleItemCard(
                    theme: theme,
                    article: article,
                    onTap: () {
                      _onTapArticle(article);
                    },
                  );
                },
                childCount: numOfItemToDisplay,
              ),
            ),
          ),
        ),
    ];
  }
}

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
