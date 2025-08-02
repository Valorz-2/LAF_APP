import 'package:flutter/material.dart';
import 'package:lost_and_found_app/models/lost_item.dart';
import 'package:lost_and_found_app/services/item_service.dart';
import 'package:lost_and_found_app/pages/user/item_detail_page.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';

class LostItemsListPage extends StatefulWidget {
  const LostItemsListPage({super.key});

  @override
  State<LostItemsListPage> createState() => _LostItemsListPageState();
}

class _LostItemsListPageState extends State<LostItemsListPage> {
  final ItemService _itemService = ItemService();
  late Future<List<LostItem>> _lostItemsFuture;

  @override
  void initState() {
    super.initState();
    _lostItemsFuture = _itemService.fetchLostItems();
  }

  Future<void> _refreshItems() async {
    setState(() {
      _lostItemsFuture = _itemService.fetchLostItems();
    });
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
            onPressed: _refreshItems,
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
            print('Error fetching lost items for list: ${snapshot.error}'); // Debug print
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

          return ListView.builder(
            itemCount: activeItems.length,
            itemBuilder: (context, index) {
              final item = activeItems[index];
              print('Displaying item: ${item.title}, Image URL: ${item.imageUrl}'); // Debug print
              return Card(
                margin: const EdgeInsets.all(8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ItemDetailPage(item: item),
                      ),
                    );
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
                                print('Image loading error for ${item.imageUrl}: $error'); // Debug print for image loading
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
          );
        },
      ),
    );
  }
}