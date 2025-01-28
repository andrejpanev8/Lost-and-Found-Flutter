import 'package:flutter/material.dart';
import 'package:lost_and_found_app/service/api_service.dart';
import 'package:lost_and_found_app/service/auth_service.dart';
import 'package:lost_and_found_app/utils/state_constants.dart';

import '../data/item_model.dart';

class ItemsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  final List<Item> _lostItems = [];
  final List<Item> _foundItems = [];
  final List<Item> _userItems = [];

  bool _lostItemsLoaded = false;
  bool _foundItemsLoaded = false;
  bool _userItemsLoaded = false;
  bool _isLoading = false;

  ItemsProvider();

  bool get lostItemsLoaded => _lostItemsLoaded;
  bool get foundItemsLoaded => _foundItemsLoaded;
  bool get userItemsLoaded => _userItemsLoaded;
  bool get isLoading => _isLoading;

  List<Item> get lostItems => _lostItems.toList();
  List<Item> get foundItems => _foundItems.toList();
  List<Item> get userItems => _userItems.toList();

  Future<void> loadLostItems() async {
    if (!_lostItemsLoaded) {
      try {
        var remoteItems = await _apiService.fetchItemsFromFirestore(
            state: ItemCategory.lost.name);
        _lostItems.addAll(remoteItems);
      } catch (e) {
        print("$e");
      }
      _lostItemsLoaded = true;
      notifyListeners();
    }
  }

  Future<void> loadFoundItems() async {
    if (!_foundItemsLoaded) {
      try {
        var remoteItems = await _apiService.fetchItemsFromFirestore(
            state: ItemCategory.found.name);

        var newItems = remoteItems
            .where((item) =>
                !_foundItems.any((existingItem) => existingItem.id == item.id))
            .toList();

        _foundItems.addAll(newItems);
      } catch (e) {
        print("$e");
      }
      _foundItemsLoaded = true;
      notifyListeners();
    }
  }

  Future<void> loadUserItems() async {
    if (!_userItemsLoaded && _authService.currentUser != null) {
      try {
        final currentUserEmail = _authService.currentUser!.email;

        final userLostItemsFuture = _apiService
            .fetchItemsFromFirestore(state: ItemCategory.lost.name)
            .then((list) => list
                .where((item) => item.ownerEmail == currentUserEmail)
                .toList());

        final userFoundItemsFuture = _apiService
            .fetchItemsFromFirestore(state: ItemCategory.found.name)
            .then((list) => list
                .where((item) => item.ownerEmail == currentUserEmail)
                .toList());

        final results =
            await Future.wait([userLostItemsFuture, userFoundItemsFuture]);

        _userItems.addAll(results.expand((list) => list));
        _userItemsLoaded = true;
        notifyListeners();
      } catch (e) {
        print("$e");
      }
    }
  }

  Future<void> addItem({
    required String name,
    required String description,
    required String ownerName,
    required String ownerEmail,
    required String imagePath,
    required String locationName,
    required double lat,
    required double lng,
    required String contactInfo,
    required ItemCategory state,
    required double reward,
  }) async {
    final Item newItem = Item(
      id: 0,
      name: name,
      description: description,
      ownerName: ownerName,
      ownerEmail: ownerEmail,
      image: imagePath,
      location: locationName,
      longitude: lng,
      latitude: lat,
      contactInfo: contactInfo,
      state: state.name,
      reward: reward,
      timestamp: DateTime.now(),
    );

    state == ItemCategory.lost
        ? _lostItems.add(newItem)
        : state == ItemCategory.found
            ? _foundItems.add(newItem)
            : null;
    _userItems.add(newItem);

    _isLoading = true;
    notifyListeners();
    await _apiService.addItemToFirestore(newItem).then((_) {
      _isLoading = false;
    });
    notifyListeners();
  }

  Future<void> updateItem(
      {required Item item,
      required String name,
      required String description,
      required String imagePath,
      required String locationName,
      required double lat,
      required double lng,
      required ItemCategory state,
      double? reward}) async {
    deleteItem(item);
    addItem(
        name: name,
        description: description,
        ownerName: item.ownerName,
        ownerEmail: item.ownerEmail,
        imagePath: imagePath,
        locationName: locationName,
        lat: lat,
        lng: lng,
        contactInfo: item.contactInfo,
        state: state,
        reward: reward ?? 0);
    notifyListeners();
  }

  void resetUserItems() {
    _userItems.clear();
    _userItemsLoaded = false;
  }

  Future<void> markItemFound(Item item) async {
    if (!_lostItemsLoaded) loadLostItems();
    _foundItems.add(item);
    _lostItems.removeWhere((oldItem) => oldItem.id == item.id);
    item.state = ItemCategory.found.name;
    resetUserItems();
    await _apiService.changeItemStateInFirestore(item, ItemCategory.lost.name);
    notifyListeners();
  }

  Future<void> markItemRetrieved(Item item) async {
    if (!_userItemsLoaded) loadUserItems();
    _userItems.add(item);
    _foundItems.removeWhere((oldItem) => oldItem.id == item.id);
    item.state = ItemCategory.retrieved.name;
    resetUserItems();
    await _apiService.changeItemStateInFirestore(item, ItemCategory.found.name);
    notifyListeners();
  }

  Future<void> deleteItem(Item item) async {
    item.state == ItemCategory.lost.name
        ? _lostItems.removeWhere((oldItem) => oldItem.id == item.id)
        : item.state == ItemCategory.found.name
            ? _foundItems.removeWhere((oldItem) => oldItem.id == item.id)
            : null;
    _userItems.removeWhere((oldItem) => oldItem.id == item.id);
    await _apiService.removeItemFromFirestore(item);
    notifyListeners();
  }
}
