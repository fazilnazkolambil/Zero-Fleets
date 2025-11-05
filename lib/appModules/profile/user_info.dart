import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:zero/appModules/profile/profile_controller.dart';
import 'package:zero/core/const_page.dart';
import 'package:zero/core/global_variables.dart';

class UserInfoPage extends StatelessWidget {
  const UserInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());
    controller.loadUserData(currentUser!.toMap());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Info'),
        actions: [
          Obx(() => IconButton(
                icon:
                    Icon(controller.isEditing.value ? Icons.close : Icons.edit),
                onPressed: controller.toggleEdit,
              )),
        ],
      ),
      body: Obx(() => SingleChildScrollView(
            // padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: controller.isEditing.value
                      ? () {
                          Fluttertoast.showToast(
                              msg:
                                  'Cannot update profile picture at the moment. Please try after some time',
                              backgroundColor: Colors.red);
                        }
                      : null,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      controller.profilePicUrl.value,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                CustomWidgets().textField(
                    label: 'Full name',
                    hintText: 'Enter your full name',
                    textController: controller.nameController,
                    textCapitalization: TextCapitalization.words,
                    readOnly: !controller.isEditing.value,
                    textInputType: TextInputType.name),
                CustomWidgets().textField(
                    label: 'Phone number',
                    hintText: 'Enter your phone number',
                    textController: controller.phoneController,
                    readOnly: true,
                    textInputType: TextInputType.number,
                    maxLength: 10,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text('+91'),
                    )),
                CustomWidgets().textField(
                    label: 'Email',
                    hintText: 'Enter your email',
                    textController: controller.emailController,
                    readOnly: !controller.isEditing.value,
                    textInputType: TextInputType.emailAddress,
                    textCapitalization: TextCapitalization.none,
                    prefixIcon: const Icon(Icons.email_outlined)),
                // controller.isEditing.value
                //     ? ImageUpload(
                //         label: 'Aadhaar Card *',
                //         uploadLabel: 'aadhaar_card',
                //         controller: Get.put(AuthController()),
                //         folderName: 'Id proofs')
                //     : ListTile(
                //         onTap: () {
                //           launchUrl(Uri.parse(controller.aadhaarUrl.value));
                //         },
                //         title: const Text('Aadhaar'),
                //         trailing: const Icon(Icons.arrow_forward_ios_rounded),
                //       ),
                const SizedBox(height: 20),
                if (controller.isEditing.value)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: ColorConst.primaryColor,
                        foregroundColor: Colors.black),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    onPressed: controller.isEditLoading.value
                        ? null
                        : () => controller.editUserInfo(),
                  ),
              ],
            ),
          )),
    );
  }
}
