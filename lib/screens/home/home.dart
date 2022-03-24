import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Text("Olá"),
            Text("Estou na home, estou na última versão"),
          ],
        ),
      ),
    );
  }
}
