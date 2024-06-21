import 'package:app_listas/home/events/functionEvents/functionsInsideEvent/functionsforSublists/functionsReadTheSublists/readTheSublist.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SublistsPage extends StatefulWidget {
  final Map<String, dynamic> list;
  final String eventId;
  final String companyId;

  const SublistsPage({
    super.key,
    required this.companyId,
    required this.eventId,
    required this.list,
  });

  @override
  State<SublistsPage> createState() => _SublistsPageState();
}

class _SublistsPageState extends State<SublistsPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchTerm = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0;
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Sublistas de ${widget.list['listName']}',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'SFPro',
            fontSize: 18 * scaleFactor,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
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
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0 * scaleFactor),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 20 * scaleFactor,
                ),
                hintText: 'Buscar Sublista',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'SFPro',
                  fontSize: 14 * scaleFactor,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10 * scaleFactor),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 15 * scaleFactor),
              ),
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SFPro',
                fontSize: 14 * scaleFactor,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(widget.companyId)
                  .collection('myEvents')
                  .doc(widget.eventId)
                  .collection('eventLists')
                  .doc(widget.list['listName'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                var eventListData =
                    snapshot.data!.data() as Map<String, dynamic>?;

                if (eventListData == null ||
                    !eventListData.containsKey('sublists')) {
                  return Center(
                    child: Text(
                      'No hay sublistas en esta lista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  );
                }

                var sublists = eventListData['sublists'];
                if (sublists is! Map<String, dynamic>) {
                  return Center(
                    child: Text(
                      'No hay sublistas en esta lista.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14 * scaleFactor,
                        fontFamily: 'SFPro',
                      ),
                    ),
                  );
                }

                var allSublists = <String>{};
                sublists.forEach((userId, userSublists) {
                  if (userSublists is Map<String, dynamic>) {
                    allSublists.addAll(userSublists.keys);
                  }
                });

                var filteredSublists = allSublists
                    .where((sublist) =>
                        sublist.toLowerCase().contains(_searchTerm))
                    .toList()
                  ..sort();

                return ListView.builder(
                  itemCount: filteredSublists.length,
                  itemBuilder: (context, index) {
                    var sublistName = filteredSublists[index];
                    return ListTile(
                      title: Text(
                        sublistName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16 * scaleFactor,
                          fontFamily: 'SFPro',
                        ),
                      ),
                      trailing: Icon(
                        CupertinoIcons.chevron_forward,
                        color: Colors.white,
                        size: 20 * scaleFactor,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReadTheSublist(
                              list: widget.list,
                              sublistName: sublistName,
                              eventId: widget.eventId,
                              companyId: widget.companyId,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
