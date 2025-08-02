import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';
import 'package:flutter/material.dart';

class ImagePickerUtil {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImage(BuildContext context) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      if (context.mounted) {
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Error picking image',
          message: 'Failed to pick image: $e',
        );
      }
    }
    return null;
  }
}
