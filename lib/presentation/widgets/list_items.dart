import 'package:flutter/material.dart';

import '../../data/item_model.dart';
import '../../utils/color_constants.dart';
import 'item_widget.dart';
import 'page_title_widget.dart';

Widget listItemsOfType({
  required BuildContext context,
  required String screenTitle,
  required String emptyScreenText,
  required List<Item> items,
  bool? userItems,
  String? error,
  void Function()? onAddPress,
}) {
  return Scaffold(
    appBar: AppBar(
      title: pageTitleWidget(title: screenTitle),
    ),
    body: items.isNotEmpty
        ? _buildItemsList(items, userItems)
        : Center(child: Text(emptyScreenText)),
    floatingActionButton: onAddPress != null
        ? FloatingActionButton(
            onPressed: onAddPress,
            backgroundColor: yellowColor,
            child: const Icon(Icons.add),
          )
        : null,
  );
}

Widget _buildItemsList(List<Item> items, bool? userItems) {
  return ListView.builder(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    itemCount: items.length,
    itemBuilder: (context, index) {
      final item = items[index];
      return Card(
        color: purpleSecondary,
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: ItemWidget(item: item, userItems: userItems),
        ),
      );
    },
  );
}
