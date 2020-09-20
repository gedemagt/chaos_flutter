import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timer/models/gym.dart';
import 'package:timer/models/rute.dart';
import 'package:timer/models/user.dart';
import 'package:timer/models/user.dart';
import 'package:timer/providers/database.dart';
import 'package:timer/util.dart';

class FirebaseDatabase extends Database {

  @override
  Future<Gym> createGym(String name, User admin, {List<String> sectors, List<String> tags}) async {
    throw Exception("Not implemented!");
  }

  @override
  Future<Rute> createRute(String name, String sector, String imageUUID, File image, {var onProgress}) async {
    throw Exception("Not implemented!");
  }

  @override
  Future<void> deleteGym(Gym gym) {
    throw Exception("Not implemented!");
  }

  @override
  Future<void> deleteRute(Rute rute) async {
    throw Exception("Not implemented!");
  }

  @override
  Future<Gym> getGym(String uuid) async {
    throw Exception("Not implemented!");
  }

  @override
  Future<Rute> getRute(String uuid) async {
    throw Exception("Not implemented!");
  }

  @override
  Future<User> getUser(String uuid) async {
    throw Exception("Not implemented!");
  }

  @override
  Future<void> refreshGyms() async {
    throw Exception("Not implemented!");
  }

  @override
  Future<void> refreshRutes() async {
    throw Exception("Not implemented!");
  }

  @override
  Future<void> refreshUsers() async {
    throw Exception("Not implemented!");
  }

  @override
  Future<Gym> saveGym(Gym gym) async {
    throw Exception("Not implemented!");
  }

  @override
  Future<Rute> saveRute(Rute rute) async {
    throw Exception("Not implemented!");
  }

  @override
  Future<User> saveUser(User user) async {
    throw Exception("Not implemented yet");
  }

  @override
  Future<void> init() async {
  }

  @override
  Future<Complete> complete(User u, Rute r, int tries) async {
    throw Exception("Not implemented!");
  }

  @override
  User getLoggedInUser() {
    throw Exception("Not implemented!");
  }

  @override
  bool isLoggedIn() {
    throw Exception("Not implemented!");
  }

  @override
  Future<User> createUser(String name, String email, String password) async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.trim(), password: password.trim());
    var current_user = await FirebaseAuth.instance.currentUser();
    var current_user_doc_ref = await Firestore.instance.collection("users").document(current_user.uid).get();
    var users = Firestore.instance.collection('userMeta');

    var data = {
      'username': name.trim(),
      'role': "USER",
      'user': current_user_doc_ref.reference,
      'gym': nullptr
    };

    await users.add(data);

    data["uuid"] = current_user.uid;
    data["name"] = data["username"];
    data["date"] = format(current_user.metadata.creationTime);

    return User.fromJson(data);
  }

  @override
  Future<User> login(String username, String password) async {
    print(username);
    try {
      var userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username.trim(),
          password: password.trim()
      );
    } catch (e) {
      print(e);
      throw e;
//      if (e.code == 'user-not-found') {
//        print('No user found for that email.');
//      } else if (e.code == 'wrong-password') {
//        print('Wrong password provided for that user.');
//      }
    }
    var current_user = await FirebaseAuth.instance.currentUser();
    var current_user_doc_ref = await Firestore.instance.collection("users").document(current_user.uid).get();
    var current_user_meta = await Firestore.instance.collection("userMeta").where("user", isEqualTo: current_user_doc_ref.reference).getDocuments();


    var data = {
      'name': current_user_meta.documents[0].data['username'],
      'role': current_user_meta.documents[0].data['role'],
      'gym': nullptr,
      'uuid': current_user.uid,
      'date': format(current_user.metadata.creationTime)
    };

    return User.fromJson(data);
  }

  @override
  Future<void> logout() async {
    throw Exception("Not implemented!");
  }

  @override
  Future<Image> getImage(String uuid) async {
    throw Exception("Not implemented!");
  }

}