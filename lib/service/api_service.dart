import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/item_model.dart';

class ApiService {
  Future<List<Item>> fetchItemsFromFirestore({required String state}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection(state).get();

      List<Item> items = snapshot.docs.map((doc) {
        return Item.fromJson(doc.data());
      }).toList();

      return items;
    } catch (e) {
      print("Error fetching items: $e");
      return [];
    }
  }

  Future<void> addItemToFirestore(Item item) async {
    try {
      final CollectionReference itemsCollection =
          FirebaseFirestore.instance.collection(item.state);

      String imageUrl = await uploadImageToSupabase(item.image);
      int id = await _generateUniqueItemId(itemsCollection);

      item.id = id;
      item.image = imageUrl;
      item.timestamp = DateTime.now();

      await itemsCollection.doc(item.id.toString()).set(item.toJson());
      print('Item saved successfully!');
    } catch (e) {
      print('Error saving item: $e');
      throw Exception('Failed to save item');
    }
  }

  Future<void> changeItemStateInFirestore(Item item, String oldState) async {
    try {
      final CollectionReference currentCollection =
          FirebaseFirestore.instance.collection(oldState);

      final CollectionReference newCollection =
          FirebaseFirestore.instance.collection(item.state);

      await currentCollection.doc(item.id.toString()).delete();
      await newCollection.doc(item.id.toString()).set(item.toJson());

      print('Item state changed successfully!');
    } catch (e) {
      print('Error changing item state: $e');
      throw Exception('Failed to change item state');
    }
  }
}

/////////////////////////////////////////////////////////////////////////////////
Future<String> uploadImageToSupabase(String imagePath) async {
  try {
    final supabase = Supabase.instance.client;
    final file = File(imagePath);

    final randomName = _generateRandomName();
    final fileName = '$randomName.jpg';

    await supabase.storage.from('images').upload(fileName, file);

    final imageUrl = supabase.storage.from('images').getPublicUrl(fileName);
    return imageUrl;
  } catch (e) {
    print('Error uploading image: $e');
    throw Exception('Failed to upload image');
  }
}

String _generateRandomName({int length = 12}) {
  const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return List.generate(length, (index) => chars[random.nextInt(chars.length)])
      .join();
}

Future<int> _generateUniqueItemId(CollectionReference itemsCollection) async {
  final random = Random();
  int newId;

  while (true) {
    // Generate a random ID
    newId = random.nextInt(100000000);

    final querySnapshot =
        await itemsCollection.where('id', isEqualTo: newId).get();

    if (querySnapshot.docs.isEmpty) {
      break;
    }
  }

  return newId;
}
