import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:watering_app/features/home/data/models/article_model.dart';
import 'package:watering_app/features/home/presentation/screens/webview_screen.dart';
import 'package:watering_app/features/home/presentation/widgets/article_item_card.dart';
import 'package:watering_app/features/home/providers/home_provider.dart';
import 'package:watering_app/features/home/providers/home_state.dart'
    as home_state;

class ArticlesScreen extends ConsumerStatefulWidget {
  const ArticlesScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends ConsumerState<ArticlesScreen> {
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
  Widget build(BuildContext context) {
    final articlesState = ref.watch(articlesProvider);
    final theme = Theme.of(context);

    final bool isLoading =
        articlesState is home_state.Loading ||
        articlesState is home_state.Initial;
    final bool isFailure = articlesState is home_state.Failure;

    List<Article> articles = [];

    if (isLoading) {
      articles = List.generate(
        8,
        (index) =>
            Article(title: BoneMock.title, description: BoneMock.paragraph),
      );
    } else if (articlesState is home_state.Success) {
      articles = articlesState.articlesList ?? [];
    }

    return Scaffold(
      backgroundColor: AppColors.primarySurface,
      appBar: CustomAppBar(
        backgroundColor: AppColors.mainGreen[200],
        foregroundColor: Colors.white,
        leading: const BackIcon(color: Colors.white),
        title: 'Tin tức cây trồng',
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.transparent,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(articlesProvider.notifier).getArticles();
        },
        child: Skeletonizer(
          enabled: isLoading,
          child: articles.isEmpty && !isLoading
              ? _buildEmptyState(isFailure)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return GestureDetector(
                      onTap: () => _onTapArticle(article),
                      child: ArticleItemCard(
                        theme: theme,
                        article: article,
                        onTap: () {
                          _onTapArticle(article);
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isFailure) {
    return Center(
      heightFactor: 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFailure ? Symbols.error_rounded : Symbols.newspaper,
            size: 54,
            weight: 700,
            color: Colors.grey,
          ),
          const SizedBox(height: 10),
          Text(
            isFailure ? 'Lỗi khi tải tin tức' : 'Không có tin tức nào',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
