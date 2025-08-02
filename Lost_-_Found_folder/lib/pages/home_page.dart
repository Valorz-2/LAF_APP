import 'package:flutter/material.dart';
import 'package:lost_and_found_app/auth/auth_service.dart';
import 'package:lost_and_found_app/models/user_profile.dart';
import 'package:lost_and_found_app/pages/admin/add_item_page.dart';
import 'package:lost_and_found_app/pages/admin/manage_claims_page.dart';
import 'package:lost_and_found_app/pages/user/lost_items_list_page.dart';
import 'package:lost_and_found_app/pages/user/my_claims_page.dart';
import 'package:lost_and_found_app/utils/app_constants.dart';
import 'package:lost_and_found_app/utils/custom_dialogs.dart';

class HomePage extends StatefulWidget {
  final UserProfile userProfile;
  const HomePage({super.key, required this.userProfile});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  Future<void> _signOut() async {
    final bool? confirm = await CustomDialogs.showConfirmationDialog(
      context: context,
      title: 'Confirm Logout',
      message: 'Are you sure you want to log out?',
    );
    if (confirm == true) {
      try {
        await _authService.signOut();
        if (mounted) {
          CustomDialogs.showAlertDialog(
            context: context,
            title: 'Logged Out',
            message: 'You have been successfully logged out.',
          );
          // Navigation handled by AuthChecker
        }
      } catch (e) {
        if (mounted) {
          CustomDialogs.showAlertDialog(
            context: context,
            title: 'Logout Error',
            message: 'Failed to log out: $e',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = widget.userProfile.role == AppConstants.adminRole;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'Admin Dashboard' : 'Lost and Found'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Logout',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF880022), // Maroon color
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Color(0xFF880022)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.userProfile.email,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Role: ${widget.userProfile.role.toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (!isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.list_alt),
                title: const Text('View Lost Items'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LostItemsListPage()), // Removed const
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('My Claim Requests'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyClaimsPage()),
                  );
                },
              ),
            ],
            if (isAdmin) ...[
              ListTile(
                leading: const Icon(Icons.add_photo_alternate),
                title: const Text('Add Lost Item'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddItemPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.request_page),
                title: const Text('Manage Claim Requests'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageClaimsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.format_list_bulleted),
                title: const Text('View All Items'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LostItemsListPage()), // Removed const
                  );
                },
              ),
            ],
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _signOut,
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hello, ${widget.userProfile.email}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'You are logged in as a ${widget.userProfile.role.toUpperCase()}.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (!isAdmin)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LostItemsListPage()), // Removed const
                      );
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Browse Lost Items'),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyClaimsPage()),
                      );
                    },
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('View My Claims'),
                  ),
                ],
              ),
            if (isAdmin)
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddItemPage()),
                      );
                    },
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Add New Lost Item'),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageClaimsPage()),
                      );
                    },
                    icon: const Icon(Icons.assignment),
                    label: const Text('Manage Claim Requests'),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LostItemsListPage()), // Removed const
                      );
                    },
                    icon: const Icon(Icons.list_alt),
                    label: const Text('View All Items'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}