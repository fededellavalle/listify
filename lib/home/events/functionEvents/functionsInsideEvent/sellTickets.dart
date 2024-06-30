import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SellTickets extends StatefulWidget {
  final String eventId;
  final String companyId;

  const SellTickets({
    super.key,
    required this.eventId,
    required this.companyId,
  });

  @override
  State<SellTickets> createState() => _SellTicketsState();
}

class _SellTicketsState extends State<SellTickets> {
  @override
  Widget build(BuildContext context) {
    double baseWidth = 375.0; // Base design width
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / baseWidth;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Entradas Generales',
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
    );
  }
}
