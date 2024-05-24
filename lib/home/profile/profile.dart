import 'package:app_listas/styles/color.dart';
import 'package:flutter/cupertino.dart';
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
        title: Text(
          'Profile',
          style: TextStyle(fontFamily: 'SFPro', color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.left_chevron,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                      fontFamily: 'SFPro',
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _email,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontFamily: 'SFPro',
                    ),
                  ),
                  SizedBox(height: 16),
                  CupertinoButton(
                    onPressed: _navigateToEditProfile,
                    color: skyBluePrimary,
                    child: Text(
                      'Editar Perfil',
                      style:
                          TextStyle(fontFamily: 'SFPro', color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey),
                  _buildListTile(CupertinoIcons.settings, 'Settings', context),
                  _buildListTile(
                      CupertinoIcons.creditcard, 'Billing Details', context),
                  _buildListTile(
                      CupertinoIcons.group, 'User Management', context),
                  _buildListTile(
                      CupertinoIcons.info_circle_fill, 'Information', context),
                  _buildListTile(CupertinoIcons.square_arrow_right,
                      'Cerrar Sesion', context),
                ],
              ),
            ),
    );
  }

  Widget _buildListTile(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: skyBluePrimary),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'SFPro',
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        // Add navigation or action here
      },
    );
  }
}
