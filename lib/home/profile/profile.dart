import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'functionsProfile/editProfile.dart'; // Import the EditProfilePage

class ProfilePage extends StatefulWidget {
  final String? uid;

  ProfilePage({this.uid});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImageUrl;
  String _name = '';
  String _lastname = '';
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();

    if (userSnapshot.exists) {
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _profileImageUrl = userData['imageUrl'];
        _name = userData['name'] ?? '';
        _lastname = userData['lastname'] ?? '';
        _email = FirebaseAuth.instance.currentUser?.email ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    final updatedProfileImageUrl = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(uid: widget.uid),
      ),
    );

    if (updatedProfileImageUrl != null) {
      setState(() {
        _profileImageUrl = updatedProfileImageUrl;
      });
      // Pass the updated image URL back to the previous screen
      Navigator.pop(context, updatedProfileImageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : AssetImage('assets/apple.png') as ImageProvider,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '$_name $_lastname',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _email,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _navigateToEditProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow, // background color
                      foregroundColor: Colors.black, // text color
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text('Edit Profile'),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey),
                  _buildListTile(Icons.settings, 'Settings', context),
                  _buildListTile(Icons.credit_card, 'Billing Details', context),
                  _buildListTile(Icons.group, 'User Management', context),
                  _buildListTile(Icons.info, 'Information', context),
                  _buildListTile(Icons.logout, 'Logout', context),
                ],
              ),
            ),
    );
  }

  Widget _buildListTile(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.yellow),
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        // Add navigation or action here
      },
    );
  }
}
