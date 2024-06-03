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
  @override
  void initState() {
    super.initState();
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
      body: StreamBuilder<DocumentSnapshot>(
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

          var eventListData = snapshot.data!.data() as Map<String, dynamic>?;

          if (eventListData == null || !eventListData.containsKey('sublists')) {
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

          var sortedSublists = allSublists.toList()..sort();

          return ListView.builder(
            itemCount: sortedSublists.length,
            itemBuilder: (context, index) {
              var sublistName = sortedSublists[index];
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
    );
  }
}
