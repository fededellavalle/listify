import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../styles/button.dart';
import 'functionsGestionPersonal/crearCategoriaPersonal.dart';
import 'functionsGestionPersonal/insideCategory.dart';

class GestionPersonal extends StatefulWidget {
  final Map<String, dynamic> companyData;

  const GestionPersonal({
    Key? key,
    required this.companyData,
  }) : super(key: key);

  @override
  State<GestionPersonal> createState() => _GestionPersonalState();
}

class _GestionPersonalState extends State<GestionPersonal> {
  Stream<List<String>>? _categoriesStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream = loadPersonalCategories();
  }

  Stream<List<String>> loadPersonalCategories() {
    CollectionReference categoryCollection = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyData['companyId'])
        .collection('personalCategories');

    return categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('personalCategories isEmpty: ${_categoriesStream?.isEmpty}');
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.95),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Gestión de Personal",
          style: GoogleFonts.roboto(
            color: Colors.white,
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            crearCategoriaPersonal(
                          companyData: widget.companyData,
                        ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.linearToEaseOut,
                                reverseCurve: Curves.easeIn,
                              ),
                            ),
                            child: child,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 500),
                      ),
                    );
                  },
                  icon: Icon(
                    UniconsLine.plus_circle,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: _categoriesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error al cargar las categorías');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          List<String> personalCategories = snapshot.data ?? [];

          if (personalCategories.isEmpty) {
            return Center(
              child: Text(
                'No tienes categorías creadas, ¿crea una aquí?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            );
          }

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade700.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            height: personalCategories.length * 50.0,
            child: ListView.builder(
              itemCount: personalCategories.length,
              itemBuilder: (context, index) {
                String categoryName = personalCategories[index];
                print(categoryName);
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('companies')
                      .doc(widget.companyData['companyId'])
                      .collection('personalCategories')
                      .doc(categoryName)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error al obtener la cantidad de personas');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    var categoryData = snapshot.data?.data() as Map<String,
                        dynamic>?; // Especificar el tipo de categoryData

                    if (categoryData != null) {
                      int personCount = categoryData['persons']?.length ?? 0;

                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InsideCategory(
                                categoryName: categoryName,
                                companyData: widget.companyData,
                                emails: categoryData['persons']
                                        ?.cast<String>() ??
                                    [], // Acceder a 'persons' como un Map<String, dynamic>
                              ),
                            ),
                          );
                        },
                        style: buttonCompany,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              '$categoryName',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '$personCount',
                              style: GoogleFonts.roboto(
                                color: Colors.grey.shade600,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(
                              UniconsLine.angle_right_b,
                              size: 20,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Text('Error: Datos de categoría no disponibles');
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
