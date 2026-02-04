import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FormIzinPage extends StatefulWidget {
  const FormIzinPage({Key? key}) : super(key: key);

  @override
  State<FormIzinPage> createState() => _FormIzinPageState();
}

class _FormIzinPageState extends State<FormIzinPage> {
  final _formKey = GlobalKey<FormState>();

  String? selectedNama;
  TimeOfDay? jamMulai;
  TimeOfDay? jamKembali;

  bool isLoading = false;

  final TextEditingController keteranganController = TextEditingController();

  /// ================== PILIH JAM ==================
  Future<void> pilihJam(bool isMulai) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        if (isMulai) {
          jamMulai = picked;
        } else {
          jamKembali = picked;
        }
      });
    }
  }

  /// ================== SUBMIT FORM ==================
  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (jamMulai == null || jamKembali == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jam mulai dan selesai wajib diisi')),
      );
      return;
    }

    int mulaiMenit = jamMulai!.hour * 60 + jamMulai!.minute;
    int selesaiMenit = jamKembali!.hour * 60 + jamKembali!.minute;

    if (selesaiMenit <= mulaiMenit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jam selesai harus lebih besar dari jam mulai'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('izins').add({
        'nama': selectedNama,
        'jam_mulai': jamMulai!.format(context),
        'jam_selesai': jamKembali!.format(context),
        'keterangan': keteranganController.text,
        'tanggal': Timestamp.now(),
      });

      // RESET FORM
      setState(() {
        selectedNama = null;
        jamMulai = null;
        jamKembali = null;
      });
      keteranganController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form izin berhasil dikirim')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengirim data: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ================== UI ==================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Form Izin')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// ===== DROPDOWN NAMA =====
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('nama_pegawais')
                          .orderBy('nama')
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(),
                      ),
                      value: selectedNama,
                      isExpanded: true,
                      items:
                          snapshot.data!.docs.map((doc) {
                            return DropdownMenuItem<String>(
                              value: doc['nama'],
                              child: Text(
                                doc['nama'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() => selectedNama = value);
                      },
                      validator:
                          (value) =>
                              value == null ? 'Nama wajib dipilih' : null,
                    );
                  },
                ),

                const SizedBox(height: 16),

                /// ===== JAM MULAI =====
                buildJamField(
                  label: 'Jam Mulai',
                  time: jamMulai,
                  onTap: () => pilihJam(true),
                ),

                const SizedBox(height: 16),

                /// ===== JAM SELESAI =====
                buildJamField(
                  label: 'Jam Selesai',
                  time: jamKembali,
                  onTap: () => pilihJam(false),
                ),

                const SizedBox(height: 16),

                /// ===== KETERANGAN =====
                TextFormField(
                  controller: keteranganController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan Izin',
                    border: OutlineInputBorder(),
                  ),
                  validator:
                      (value) =>
                          value!.isEmpty ? 'Keterangan wajib diisi' : null,
                ),

                const SizedBox(height: 24),

                /// ===== BUTTON =====
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitForm,
                    child:
                        isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Kirim',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ================== WIDGET JAM ==================
  Widget buildJamField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.access_time),
          ),
          controller: TextEditingController(
            text: time == null ? '' : time.format(context),
          ),
        ),
      ),
    );
  }
}
