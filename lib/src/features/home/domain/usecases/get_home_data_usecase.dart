import '../model/home_data.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase {
  const GetHomeDataUseCase(this._repository);

  final HomeRepository _repository;

  Future<HomeData> call() async {
    final (banners, stories, categories, furniture, materials, combinations) = await (
      _repository.getBanners(),
      _repository.getStories(),
      _repository.getCategories(),
      _repository.getTopFurniture(),
      _repository.getTopMaterials(),
      _repository.getTopCombinations(),
    ).wait;

    return HomeData(
      stories: stories,
      banners: banners,
      categories: categories,
      topFurniture: furniture,
      topMaterials: materials,
      topCombinations: combinations,
    );
  }
}
