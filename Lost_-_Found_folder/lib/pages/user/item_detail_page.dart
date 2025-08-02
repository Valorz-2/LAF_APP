import 'package:flutter/material.dart';
import 'package:lost_and_found_app/auth/auth_service.dart';
import 'package:lost_and_found_app/models/claim_request.dart';
import 'package:lost_and_found_app/models/lost_item.dart';
import 'package:lost_and_found_app/services/claim_service.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';
import 'package:uuid/uuid.dart'; // For generating claim ID

class ItemDetailPage extends StatefulWidget {
  final LostItem item;
  const ItemDetailPage({super.key, required this.item});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final ClaimService _claimService = ClaimService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  final Uuid _uuid = const Uuid();
  bool _isLoading = false;

  Future<void> _submitClaim() async {
    final String? userId = _authService.getCurrentUserId();
    if (userId == null) {
      CustomDialogs.showAlertDialog(
        context: context,
        title: 'Authentication Required',
        message: 'Please log in to submit a claim.',
      );
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      CustomDialogs.showAlertDialog(
        context: context,
        title: 'Message Required',
        message: 'Please explain why this item is yours.',
      );
      return;
    }

    final bool? confirm = await CustomDialogs.showConfirmationDialog(
      context: context,
      title: 'Confirm Claim',
      message: 'Are you sure you want to submit a claim for "${widget.item.title}"?',
    );

    if (confirm == true) {
      setState(() {
        _isLoading = true;
      });
      CustomDialogs.showLoadingDialog(context, message: 'Submitting claim...');

      try {
        final ClaimRequest newClaim = ClaimRequest(
          id: _uuid.v4(),
          createdAt: DateTime.now(),
          itemId: widget.item.id,
          requesterId: userId,
          requesterMessage: _messageController.text.trim(),
          status: AppConstants.claimStatusPending,
        );

        await _claimService.createClaimRequest(newClaim);

        if (mounted) {
          CustomDialogs.hideLoadingDialog(context);
          CustomDialogs.showAlertDialog(
            context: context,
            title: 'Claim Submitted!',
            message: 'Your claim for "${widget.item.title}" has been submitted. You will be notified of the status.',
            onButtonPressed: () {
              Navigator.of(context).pop(); // Dismiss alert
              Navigator.of(context).pop(); // Go back to lost items list
            },
          );
        }
      } catch (e) {
        if (mounted) {
          CustomDialogs.hideLoadingDialog(context);
          CustomDialogs.showAlertDialog(
            context: context,
            title: 'Error Submitting Claim',
            message: 'Failed to submit claim: $e',
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
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Item Detail Page: Image URL for ${widget.item.title}: ${widget.item.imageUrl}'); // Debug print
    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.item.imageUrl != null && widget.item.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.item.imageUrl!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print('Image loading error in detail page for ${widget.item.imageUrl}: $error'); // Debug print for image loading
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image, size: 80, color: Colors.grey)),
                    );
                  },
                ),
              )
            else
              Container(
                height: 250,
                color: Colors.grey[300],
                child: const Center(child: Text('No Image Available')),
              ),
            const SizedBox(height: 20),
            Text(
              widget.item.title,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            const SizedBox(height: 10),
            Text(
              'Found at: ${widget.item.locationFound}',
              style: const TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            if (widget.item.description != null && widget.item.description!.isNotEmpty)
              Text(
                'Description: ${widget.item.description}',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            if (widget.item.description != null && widget.item.description!.isNotEmpty)
              const SizedBox(height: 10),
            if (widget.item.claimInstructions != null && widget.item.claimInstructions!.isNotEmpty)
              Text(
                'Claim Instructions: ${widget.item.claimInstructions}',
                style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
              ),
            if (widget.item.claimInstructions != null && widget.item.claimInstructions!.isNotEmpty)
              const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'Claim this item:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[700]),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Why is this item yours?',
                hintText: 'e.g., I lost this on Monday, it has a small dent on the side...',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: widget.item.status == AppConstants.itemStatusActive ? _submitClaim : null, // Disable if not active
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50), // Make button full width
                      backgroundColor: widget.item.status == AppConstants.itemStatusActive ? Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}) : Colors.grey,
                    ),
                    child: Text(
                      widget.item.status == AppConstants.itemStatusActive ? 'Submit Claim Request' : 'Item ${widget.item.status.toUpperCase()}',
                      style: Theme.of(context).elevatedButtonTheme.style?.textStyle?.resolve({}),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
