import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/appModules/auth/image_upload.dart';
import 'package:zero/appModules/auth/onboarding_page.dart';
import 'package:zero/appModules/profile/profile_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class SignupPage extends GetView<AuthController> {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    h = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: Image.asset('assets/icons/logo.png'),
          toolbarHeight: h * 0.1,
          leadingWidth: 120,
          actions: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(
                () => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        backgroundColor: ColorConst.primaryColor),
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            if (controller.signupFormkey.currentState!
                                .validate()) {
                              bool isSuccess =
                                  await controller.updateUserDetails();
                              if (isSuccess) {
                                Get.offAll(() => OnboardingPage());
                              }
                              controller.clearAll();
                            }
                          },
                    child: controller.isLoading.value
                        ? const Center(child: CupertinoActivityIndicator())
                        : Text(
                            'Save',
                            style: Get.textTheme.bodySmall!.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )),
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: controller.signupFormkey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidgets().textField(
                        readOnly: true,
                        label: 'Mobile number *',
                        hintText: 'Enter your Mobile number *',
                        textController: controller.phonenumberController,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(15),
                          child: Text('+91'),
                        ),
                        suffixIcon: TextButton(
                            onPressed: () {
                              controller.authStatus.value = AuthStatus.initial;
                              Get.offAllNamed('/login');
                            },
                            child: const Text('Edit')),
                        textInputType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your Mobile number';
                          }
                          if (value.length != 10) {
                            return 'Enter a valid Mobile number';
                          }
                          return null;
                        },
                      ),
                      CustomWidgets().textField(
                        label: 'Full name *',
                        hintText: 'Enter your full name*',
                        textController: controller.fullnameController,
                        prefixIcon: const Icon(Icons.person_2),
                        textCapitalization: TextCapitalization.words,
                        textInputType: TextInputType.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your name';
                          } else {
                            return null;
                          }
                        },
                      ),
                      CustomWidgets().textField(
                        label: 'Email (optional)',
                        hintText: 'Enter your email',
                        textController: controller.emailController,
                        textCapitalization: TextCapitalization.none,
                        prefixIcon: const Icon(Icons.email),
                        textInputType: TextInputType.emailAddress,
                      ),
                      ImageUpload(
                        label: 'Profile Picture *',
                        uploadLabel: 'profile_picture',
                        controller: controller,
                        folderName: 'Id proofs',
                      ),
                      ImageUpload(
                          label: 'Driving Licence *',
                          uploadLabel: 'driving_licence',
                          controller: controller,
                          folderName: 'Id proofs'),
                      ImageUpload(
                          label: 'Aadhaar Card *',
                          uploadLabel: 'aadhaar_card',
                          controller: controller,
                          folderName: 'Id proofs'),
                    ],
                  ),
                ),
              ),
            ),
            _buildFooterSection()
          ],
        ));
  }

  Widget _buildFooterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () =>
              Get.put(ProfileController()).openLink(urlSuffix: 'terms'),
          child: const Text(
            'Terms & Conditions',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        const Text(
          ' • ',
          style: TextStyle(color: Colors.white54),
        ),
        TextButton(
          onPressed: () =>
              Get.put(ProfileController()).openLink(urlSuffix: 'privacy'),
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
