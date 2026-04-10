import '../model/home_data.dart';
import '../repositories/home_repository.dart';

class GetHomeDataUseCase {
  const GetHomeDataUseCase(this._repository);

  final HomeRepository _repository;

  Future<HomeData> call() async {
    final (stories, categories, furniture, materials, combinations) = await (
      _repository.getStories(),
      _repository.getCategories(),
      _repository.getTopFurniture(),
      _repository.getTopMaterials(),
      _repository.getTopCombinations(),
    ).wait;

    // TODO: replace with _repository.getBanners() when API is ready
    const banners = [
      'https://cdn.azamov.me/images/banners/1773897035826-aa.png',
    ];

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
