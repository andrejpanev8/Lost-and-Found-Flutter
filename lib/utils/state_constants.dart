enum ItemCategory {
  lost,
  found,
  retrieved,
}

extension ItemCategoryExtension on ItemCategory {
  String get name {
    switch (this) {
      case ItemCategory.lost:
        return "Lost";
      case ItemCategory.found:
        return "Found";
      case ItemCategory.retrieved:
        return "Retrieved";
    }
  }
}
