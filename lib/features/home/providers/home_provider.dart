import 'package:flutter_riverpod/legacy.dart';
import 'package:watering_app/features/home/domain/home_repository_impl.dart';
import 'package:watering_app/features/home/domain/home_repository_provider.dart';
import 'package:watering_app/features/home/providers/home_state.dart'
    as home_state;

//devices quantity & online devices quantity
final quantitiesProvider =
    StateNotifierProvider.autoDispose<QuantitiesNotifier, home_state.HomeState>(
      (ref) {
        final homeRepository = ref.watch(homeRepositoryProvider);
        return QuantitiesNotifier(homeRepository);
      },
    );

class QuantitiesNotifier extends StateNotifier<home_state.HomeState> {
  QuantitiesNotifier(this.homeRepository) : super(home_state.Initial());

  HomeRepositoryImpl homeRepository;

  Future<void> getQuantities() async {
    state = home_state.Loading();

    final devicesResponse = await homeRepository.getDevicesQuantity();

    if (devicesResponse.isLeft()) {
      if (!mounted) return;
      state = home_state.Failure(devicesResponse.fold((l) => l, (r) => null)!);
      return;
    }

    final onlineResponse = await homeRepository.getOnlineDevicesQuantity();

    if (onlineResponse.isLeft()) {
      if (!mounted) return;
      state = home_state.Failure(onlineResponse.fold((l) => l, (r) => null)!);
      return;
    }

    if (!mounted) return;

    final int devicesQuantity = devicesResponse.fold(
      (l) => 0,
      (r) => r.data as int,
    );
    final int onlineQuantity = onlineResponse.fold(
      (l) => 0,
      (r) => r.data as int,
    );

    state = home_state.Success(
      devicesQuantity: devicesQuantity,
      onlineDevicesQuantity: onlineQuantity,
    );
  }
}

//--------------------------------------------------------------------------------------------------
//get list articles
final articlesProvider =
    StateNotifierProvider.autoDispose<ArticlesNotifier, home_state.HomeState>(
      (ref) {
        final homeRepository = ref.watch(homeRepositoryProvider);
        return ArticlesNotifier(homeRepository);
      },
    );

class ArticlesNotifier extends StateNotifier<home_state.HomeState> {
  ArticlesNotifier(this.homeRepository) : super(home_state.Initial());
  final HomeRepositoryImpl homeRepository;

  Future<void> getArticles() async {
    state = home_state.Loading();
    final response = await homeRepository.getArticles();
    if (!mounted) return;
    state = response.fold(
      (exception) {
        return home_state.Failure(exception);
      },
      (articlesList) {
        return home_state.Success(articlesList: articlesList);
      },
    );
  }

  Future<void> refresh() async {
    await getArticles();
  }

  void setLoading() {
    state = home_state.Loading();
  }
}
