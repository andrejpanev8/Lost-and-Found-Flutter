import 'package:flutter/material.dart';
import 'package:lost_and_found_app/providers/user_info_provider.dart';
import 'package:lost_and_found_app/service/auth_service.dart';
import 'package:lost_and_found_app/utils/state_constants.dart';
import 'package:provider/provider.dart';

import '../../providers/items_provider.dart';
import '../widgets/add_item_pop.dart';
import '../widgets/list_items.dart';

class FoundItemsScreen extends StatelessWidget {
  const FoundItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemsProvider>();
    if (!provider.foundItemsLoaded) {
      provider.loadFoundItems();
    }

    return !provider.isLoading
        ? listItemsOfType(
            context: context,
            screenTitle: 'Found Items',
            emptyScreenText: "Currently there are no found items.",
            items: provider.foundItems,
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
          state: ItemCategory.found,
        ),
      );
    }
  }
}
