import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_page.dart';

class AdminGatePage extends StatefulWidget {
  const AdminGatePage({Key? key}) : super(key: key);

  @override
  State<AdminGatePage> createState() => _AdminGatePageState();
}

class _AdminGatePageState extends State<AdminGatePage> {
  final TextEditingController kodeController = TextEditingController();
  String? errorText;

  late String kodeBenar;

  @override
  void initState() {
    super.initState();
    kodeBenar = generateAdminCode();
  }

  String generateAdminCode() {
    final now = DateTime.now();
    return DateFormat('yyyyMMdd').format(now);
  }

  void cekKode() {
    final input = kodeController.text.trim();

    if (input == kodeBenar) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
    } else {
      setState(() {
        errorText = 'Kode salah';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akses Admin')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 64),
            const SizedBox(height: 16),

            /// ===== TAMPILKAN KODE =====
            Text('Kode', style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 24),

            TextField(
              controller: kodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Kode',
                border: const OutlineInputBorder(),
                errorText: errorText,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: cekKode,
                child: const Text('Masuk Admin'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
