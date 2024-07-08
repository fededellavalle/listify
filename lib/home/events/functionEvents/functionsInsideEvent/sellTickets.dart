import 'package:app_listas/styles/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int _ticketCount = 0;
  double _ticketPrice = 0.0;
  bool isLoading = false;

  void _incrementTicket() {
    setState(() {
      if (_ticketCount < 100) {
        _ticketCount++;
      }
    });
  }

  void _decrementTicket() {
    setState(() {
      if (_ticketCount > 0) {
        _ticketCount--;
      }
    });
  }

  void _confirmSale() {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text("Confirmar Venta"),
          content:
              Text("¿Está seguro de que desea vender $_ticketCount entradas?"),
          actions: [
            CupertinoDialogAction(
              child: Text("Cancelar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text("Confirmar"),
              onPressed: () {
                Navigator.of(context).pop();
                _sellTickets();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _sellTickets() async {
    setState(() {
      isLoading = true;
    });

    try {
      DocumentReference eventRef = FirebaseFirestore.instance
          .collection('companies')
          .doc(widget.companyId)
          .collection('myEvents')
          .doc(widget.eventId);

      await eventRef.update({
        'ticketsSold': FieldValue.increment(_ticketCount),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Entradas vendidas exitosamente.'),
        ),
      );

      setState(() {
        _ticketCount = 0; // Reset ticket count after sale
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al vender entradas: $e'),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

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
          onPressed: isLoading
              ? null
              : () {
                  Navigator.of(context).pop();
                },
        ),
      ),
      body: SingleChildScrollView(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('companies')
              .doc(widget.companyId)
              .collection('myEvents')
              .doc(widget.eventId)
              .snapshots(),
          builder: (context, eventSnapshot) {
            if (!eventSnapshot.hasData) {
              return Center(
                child: CupertinoActivityIndicator(),
              );
            }

            var eventData = eventSnapshot.data!.data() as Map<String, dynamic>?;
            if (eventData == null || eventData['eventState'] != 'Live') {
              return Center(
                child: Text(
                  'El evento ya ha finalizado.',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SFPro',
                    fontSize: 16 * scaleFactor,
                  ),
                ),
              );
            }

            _ticketPrice = eventData['eventTicketValue'] ?? 0.0;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Precio de cada entrada: \$${_ticketPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.minus_circle,
                          color: Colors.white,
                        ),
                        onPressed: _decrementTicket,
                      ),
                      SizedBox(width: 20),
                      Text(
                        '$_ticketCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'SFPro',
                          fontSize: 24 * scaleFactor,
                        ),
                      ),
                      SizedBox(width: 20),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.plus_circle,
                          color: Colors.white,
                        ),
                        onPressed: _incrementTicket,
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Total: \$${(_ticketCount * _ticketPrice).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 16 * scaleFactor,
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      onPressed:
                          _ticketCount > 0 && !isLoading ? _confirmSale : null,
                      child: isLoading
                          ? CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : Text(
                              'Vender Entradas',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SFPro',
                                fontSize: 16 * scaleFactor,
                              ),
                            ),
                      color: skyBluePrimary,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
