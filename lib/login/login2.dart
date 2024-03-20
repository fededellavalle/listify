import 'package:flutter/material.dart';

class LoginPage2 extends StatelessWidget {
  const LoginPage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [
              Colors.orange[900]!,
              Colors.orange[800]!,
              Colors.orange[400]!,
            ],
          ),
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 80,
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Iniciar Sesion",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          )),
                      Text("Iniciar Sesion",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                          )),
                    ]),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(60),
                          topRight: Radius.circular(60))),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 60,
                        ),
                        Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: Color.fromRGBO(225, 95, 27, .3),
                                blurRadius: 20,
                                offset: Offset(0, 10))
                          ]),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[200]!)),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Ingrese su email",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[200]!)),
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              Text(
                                "Olvidaste tu password?",
                                style: TextStyle(color: Colors.grey),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
