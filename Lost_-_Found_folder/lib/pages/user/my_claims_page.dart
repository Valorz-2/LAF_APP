import 'package:flutter/material.dart';
import 'package:lost_and_found_app/auth/auth_service.dart';
import 'package:lost_and_found_app/models/claim_request.dart';
import 'package:lost_and_found_app/models/lost_item.dart';
import 'package:lost_and_found_app/services/claim_service.dart';
import 'package:lost_and_found_app/services/item_service.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';
import 'package:intl/intl.dart'; // For date formatting

class MyClaimsPage extends StatefulWidget {
  const MyClaimsPage({super.key});

  @override
  State<MyClaimsPage> createState() => _MyClaimsPageState();
}

class _MyClaimsPageState extends State<MyClaimsPage> {
  final ClaimService _claimService = ClaimService();
  final ItemService _itemService = ItemService();
  final AuthService _authService = AuthService();

  String? _currentUserId;
  final Map<String, LostItem> _lostItemsCache = {};

  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.getCurrentUserId();
    if (_currentUserId == null) {
      // Handle case where user ID is not available (e.g., not logged in)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CustomDialogs.showAlertDialog(
          context: context,
          title: 'Error',
          message: 'You must be logged in to view your claims.',
          onButtonPressed: () {
            Navigator.of(context).pop(); // Go back
          },
        );
      });
    }
  }

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

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Claim Requests')),
        body: const Center(child: Text('Please log in to view your claims.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Claim Requests'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ClaimRequest>>(
        stream: _claimService.getUserClaimRequestsStream(_currentUserId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have not submitted any claim requests yet.'));
          }

          final claims = snapshot.data!;

          return ListView.builder(
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final claim = claims[index];
              return FutureBuilder<LostItem?>(
                future: _getLostItem(claim.itemId),
                builder: (context, itemSnapshot) {
                  if (itemSnapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (itemSnapshot.hasError) {
                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error loading item details: ${itemSnapshot.error}'),
                      ),
                    );
                  }

                  final LostItem? item = itemSnapshot.data;

                  Color statusColor;
                  String statusText;
                  switch (claim.status) {
                    case AppConstants.claimStatusAccepted:
                      statusColor = Colors.green;
                      statusText = 'ACCEPTED';
                      break;
                    case AppConstants.claimStatusDeclined:
                      statusColor = Colors.red;
                      statusText = 'DECLINED';
                      break;
                    case AppConstants.claimStatusPending:
                    default:
                      statusColor = Colors.orange;
                      statusText = 'PENDING';
                      break;
                  }

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
                          Text('Your Message: ${claim.requesterMessage}'),
                          Text('Requested On: ${DateFormat('MMM dd, yyyy - hh:mm a').format(claim.createdAt)}'),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Chip(
                              label: Text(
                                statusText,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: statusColor,
                            ),
                          ),
                          if (claim.adminResponse != null && claim.adminResponse!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Admin Response: ${claim.adminResponse}',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey[700],
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