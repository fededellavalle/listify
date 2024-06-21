import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class _GestionPersonalState extends State<GestionPersonal>
    with SingleTickerProviderStateMixin {
  Stream<List<String>>? _categoriesStream;
  late AnimationController _animationController;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _categoriesStream = loadPersonalCategories();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0.1, -0.2),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Stream<List<String>> loadPersonalCategories() {
    CollectionReference categoryCollection = FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyData['username'])
        .collection('personalCategories');

    return categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.id).toList();
    });
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
          "Gestión de Personal",
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
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10 * scaleFactor),
            child: IconButton(
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
                CupertinoIcons.add_circled,
                size: 24 * scaleFactor,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<String>>(
        stream: _categoriesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar las categorías',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SFPro',
                  fontSize: 18 * scaleFactor,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<String> personalCategories = snapshot.data ?? [];

          if (personalCategories.isEmpty) {
            return Stack(
              children: [
                Center(
                  child: Text(
                    'Aún no has creado ninguna categoría.\n¡Agrega una ahora!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'SFPro',
                      fontSize: 18 * scaleFactor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  top: 1 * scaleFactor,
                  right: 35 * scaleFactor,
                  child: SlideTransition(
                    position: _animation,
                    child: Icon(
                      CupertinoIcons.arrow_up_right,
                      color: Colors.white,
                      size: 40 * scaleFactor,
                    ),
                  ),
                ),
              ],
            );
          }

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10 * scaleFactor),
            decoration: BoxDecoration(
              color: Colors.grey.shade700.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10 * scaleFactor),
            ),
            height: personalCategories.length * 50.0 * scaleFactor,
            child: ListView.builder(
              itemCount: personalCategories.length,
              itemBuilder: (context, index) {
                String categoryName = personalCategories[index];
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('companies')
                      .doc(widget.companyData['username'])
                      .collection('personalCategories')
                      .doc(categoryName)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al obtener la cantidad de personas',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 18 * scaleFactor,
                          ),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    var categoryData =
                        snapshot.data?.data() as Map<String, dynamic>?;

                    if (categoryData != null) {
                      int memberCount = categoryData['members']?.length ?? 0;

                      return ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      InsideCategory(
                                categoryName: categoryName,
                                companyData: widget.companyData,
                                emails:
                                    categoryData['members']?.cast<String>() ??
                                        [],
                              ),
                              transitionsBuilder: (context, animation,
                                  secondaryAnimation, child) {
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
                        style: buttonCompany,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              categoryName,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'SFPro',
                                fontSize: 18 * scaleFactor,
                              ),
                            ),
                            Spacer(),
                            Text(
                              '$memberCount',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: 'SFPro',
                                fontSize: 18 * scaleFactor,
                              ),
                            ),
                            SizedBox(width: 3 * scaleFactor),
                            Icon(
                              UniconsLine.angle_right_b,
                              size: 20 * scaleFactor,
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Text(
                          'Error: Datos de categoría no disponibles',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'SFPro',
                            fontSize: 18 * scaleFactor,
                          ),
                        ),
                      );
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
