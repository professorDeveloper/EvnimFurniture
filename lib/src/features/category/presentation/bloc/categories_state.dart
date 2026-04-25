import '../../domain/model/category_model.dart';

abstract class CategoriesState {
  const CategoriesState();
}

class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

class CategoriesLoaded extends CategoriesState {
  const CategoriesLoaded({required this.categories});
  final List<CategoryItem> categories;
}

class CategoriesError extends CategoriesState {
  const CategoriesError({required this.message});
  final String message;
}
