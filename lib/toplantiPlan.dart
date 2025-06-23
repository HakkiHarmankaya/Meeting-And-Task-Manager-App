import 'package:flutter/material.dart';
import 'toplantiDuzen.dart'; // Toplanti sınıfı burada olmalı

class ToplantiPlan extends StatefulWidget {
  @override
  _ToplantiPlanState createState() => _ToplantiPlanState();
}

class _ToplantiPlanState extends State<ToplantiPlan> {
  final TextEditingController adController = TextEditingController();
  final TextEditingController aciklamaController = TextEditingController();

  String? secilenDurum;
  DateTime? secilenTarih;
  TimeOfDay? secilenSaat;

  void _tarihSec(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        secilenTarih = picked;
      });
    }
  }

  void _saatSec(BuildContext context) async {
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

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color kartRenk = isDark ? Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text("Toplantı Ekle"),
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
                  controller: adController,
                  decoration: InputDecoration(
                    labelText: "Toplantı Adı",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  value: secilenDurum,
                  items: ['Acil', 'Günlük Toplantı', 'Haftalık Toplantı', 'Aylık Toplantı']
                      .map((durum) => DropdownMenuItem(
                            value: durum,
                            child: Text(durum),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      secilenDurum = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Toplantı Durumu",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                TextField(
                  controller: aciklamaController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Toplantı Açıklaması",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () => _tarihSec(context),
                  icon: Icon(Icons.calendar_today),
                  label: Text(secilenTarih == null
                      ? "Tarih Seç"
                      : "${secilenTarih!.day}/${secilenTarih!.month}/${secilenTarih!.year}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: () => _saatSec(context),
                  icon: Icon(Icons.access_time),
                  label: Text(secilenSaat == null
                      ? "Saat Seç"
                      : "${secilenSaat!.hour.toString().padLeft(2, '0')}:${secilenSaat!.minute.toString().padLeft(2, '0')}"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.grey.shade100,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (adController.text.isNotEmpty &&
                        secilenDurum != null &&
                        aciklamaController.text.isNotEmpty &&
                        secilenTarih != null &&
                        secilenSaat != null) {
                      Toplanti yeniToplanti = Toplanti(
                        adi: adController.text,
                        durumu: secilenDurum!,
                        aciklama: aciklamaController.text,
                        tarih: secilenTarih!,
                        saat: secilenSaat!, // modelde destekleniyorsa
                      );
                      Navigator.pop(context, yeniToplanti);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Lütfen tüm alanları doldurun")),
                      );
                    }
                  },
                  child: Text("Toplantıyı Kaydet"),
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
