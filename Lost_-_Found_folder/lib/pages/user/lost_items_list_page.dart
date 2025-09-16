import 'package:flutter/material.dart';
import 'package:lost_and_found_app/models/lost_item.dart';
import 'package:lost_and_found_app/pages/admin/add_item_page.dart'; // Make sure this import is correct
import 'package:lost_and_found_app/services/item_service.dart';
import 'package:lost_and_found_app/pages/user/item_detail_page.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';
// TODO: You may need to import your AuthService to check the user's role
// import 'package:lost_and_found_app/auth/auth_service.dart';

class LostItemsListPage extends StatefulWidget {
  const LostItemsListPage({super.key});

  @override
  State<LostItemsListPage> createState() => _LostItemsListPageState();
}

class _LostItemsListPageState extends State<LostItemsListPage> {
  final ItemService _itemService = ItemService();
  late Future<List<LostItem>> _lostItemsFuture;
  // final AuthService _authService = AuthService(); // Uncomment to use for role checking
  bool _isAdmin = true; // Placeholder for admin check

  @override
  void initState() {
    super.initState();
    // In a real app, you would fetch the user's role here
    // _checkUserRole();
    _refreshItems(); // Initial data fetch
  }

  // Example of how you might check the user's role
  /*
  void _checkUserRole() async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      final profile = await _authService.fetchUserProfile(user.id);
      if (mounted) {
        setState(() {
          _isAdmin = profile?.role == AppConstants.adminRole;
        });
      }
    }
  }
  */

  // Renamed to be more descriptive, this is our core refresh logic
  void _refreshItems() {
    setState(() {
      _lostItemsFuture = _itemService.fetchLostItems();
    });
  }

  // ** THE SOLUTION IS HERE **
  // This method navigates to the AddItemPage and waits for it to close.
  void _navigateAndRefresh() async {
    // The 'await' keyword pauses this function until AddItemPage is closed.
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddItemPage()),
    );
    
    // When we return from AddItemPage, this code executes, refreshing the list.
    _refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Items'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshItems, // Manual refresh still available
            tooltip: 'Refresh Items',
          ),
        ],
      ),
      body: FutureBuilder<List<LostItem>>(
        future: _lostItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No lost items found.'));
          }

          final activeItems = snapshot.data!
              .where((item) => item.status == AppConstants.itemStatusActive)
              .toList();

          if (activeItems.isEmpty) {
            return const Center(child: Text('No active lost items found.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshItems(), // Added pull-to-refresh
            child: ListView.builder(
              itemCount: activeItems.length,
              itemBuilder: (context, index) {
                final item = activeItems[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: InkWell(
                    onTap: () async {
                      // Navigate to detail page and refresh if an item was claimed
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ItemDetailPage(item: item),
                        ),
                      );
                      // If the detail page returns 'true', it means an action was taken
                      if (result == true) {
                        _refreshItems();
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.imageUrl!,
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              height: 150,
                              color: Colors.grey[300],
                              child: const Center(child: Text('No Image Available')),
                            ),
                          const SizedBox(height: 10),
                          Text(
                            item.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text('Found at: ${item.locationFound}'),
                          Text('Posted on: ${item.createdAt.toLocal().toString().split(' ')[0]}'),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Chip(
                              label: Text(item.status.toUpperCase()),
                              backgroundColor: item.status == AppConstants.itemStatusActive
                                  ? Colors.blue.shade100
                                  : Colors.green.shade100,
                              labelStyle: TextStyle(
                                color: item.status == AppConstants.itemStatusActive
                                    ? Colors.blue.shade800
                                    : Colors.green.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      // This button will navigate and then trigger a refresh on return
      floatingActionButton: _isAdmin
          ? FloatingActionButton(
              onPressed: _navigateAndRefresh,
              tooltip: 'Add New Item',
              child: const Icon(Icons.add_a_photo),
            )
          : null,
    );
  }
}