import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zero/appModules/auth/auth_controller.dart';

class ImageUpload extends StatelessWidget {
  final String label;
  final String uploadLabel;
  final AuthController controller;
  final String folderName;
  const ImageUpload(
      {super.key,
      required this.label,
      required this.uploadLabel,
      required this.controller,
      required this.folderName});

  @override
  Widget build(BuildContext context) {
    return FormField<String?>(
      initialValue: null,
      validator: (url) {
        if (url == null) {
          return 'Please upload $label';
        }
        return null;
      },
      builder: (field) {
        return ListTile(
          title: Text(label, style: Get.textTheme.bodyMedium),
          subtitle: field.value != null
              ? Text(
                  'Completed',
                  style: Get.textTheme.bodySmall!.copyWith(color: Colors.green),
                )
              : field.hasError
                  ? Text(
                      field.errorText!,
                      style:
                          Get.textTheme.bodySmall!.copyWith(color: Colors.red),
                    )
                  : null,
          trailing: field.value != null
              ? const Icon(Icons.verified, size: 20, color: Colors.green)
              : const Icon(Icons.arrow_forward_ios, size: 15),
          onTap: () {
            _showImageSource(uploadLabel, field);
          },
        );
      },
    );
  }

  void _showImageSource(String uploadLabel, FormFieldState field) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Get.theme.cardColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Image Source',
              style: Get.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              onTap: () async {
                Get.back();
                await controller.pickImage(
                    source: ImageSource.camera,
                    label: uploadLabel,
                    folderName: folderName);
                confirmImageUpload(uploadLabel, field);
                // field.didChange(controller.uploads[label]);
              },
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              titleTextStyle: Get.textTheme.bodyMedium,
            ),
            const Divider(
              color: Colors.white12,
            ),
            ListTile(
              onTap: () async {
                Get.back();
                await controller.pickImage(
                    source: ImageSource.gallery,
                    label: uploadLabel,
                    folderName: folderName);
                confirmImageUpload(uploadLabel, field);
              },
              leading: const Icon(Icons.photo_library),
              titleTextStyle: Get.textTheme.bodyMedium,
              title: const Text('Gallery'),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void confirmImageUpload(String uploadLabel, FormFieldState field) {
    Get.dialog(
        barrierDismissible: false,
        AlertDialog(
          content: SizedBox(
              height: 150,
              child: Image.file(
                controller.uploads[uploadLabel]['image_file'],
                fit: BoxFit.cover,
              )),
          actions: [
            TextButton(
                onPressed: () {
                  controller.uploads.remove(uploadLabel);
                  controller.isLoading.value = false;
                  Get.back();
                },
                child: const Text('Cancel')),
            Obx(
              () => TextButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          String? imageUrl = await controller.uploadImage(
                              uploadLabel: uploadLabel);
                          if (imageUrl != null) {
                            field.didChange(imageUrl);
                            Get.back();
                          }
                        },
                  child: controller.isLoading.value
                      ? const CupertinoActivityIndicator()
                      : const Text('Confirm')),
            )
          ],
        ));
  }
}
