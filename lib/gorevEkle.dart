import 'package:flutter/material.dart';
import 'gorevDuzen.dart'; // Gorev sınıfı burada tanımlı

class GorevEkle extends StatefulWidget {
  @override
  _GorevEkleState createState() => _GorevEkleState();
}

class _GorevEkleState extends State<GorevEkle> {
  final TextEditingController kisiAdController = TextEditingController();
  final TextEditingController gorevAdController = TextEditingController();
  final TextEditingController gorevAmacController = TextEditingController();
  DateTime secilenTarih = DateTime.now();
  TimeOfDay? secilenSaat;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: secilenTarih,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        secilenTarih = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        secilenSaat = picked;
      });
    }
  }

  void _kaydet() {
    if (kisiAdController.text.isNotEmpty &&
        gorevAdController.text.isNotEmpty &&
        gorevAmacController.text.isNotEmpty &&
        secilenSaat != null) {
      Gorev yeniGorev = Gorev(
        kisiAdi: kisiAdController.text,
        gorevAdi: gorevAdController.text,
        gorevAmaci: gorevAmacController.text,
        tarih: secilenTarih,
        saat: secilenSaat!,
      );

      Navigator.pop(context, yeniGorev);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lütfen tüm alanları doldurun")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color kartRenk = isDark ? Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text("Görev Ekle"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: kartRenk,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: kisiAdController,
                  decoration: InputDecoration(
                    labelText: "Kişi Adı",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: gorevAdController,
                  decoration: InputDecoration(
                    labelText: "Görev Adı",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: gorevAmacController,
                  decoration: InputDecoration(
                    labelText: "Görev Amacı",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text("Tarih Seç: ${secilenTarih.day}/${secilenTarih.month}/${secilenTarih.year}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _selectTime(context),
                  icon: Icon(Icons.access_time),
                  label: Text(
                    secilenSaat == null
                        ? "Saat Seç"
                        : "Saat: ${secilenSaat!.hour.toString().padLeft(2, '0')}:${secilenSaat!.minute.toString().padLeft(2, '0')}",
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _kaydet,
                  child: Text("Kaydet"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
