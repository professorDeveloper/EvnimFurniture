part of 'home_bloc.dart';

abstract class HomeState {
  const HomeState();
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({
    required this.data,
    this.combinations = const [],
    this.combinationsPage = 1,
    this.hasMoreCombinations = true,
    this.loadingMoreCombinations = false,
  });

  final HomeData data;
  final List<CombinationItem> combinations;
  final int combinationsPage;
  final bool hasMoreCombinations;
  final bool loadingMoreCombinations;

  HomeLoaded copyWith({
    HomeData? data,
    List<CombinationItem>? combinations,
    int? combinationsPage,
    bool? hasMoreCombinations,
    bool? loadingMoreCombinations,
  }) {
    return HomeLoaded(
      data: data ?? this.data,
      combinations: combinations ?? this.combinations,
      combinationsPage: combinationsPage ?? this.combinationsPage,
      hasMoreCombinations: hasMoreCombinations ?? this.hasMoreCombinations,
      loadingMoreCombinations: loadingMoreCombinations ?? this.loadingMoreCombinations,
    );
  }
}

class HomeError extends HomeState {
  const HomeError({required this.message});
  final String message;
}
