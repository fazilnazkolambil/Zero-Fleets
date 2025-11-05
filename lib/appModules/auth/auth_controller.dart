import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zero/appModules/auth/onboarding_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zero/core/global_variables.dart';
import 'package:zero/models/user_model.dart';

class AuthController extends GetxController {
  String? userId;
  final box = Hive.box('zeroCache');

  TextEditingController fullnameController = TextEditingController();
  TextEditingController phonenumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  RxBool onboarded = false.obs;
  final loginFormkey = GlobalKey<FormState>();
  final signupFormkey = GlobalKey<FormState>();
  RxString authStatus = AuthStatus.initial.obs;
  RxString authError = ''.obs;
  String _verificationId = '';
  RxBool isLoading = false.obs;

  Future<void> checkAuth() async {
    // logoutUser();
    var user = _auth.currentUser;
    final userCache = box.get('user');
    if (user != null && userCache != null) {
      final cacheUser = jsonDecode(userCache);
      currentUser = UserModel.fromMap(cacheUser);
      DocumentSnapshot userData =
          await _firestore.collection('users').doc(currentUser!.uid).get();
      currentUser = UserModel.fromMap(userData.data() as Map<String, dynamic>);
      if (currentUser!.userRole == null) {
        Get.off(() => OnboardingPage());
      } else {
        Get.offNamed('/home');
      }
    } else {
      Get.offNamed('/login');
    }
  }

  verifyPhoneNumber() async {
    try {
      authStatus.value = AuthStatus.sendingOTP;
      await _auth.verifyPhoneNumber(
        phoneNumber: '+91${phonenumberController.text}',
        verificationCompleted: (phoneAuthCredential) {
          signInUser(phoneAuthCredential);
        },
        verificationFailed: (error) {
          authStatus.value = AuthStatus.error;
          authError.value =
              error.message ?? 'Error verifying phone number. Please try again';
        },
        codeSent: (verificationId, forceResendingToken) {
          authStatus.value = AuthStatus.otpSent;
          _verificationId = verificationId;
          Fluttertoast.showToast(
              msg: 'OTP sent to +91${phonenumberController.text}');
        },
        codeAutoRetrievalTimeout: (verificationId) {
          if (authStatus.value == AuthStatus.sendingOTP) {
            authStatus.value = AuthStatus.otpSent;
          }
        },
      );
    } catch (e) {
      authStatus.value = AuthStatus.error;
      authError.value = 'Error sending OTP : $e';
    }
  }

  verifyOtp() async {
    try {
      authStatus.value = AuthStatus.verifyingOTP;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otpController.text,
      );
      await signInUser(credential);
    } catch (e) {
      authStatus.value = AuthStatus.otpSent;
      authError.value = 'Invalid OTP';
    }
  }

  signInUser(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      userId = userCredential.user!.uid;
      if (userCredential.additionalUserInfo!.isNewUser) {
        Get.offNamed('/signup');
      }
      var user = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      if (user.data() == null) {
        Get.offNamed('/signup');
      } else {
        currentUser = UserModel.fromMap(user.data() as Map<String, dynamic>);
        box.put('user', jsonEncode(user.data()));
        if (currentUser!.userRole == null) {
          Get.offAll(() => OnboardingPage());
        } else {
          // if (currentUser!.userRole == 'FLEET_OWNER') {
          //   loadFleet();
          // }
          Get.offAllNamed('/home');
        }
      }
      authStatus.value = AuthStatus.initial;
      otpController.clear();
    } on FirebaseAuthException catch (e) {
      authStatus.value = AuthStatus.otpSent;
      authError.value = e.message ?? 'Authentication failed';
    }
  }

  Map<String, dynamic> uploads = {};
  pickImage(
      {required ImageSource source,
      required String label,
      required String folderName}) async {
    var pickImage = await ImagePicker().pickImage(source: source);
    if (pickImage != null) {
      String imageKey = '${userId ?? currentUser!.uid}/$folderName/$label';
      uploads[label] = {
        'image_file': File(pickImage.path),
        'image_path': pickImage.path,
        'image_key': imageKey
      };
    }
  }

  Future<String?> uploadImage({required String uploadLabel}) async {
    try {
      isLoading.value = true;
      final file = uploads[uploadLabel];
      final storageRef = _storage.ref().child(file['image_key']);
      await storageRef.putFile(file['image_file']);
      final downloadUrl = await storageRef.getDownloadURL();
      uploads[uploadLabel]['image_url'] = downloadUrl;
      isLoading.value = false;
      return downloadUrl;
    } on FirebaseException catch (e) {
      isLoading.value = false;
      log('Upload error: $e');
      return null;
    }
  }

  Future<bool> updateUserDetails() async {
    try {
      isLoading.value = true;
      UserModel userModel = UserModel(
          uid: userId ?? currentUser!.uid,
          fullName: fullnameController.text.trim(),
          phoneNumber: phonenumberController.text,
          email:
              emailController.text.isEmpty ? null : emailController.text.trim(),
          licenceUrl: uploads['driving_licence']['image_url'],
          profilePicUrl: uploads['profile_picture']['image_url'],
          aadhaarUrl: uploads['aadhaar_card']['image_url'],
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
          status: 'ACTIVE',
          wallet: 0,
          lastVehicle: '');
      await _firestore.collection('users').doc(userId).set(userModel.toMap());
      currentUser = UserModel.fromMap(userModel.toMap());
      box.put('user', jsonEncode(userModel.toMap()));
      isLoading.value = false;
      return true;
    } catch (e) {
      isLoading.value = false;
      log("Error in updateUserDetails : $e");
      return false;
    }
  }

  clearAll() {
    authStatus.value = AuthStatus.initial;
    phonenumberController.clear();
    otpController.clear();
    fullnameController.clear();
    emailController.clear();
    uploads.clear();
  }

  Future<void> logoutUser() async {
    try {
      clearAll();
      await FirebaseAuth.instance.signOut();
      currentFleet = null;
      currentUser = null;
      await box.clear();
      authStatus.value = AuthStatus.initial;
      Get.offAllNamed('/login');
    } catch (e) {
      log('Logout error: $e');
    }
  }
}

class AuthStatus {
  static const String initial = 'initial';
  static const String sendingOTP = 'sendingOTP';
  static const String otpSent = 'otpSent';
  static const String verifyingOTP = 'verifyingOTP';
  static const String registerUser = 'registerUser';
  static const String error = 'error';
}
