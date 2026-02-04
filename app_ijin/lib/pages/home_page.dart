import 'package:flutter/material.dart';
import 'admin_gate.dart';
import 'form_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu Utama')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Text('Admin'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminGatePage()),
                );
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Form Izin'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => FormIzinPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
