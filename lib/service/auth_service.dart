import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lost_and_found_app/data/DTO/user_DTO.dart';
import 'package:lost_and_found_app/providers/user_info_provider.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("Error during registration: ${e.message}");
      if (e.code == 'email-already-in-use') {
        log("The email address is already in use.");
      } else if (e.code == 'weak-password') {
        log("The password is too weak.");
      }
    } catch (e) {
      log("An unexpected error occurred: $e");
    }
    return null;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password, UserProvider userProvider) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userProvider.initializeUserInfo();
      return cred.user;
    } on FirebaseAuthException catch (e) {
      log("Error during login: ${e.message}");
      if (e.code == 'user-not-found') {
        log("No user found with this email.");
      } else if (e.code == 'wrong-password') {
        log("Incorrect password.");
      }
    } catch (e) {
      log("An unexpected error occurred: $e");
    }
    return null;
  }

  Future<void> logOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Error during sign out: $e");
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<void> updateUserDisplay({required String fullName}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateDisplayName(fullName);
      await user.reload();
    }
  }

  Future<void> updateUserProfile(
      {String? fullName,
      String? phoneNumber,
      String? profilePictureUrl,
      bool? contactEmail = true,
      bool? contactPhone = false}) async {
    final user = FirebaseAuth.instance.currentUser;

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'fullName': fullName,
      'email': user.email,
      'phoneNumber': phoneNumber,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'profilePicture': profilePictureUrl
    });
  }

  Future<UserDto> getUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final data = doc.data();
    if (data != null) {
      return UserDto.fromJson(data);
    } else {
      throw Exception("User data not found");
    }
  }
}
