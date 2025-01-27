import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:lost_and_found_app/providers/items_provider.dart';
import 'package:lost_and_found_app/providers/user_info_provider.dart';
import 'package:lost_and_found_app/service/map_service.dart';
import 'package:lost_and_found_app/utils/state_constants.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../data/item_model.dart';
import '../../utils/color_constants.dart';
import '../screens/map_screen.dart';

class AddItemPopup extends StatefulWidget {
  final ItemsProvider provider;
  final UserProvider userProvider = UserProvider();
  final ItemCategory state;
  final Item? item;

  AddItemPopup(
      {super.key, required this.provider, required this.state, this.item});

  @override
  State<AddItemPopup> createState() => _AddItemPopupState();
}

class _AddItemPopupState extends State<AddItemPopup> {
  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameController.text = widget.item!.name;
      _descriptionController.text = widget.item!.description;
      _locationController.text = widget.item!.location;
      _rewardController.text = widget.item!.reward.toString();
      _selectedLatLng = LatLng(widget.item!.latitude, widget.item!.longitude);
      _selectedImage = null;
      _selectedState = widget.item!.state == ItemCategory.lost.name
          ? ItemCategory.lost
          : widget.item!.state == ItemCategory.found.name
              ? ItemCategory.found
              : ItemCategory.retrieved;
    }
  }

  ItemCategory? _selectedState;

  LatLng? _selectedLatLng = LatLng(41.99812940, 21.42543550);
  XFile? _selectedImage;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var provider = context.read<UserProvider>();
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _image(),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Item Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 6.0),
              GestureDetector(
                onTap: _callMap,
                child: Container(
                  height: 120,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: greyColor[200],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: greyColor),
                  ),
                  child: Center(child: _mapSection()),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _rewardController,
                decoration: const InputDecoration(
                  labelText: "Reward (optional)",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              const Text(
                "Contact info:",
                style: TextStyle(fontSize: 16.0),
              ),
              Text(
                provider.getContactInfo(),
                style: TextStyle(fontSize: 14.0, color: greyColor),
              ),
              const SizedBox(height: 16.0),
              _stateDropdown(),
              const SizedBox(height: 16.0),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stateDropdown() {
    return widget.item != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Item State",
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: 8.0),
              DropdownButtonFormField<ItemCategory>(
                value: _selectedState,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ItemCategory.values
                    .map(
                      (category) => DropdownMenuItem<ItemCategory>(
                        value: category,
                        child: Text(category.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
              ),
            ],
          )
        : const SizedBox.shrink();
  }

  Future<void> _callMap() async {
    final result = await MapService().openMap(
      context,
      MaterialPageRoute(builder: (context) => MapScreen()),
    );
    setState(() {
      _selectedLatLng = result;
    });
  }

  Widget _mapSection() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _selectedLatLng == null
          ? [
              const Icon(Icons.location_on, size: 40),
              Text(
                "Tap to select location",
                style: TextStyle(fontSize: 16.0),
              ),
            ]
          : [
              CachedNetworkImage(
                imageUrl: MapService().generateMapUrl(
                  _selectedLatLng!.latitude,
                  _selectedLatLng!.longitude,
                ),
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: double.infinity,
                height: 80,
                fit: BoxFit.cover,
              ),
            ],
    );
  }

  Future<void> _saveItem() async {
    try {
      if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all required fields")),
        );
        return;
      }

      if (widget.item == null) {
        await widget.provider.addItem(
          name: _nameController.text,
          description: _descriptionController.text,
          ownerName: widget.userProvider.fullName,
          ownerEmail: widget.userProvider.email,
          imagePath: _selectedImage?.path ?? '',
          locationName: _locationController.text,
          lat: _selectedLatLng!.latitude,
          lng: _selectedLatLng!.longitude,
          contactInfo: widget.userProvider.getContactInfo(),
          reward: _rewardController.text.isNotEmpty
              ? double.parse(_rewardController.text)
              : 0,
          state: widget.state,
        );
      } else {
        await widget.provider.updateItem(
            item: widget.item!,
            name: _nameController.text,
            description: _descriptionController.text,
            imagePath: _selectedImage?.path ?? widget.item!.image,
            locationName: _locationController.text,
            lat: _selectedLatLng!.latitude,
            lng: _selectedLatLng!.longitude,
            reward: _rewardController.text.isNotEmpty
                ? double.parse(_rewardController.text)
                : null,
            state: _selectedState!);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Widget _image() {
    return Container(
      height: 80,
      width: 80,
      decoration: BoxDecoration(
        color: greyColor[200],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: greyColor),
        image: _selectedImage != null
            ? DecorationImage(
                image: FileImage(
                  File(_selectedImage!.path),
                ),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: _selectedImage == null
          ? const Icon(Icons.add, size: 40, color: greyColor)
          : null,
    );
  }

  Widget _saveButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _saveItem,
            style: ElevatedButton.styleFrom(
              backgroundColor: greenPrimary,
              padding: const EdgeInsets.symmetric(vertical: 6.0),
            ),
            child: const Text(
              "Save",
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ],
    );
  }
}
