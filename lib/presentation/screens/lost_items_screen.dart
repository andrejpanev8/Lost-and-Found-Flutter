import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/items_provider.dart';
import '../../providers/user_info_provider.dart';
import '../../service/auth_service.dart';
import '../../utils/state_constants.dart';
import '../widgets/add_item_pop.dart';
import '../widgets/list_items.dart';

class LostItemsScreen extends StatelessWidget {
  const LostItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemsProvider>();
    if (!provider.lostItemsLoaded) {
      provider.loadLostItems();
    }

    return !provider.isLoading
        ? listItemsOfType(
            context: context,
            screenTitle: 'Lost Items',
            emptyScreenText: "Currently there are no lost items.",
            items: provider.lostItems,
            onAddPress: () {
              _showAddItemPopup(context, provider);
            },
          )
        : const SizedBox();
  }

  _showAddItemPopup(BuildContext context, ItemsProvider provider) {
    if (AuthService().currentUser == null) {
      UserProvider().navigate(context, "/login");
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
        ),
        builder: (context) => AddItemPopup(
          provider: provider,
          state: ItemCategory.lost,
        ),
      );
    }
  }
}
