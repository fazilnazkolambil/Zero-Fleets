import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/auth/auth_controller.dart';
import 'package:zero/appModules/auth/image_upload.dart';
import 'package:zero/appModules/auth/onboarding_page.dart';
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

  // Widget _uploads({required String label, required String uploadLabel}) {
  //   return FormField<String?>(
  //     initialValue: null,
  //     validator: (url) {
  //       if (url == null) {
  //         return 'Please upload $label';
  //       }
  //       return null;
  //     },
  //     builder: (field) {
  //       return ListTile(
  //         title: Text(label, style: Get.textTheme.bodyMedium),
  //         subtitle: field.value != null
  //             ? Text(
  //                 'Completed',
  //                 style: Get.textTheme.bodySmall!.copyWith(color: Colors.green),
  //               )
  //             : field.hasError
  //                 ? Text(
  //                     field.errorText!,
  //                     style:
  //                         Get.textTheme.bodySmall!.copyWith(color: Colors.red),
  //                   )
  //                 : null,
  //         trailing: field.value != null
  //             ? const Icon(Icons.verified, size: 20, color: Colors.green)
  //             : const Icon(Icons.arrow_forward_ios, size: 15),
  //         onTap: () {
  //           _showImageSource(uploadLabel, field);
  //         },
  //       );
  //     },
  //   );
  // }

  // void _showImageSource(String uploadLabel, FormFieldState field) {
  //   Get.bottomSheet(
  //     Container(
  //       padding: const EdgeInsets.symmetric(vertical: 20),
  //       decoration: BoxDecoration(
  //         color: Get.theme.cardColor,
  //         borderRadius: const BorderRadius.only(
  //           topLeft: Radius.circular(20),
  //           topRight: Radius.circular(20),
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Container(
  //             width: 40,
  //             height: 4,
  //             decoration: BoxDecoration(
  //               color: Colors.grey[300],
  //               borderRadius: BorderRadius.circular(2),
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           Text(
  //             'Select Image Source',
  //             style: Get.textTheme.bodyMedium?.copyWith(
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           ListTile(
  //             onTap: () async {
  //               Get.back();
  //               await controller.pickImage(
  //                   source: ImageSource.camera,
  //                   label: uploadLabel,
  //                   folderName: 'Id proofs');
  //               confirmImageUpload(uploadLabel, field);
  //               // field.didChange(controller.uploads[label]);
  //             },
  //             leading: const Icon(Icons.camera_alt),
  //             title: const Text('Camera'),
  //             titleTextStyle: Get.textTheme.bodyMedium,
  //           ),
  //           const Divider(
  //             color: Colors.white12,
  //           ),
  //           ListTile(
  //             onTap: () async {
  //               Get.back();
  //               await controller.pickImage(
  //                   source: ImageSource.gallery,
  //                   label: uploadLabel,
  //                   folderName: 'Id proofs');
  //               confirmImageUpload(uploadLabel, field);
  //             },
  //             leading: const Icon(Icons.photo_library),
  //             titleTextStyle: Get.textTheme.bodyMedium,
  //             title: const Text('Gallery'),
  //           ),
  //         ],
  //       ),
  //     ),
  //     isScrollControlled: true,
  //   );
  // }

  // void confirmImageUpload(String uploadLabel, FormFieldState field) {
  //   Get.dialog(
  //       barrierDismissible: false,
  //       AlertDialog(
  //         content: Image.file(controller.uploads[uploadLabel]['image_file']),
  //         actions: [
  //           TextButton(
  //               onPressed: () {
  //                 controller.uploads.remove(uploadLabel);
  //                 Get.back();
  //               },
  //               child: const Text('Cancel')),
  //           Obx(
  //             () => TextButton(
  //                 onPressed: controller.isLoading.value
  //                     ? null
  //                     : () async {
  //                         String? imageUrl = await controller.uploadImage(
  //                             uploadLabel: uploadLabel);
  //                         if (imageUrl != null) {
  //                           field.didChange(imageUrl);
  //                           Get.back();
  //                         }
  //                       },
  //                 child: controller.isLoading.value
  //                     ? const CupertinoActivityIndicator()
  //                     : const Text('Confirm')),
  //           )
  //         ],
  //       ));
  // }

  Widget _buildFooterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {},
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
          onPressed: () {},
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
