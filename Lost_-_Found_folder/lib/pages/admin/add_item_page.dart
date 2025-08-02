import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lost_and_found_app/auth/auth_service.dart';
import 'package:lost_and_found_app/models/lost_item.dart';
import 'package:lost_and_found_app/services/item_service.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';
import 'package:lost_and_found_app/utils/image_picker_util.dart';
import 'package:uuid/uuid.dart'; // For generating item ID

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _claimInstructionsController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();
  final ImagePickerUtil _imagePickerUtil = ImagePickerUtil();
  final Uuid _uuid = const Uuid();

  Future<void> _pickImage() async {
    final File? image = await _imagePickerUtil.pickImage(context);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _submitItem() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Missing Image',
          message: 'Please select an image for the lost item.',
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });
      CustomDialogs.showLoadingDialog(context, message: 'Adding item...');

      try {
        final String? currentUserId = _authService.getCurrentUserId();
        if (currentUserId == null) {
          throw Exception('User not logged in.');
        }

        final LostItem newItem = LostItem(
          id: _uuid.v4(), // Generate a unique ID for the new item
          createdAt: DateTime.now(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          locationFound: _locationController.text.trim(),
          claimInstructions: _claimInstructionsController.text.trim().isEmpty
              ? null
              : _claimInstructionsController.text.trim(),
          status: AppConstants.itemStatusActive,
          postedBy: currentUserId,
        );

        await _itemService.addLostItem(newItem, _selectedImage);

        if (mounted) {
          CustomDialogs.hideLoadingDialog(context);
          CustomDialogs.showAlertDialog(
            context: context,
            title: 'Success',
            message: 'Lost item added successfully!',
            onButtonPressed: () {
              Navigator.of(context).pop(); // Pop the alert dialog
              Navigator.of(context).pop(); // Pop the AddItemPage
            },
          );
        }
      } catch (e) {
        if (mounted) {
          CustomDialogs.hideLoadingDialog(context);
          CustomDialogs.showAlertDialog(
            context: context,
            title: 'Error',
            message: 'Failed to add item: $e',
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _claimInstructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Lost Item'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Tap to select image',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Item Title',
                  hintText: 'e.g., Blue Water Bottle',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title for the item.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g., Has a few scratches, black cap',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location Found',
                  hintText: 'e.g., Canteen, Library, Block A, Room 101',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter where the item was found.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _claimInstructionsController,
                decoration: const InputDecoration(
                  labelText: 'Claim Instructions (Optional)',
                  hintText: 'e.g., Contact security at front desk, show ID',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitItem,
                      child: const Text('Add Lost Item'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
