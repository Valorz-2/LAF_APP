import 'package:flutter/material.dart';
import 'package:lost_and_found_app/models/claim_request.dart';
import 'package:lost_and_found_app/models/lost_item.dart';
import 'package:lost_and_found_app/models/user_profile.dart';
import 'package:lost_and_found_app/services/claim_service.dart';
import 'package:lost_and_found_app/services/item_service.dart';
import 'package:lost_and_found_app/auth/auth_service.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';
import 'package:intl/intl.dart'; // For date formatting

class ManageClaimsPage extends StatefulWidget {
  const ManageClaimsPage({super.key});

  @override
  State<ManageClaimsPage> createState() => _ManageClaimsPageState();
}

class _ManageClaimsPageState extends State<ManageClaimsPage> {
  final ClaimService _claimService = ClaimService();
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();

  final Map<String, LostItem> _lostItemsCache = {};
  final Map<String, UserProfile> _userProfilesCache = {};

  Future<LostItem?> _getLostItem(String itemId) async {
    if (_lostItemsCache.containsKey(itemId)) {
      return _lostItemsCache[itemId];
    }
    final item = await _itemService.getLostItemById(itemId);
    if (item != null) {
      _lostItemsCache[itemId] = item;
    }
    return item;
  }

  Future<UserProfile?> _getUserProfile(String userId) async {
    if (_userProfilesCache.containsKey(userId)) {
      return _userProfilesCache[userId];
    }
    final profile = await _authService.fetchUserProfile(userId);
    if (profile != null) {
      _userProfilesCache[userId] = profile;
    }
    return profile;
  }

  Future<void> _handleClaim(ClaimRequest request, String newStatus) async {
    String? adminResponse;
    if (newStatus == AppConstants.claimStatusAccepted) {
      adminResponse = await _showAdminResponseDialog(
          'Accept Claim', 'Enter a message for the user (e.g., pickup instructions):');
      if (adminResponse == null) return; // User cancelled
    } else if (newStatus == AppConstants.claimStatusDeclined) {
      adminResponse = await _showAdminResponseDialog(
          'Decline Claim', 'Enter a reason for declining:');
      if (adminResponse == null) return; // User cancelled
    }

    CustomDialogs.showLoadingDialog(context, message: 'Updating claim...');
    try {
      await _claimService.updateClaimRequestStatus(
          request.id, newStatus, adminResponse);
      if (newStatus == AppConstants.claimStatusAccepted) {
        await _itemService.updateLostItemStatus(
            request.itemId, AppConstants.itemStatusClaimed);
      }
      if (mounted) {
        CustomDialogs.hideLoadingDialog(context);
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Success',
          message: 'Claim request updated successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        CustomDialogs.hideLoadingDialog(context);
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Error',
          message: 'Failed to update claim: $e',
        );
      }
    }
  }

  Future<String?> _showAdminResponseDialog(String title, String hintText) async {
    TextEditingController responseController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: responseController,
            decoration: InputDecoration(hintText: hintText),
            maxLines: 3,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Cancel
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(responseController.text.trim());
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Claim Requests'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ClaimRequest>>(
        stream: _claimService.getClaimRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No claim requests found.'));
          }

          final claims = snapshot.data!;

          return ListView.builder(
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final claim = claims[index];
              return FutureBuilder<Map<String, dynamic>>(
                future: Future.wait([
                  _getLostItem(claim.itemId),
                  _getUserProfile(claim.requesterId),
                ]).then((results) => {
                      'item': results[0] as LostItem?,
                      'requester': results[1] as UserProfile?,
                    }),
                builder: (context, AsyncSnapshot<Map<String, dynamic>> dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (dataSnapshot.hasError) {
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error loading details: ${dataSnapshot.error}'),
                      ),
                    );
                  }

                  final LostItem? item = dataSnapshot.data?['item'];
                  final UserProfile? requester = dataSnapshot.data?['requester'];

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Claim for: ${item?.title ?? 'Unknown Item'}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Requested by: ${requester?.email ?? 'Unknown User'}'),
                          Text('Message: ${claim.requesterMessage}'),
                          Text('Status: ${claim.status.toUpperCase()}'),
                          Text('Requested On: ${DateFormat('MMM dd, yyyy - hh:mm a').format(claim.createdAt)}'),
                          if (claim.adminResponse != null && claim.adminResponse!.isNotEmpty)
                            Text('Admin Response: ${claim.adminResponse}'),
                          const SizedBox(height: 10),
                          if (claim.status == AppConstants.claimStatusPending)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _handleClaim(claim, AppConstants.claimStatusAccepted),
                                  icon: const Icon(Icons.check),
                                  label: const Text('Accept'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () => _handleClaim(claim, AppConstants.claimStatusDeclined),
                                  icon: const Icon(Icons.close),
                                  label: const Text('Decline'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                ),
                              ],
                            )
                          else
                            Align(
                              alignment: Alignment.centerRight,
                              child: Chip(
                                label: Text(claim.status.toUpperCase()),
                                backgroundColor: claim.status == AppConstants.claimStatusAccepted
                                    ? Colors.green.shade100
                                    : Colors.red.shade100,
                                labelStyle: TextStyle(
                                  color: claim.status == AppConstants.claimStatusAccepted
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
