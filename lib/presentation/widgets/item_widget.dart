import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lost_and_found_app/service/map_service.dart';
import 'package:lost_and_found_app/utils/state_constants.dart';
import 'package:provider/provider.dart';

import '../../data/item_model.dart';
import '../../providers/items_provider.dart';
import '../../utils/color_constants.dart';
import '../../utils/text_styles.dart';

class ItemWidget extends StatelessWidget {
  final Item item;
  const ItemWidget({super.key, required this.item, bool? userItems});

  @override
  Widget build(BuildContext context) {
    var provider = context.read<ItemsProvider>();
    return GestureDetector(
      onTap: () => _showItemDetailsDialog(context, item, provider),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _image(),
          const SizedBox(width: 12),
          _details(),
        ],
      ),
    );
  }

  Widget _details() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Item - ${item.name}",
            style: StyledText().descriptionText(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: StyledText().descriptionText(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Text(
            "Location: ${item.location}",
            style: StyledText().descriptionText(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _image() {
    return SizedBox(
      width: 80,
      child: Image.network(
        item.image,
        fit: BoxFit.cover,
      ),
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
