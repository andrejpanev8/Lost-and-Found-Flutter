import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found_app/presentation/widgets/add_item_pop.dart';
import 'package:lost_and_found_app/service/map_service.dart';
import 'package:lost_and_found_app/utils/state_constants.dart';
import 'package:provider/provider.dart';

import '../../data/item_model.dart';
import '../../providers/items_provider.dart';
import '../../utils/color_constants.dart';
import '../../utils/text_styles.dart';

class ItemWidget extends StatelessWidget {
  final Item item;
  bool? userItems;
  ItemWidget({super.key, required this.item, this.userItems});

  @override
  Widget build(BuildContext context) {
    var provider = context.read<ItemsProvider>();
    return GestureDetector(
      onTap: () => _showItemDetailsDialog(context, item, provider),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.start, // Aligns image and details side-by-side
        children: [
          _image(provider),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _details(context, provider),
                const SizedBox(height: 8),
                userItems == true
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [_itemStateText(), _deleteButton(provider)],
                      )
                    : SizedBox.shrink()
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context, ItemsProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "Item - ${item.name}",
                style: StyledText().descriptionText(),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            userItems == true
                ? IconButton(
                    icon: Icon(Icons.edit_square),
                    onPressed: () => _editItem(context, provider),
                  )
                : SizedBox.shrink(),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          item.description,
          style: StyledText().descriptionText(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Text(
          "Location: ${item.location}",
          style: StyledText().descriptionText(fontSize: 14),
        ),
      ],
    );
  }

  Widget _image(ItemsProvider provider) {
    return provider.isLoading
        ? const CircularProgressIndicator()
        : SizedBox(
            width: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
              ),
            ),
          );
  }

  Widget _itemStateText() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Text(item.state,
          style: StyledText().descriptionText(
              color: item.state == ItemCategory.lost.name
                  ? redDark
                  : item.state == ItemCategory.found.name
                      ? greenPrimary
                      : null)),
    );
  }

  Widget _deleteButton(ItemsProvider provider) {
    return ElevatedButton(
      onPressed: () {
        provider.deleteItem(item);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: redTransparent,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      ),
      child: const Text(
        "Delete",
        style: TextStyle(fontSize: 14.0, color: whiteColor),
      ),
    );
  }

  void _editItem(BuildContext context, ItemsProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: AddItemPopup(
            provider: provider,
            state: item.state == ItemCategory.lost.name
                ? ItemCategory.lost
                : ItemCategory.found,
            item: item,
          ),
        );
      },
    );
  }
}

void _showItemDetailsDialog(
    BuildContext context, Item item, ItemsProvider provider) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Listing: #${item.id}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Image.network(
                  item.image,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 16),
                Text("Item: ${item.name}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Description: ${item.description}"),
                const SizedBox(height: 8),
                CachedNetworkImage(
                  imageUrl: MapService()
                      .generateMapUrl(item.latitude, item.longitude),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 6),
                Text("Location: ${item.location}"),
                const SizedBox(height: 8),
                Text("Reward: \$${item.reward}"),
                const SizedBox(height: 8),
                Text("Contact info: ${item.contactInfo}"),
                const SizedBox(height: 16),
                item.state == ItemCategory.lost.name
                    ? Center(
                        child: ElevatedButton(
                          onPressed: () {
                            provider.markItemFound(item);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenPrimary,
                          ),
                          child: Text(
                            "Mark found",
                            style: StyledText().descriptionText(),
                          ),
                        ),
                      )
                    : const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      );
    },
  );
}
