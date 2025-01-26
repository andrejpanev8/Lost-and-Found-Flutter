import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/items_provider.dart';
import '../widgets/list_items.dart';

class MyItemsScreen extends StatelessWidget {
  const MyItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemsProvider>();
    if (!provider.userItemsLoaded) {
      provider.loadUserItems();
    }
    return !provider.isLoading
        ? listItemsOfType(
            context: context,
            screenTitle: 'My Items',
            emptyScreenText: "Currently you have no items.",
            items: provider.userItems,
            userItems: true,
          )
        : SizedBox();
  }
}
