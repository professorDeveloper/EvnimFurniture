import '../../../home/domain/model/furniture_item.dart';

abstract class CategoryFurnitureState {
  const CategoryFurnitureState();
}

class CategoryFurnitureInitial extends CategoryFurnitureState {
  const CategoryFurnitureInitial();
}

class CategoryFurnitureLoading extends CategoryFurnitureState {
  const CategoryFurnitureLoading();
}

class CategoryFurnitureLoaded extends CategoryFurnitureState {
  const CategoryFurnitureLoaded({
    required this.allItems,
    required this.filteredItems,
    this.query = '',
  });

  final List<FurnitureItem> allItems;
  final List<FurnitureItem> filteredItems;
  final String query;
}

class CategoryFurnitureError extends CategoryFurnitureState {
  const CategoryFurnitureError({required this.message});
  final String message;
}
