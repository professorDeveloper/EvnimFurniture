import 'package:hive_flutter/hive_flutter.dart';

class ViewHistoryService {
  static const _boxName = 'view_history';

  late Box<int> _box;

  Future<void> init() async {
    _box = await Hive.openBox<int>(_boxName);
  }

  int recordView(String itemId) {
    final current = _box.get(itemId, defaultValue: 0)!;
    final updated = current + 1;
    _box.put(itemId, updated);
    return updated;
  }

  int getViewCount(String itemId) =>
      _box.get(itemId, defaultValue: 0)!;

  bool hasViewed(String itemId) =>
      (_box.get(itemId, defaultValue: 0)! > 0);
}
