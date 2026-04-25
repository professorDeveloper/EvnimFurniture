abstract class CategoryFurnitureEvent {
  const CategoryFurnitureEvent();
}

class LoadCategoryFurniture extends CategoryFurnitureEvent {
  const LoadCategoryFurniture({required this.slug});
  final String slug;
}

class RefreshCategoryFurniture extends CategoryFurnitureEvent {
  const RefreshCategoryFurniture({required this.slug});
  final String slug;
}

class SearchCategoryFurniture extends CategoryFurnitureEvent {
  const SearchCategoryFurniture({required this.query});
  final String query;
}
