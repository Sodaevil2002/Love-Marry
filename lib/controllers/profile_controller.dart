import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:love_and_marry_app/consts/consts.dart';
import 'package:love_and_marry_app/consts/firebase_consts.dart';
import 'package:love_and_marry_app/services/firestore_services.dart';
import 'package:path/path.dart';

class ProfileController extends GetxController{
var profileImagePath =''.obs;
var profileImageLink = '';
var isLoading = false.obs;

//textfield
  var nameController = TextEditingController();
  var oldpassController = TextEditingController();
  var newpassController = TextEditingController();

changeImage(context) async {
  try{
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (img == null) return;
    profileImagePath.value = img.path;
  }
  on PlatformException catch (e) {
    VxToast.show(context, msg: toString());
  }
}

upLoadProfileImage () async {
  var filename = basename(profileImagePath.value);
  var destination ='image/${currentUser!.uid}/$filename';
  Reference ref = FirebaseStorage.instance.ref().child(destination);
  await ref.putFile(File(profileImagePath.value));
  profileImageLink = await ref.getDownloadURL();
}

  updateProfile({name, password, imgUrl}) async {
    var store = firestore.collection(usersCollection).doc(currentUser!.uid);
    await store.set({
      'name': name,
      'password' : password,
      'imageUrl':  imgUrl
    },SetOptions(merge: true));
    isLoading(false);
  }

  changeAuthPassword({email, password,newpassword}) async {
  final cred = EmailAuthProvider.credential(email: email, password: password);
  await currentUser!.reauthenticateWithCredential(cred).then((value){
    currentUser!.updatePassword(newpassword);
  }).catchError((error){
    print(error.toString());
  });
  }
}