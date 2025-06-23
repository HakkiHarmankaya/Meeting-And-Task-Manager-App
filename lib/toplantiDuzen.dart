import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'toplantiPlan.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



class Toplanti {
  String? id; // 🔴 Firestore document ID
  String adi;
  String durumu;
  String aciklama;
  DateTime tarih;
  TimeOfDay saat;

  Toplanti({
    this.id,
    required this.adi,
    required this.durumu,
    required this.aciklama,
    required this.tarih,
    required this.saat,
  });

  Map<String, dynamic> toMap() {
    return {
      'adi': adi,
      'durumu': durumu,
      'aciklama': aciklama,
      'tarih': tarih.toIso8601String(),
      'saat': '${saat.hour}:${saat.minute.toString().padLeft(2, '0')}',
    };
  }

  factory Toplanti.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final saatParcala = (data['saat'] as String).split(":");
    return Toplanti(
      id: doc.id,
      adi: data['adi'],
      durumu: data['durumu'],
      aciklama: data['aciklama'],
      tarih: DateTime.parse(data['tarih']),
      saat: TimeOfDay(
        hour: int.parse(saatParcala[0]),
        minute: int.parse(saatParcala[1]),
      ),
    );
  }
}


class ToplantiDuzen extends StatefulWidget {
  final Function(String)? onBildirim;
  const ToplantiDuzen({Key? key, this.onBildirim}) : super(key: key);

  @override
  _ToplantiDuzenState createState() => _ToplantiDuzenState();
}

class _ToplantiDuzenState extends State<ToplantiDuzen> {
  final String toplantilarKey = "toplanti_listesi";
  List<Toplanti> toplantilar = [];

  @override
  void initState() {
    super.initState();
    _yukle();
  }

Future<void> _yukle() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final prefs = await SharedPreferences.getInstance();
  final eskiJsonList = prefs.getStringList("toplanti_listesi") ?? [];

  // 🔄 Eski SharedPreferences kayıtlarını Firestore'a aktar
  for (var json in eskiJsonList) {
    final map = jsonDecode(json);
    final query = await FirebaseFirestore.instance
        .collection('toplantilar')
        .where('uid', isEqualTo: user.uid)
        .where('adi', isEqualTo: map['adi'])
        .where('tarih', isEqualTo: map['tarih'])
        .get();

    if (query.docs.isEmpty) {
      await FirebaseFirestore.instance
          .collection('toplantilar')
          .add({
        ...map,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('toplantilar') // 🔥 doğru yer
        .orderBy('tarih')
        .get();


  setState(() {
    toplantilar = snapshot.docs.map((doc) => Toplanti.fromFirestore(doc)).toList();
  });
}




  Future<void> _kaydet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = toplantilar.map((t) => jsonEncode(t.toMap())).toList();
    await prefs.setStringList(toplantilarKey, jsonList);
  }

  void _yeniToplantiEkle() async {
    final Toplanti? yeniToplanti = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ToplantiPlan()),
    );

    if (yeniToplanti != null) {
      setState(() {
        toplantilar.add(yeniToplanti);
      });
      
      await _kaydet();

      await FirestoreService.toplantiEkle({
        'adi': yeniToplanti.adi,
        'durumu': yeniToplanti.durumu,
        'aciklama': yeniToplanti.aciklama,
        'tarih': yeniToplanti.tarih.toIso8601String(),
        'saat': '${yeniToplanti.saat.hour}:${yeniToplanti.saat.minute.toString().padLeft(2, '0')}',
        'uid': FirebaseAuth.instance.currentUser?.uid, // ✅ BURASI
        'createdAt': FieldValue.serverTimestamp(),
      });


      final tarihStr = "${yeniToplanti.tarih.day.toString().padLeft(2, '0')}/"
          "${yeniToplanti.tarih.month.toString().padLeft(2, '0')}/"
          "${yeniToplanti.tarih.year}";
      final saatStr = "${yeniToplanti.saat.hour.toString().padLeft(2, '0')}:"
          "${yeniToplanti.saat.minute.toString().padLeft(2, '0')}";

      widget.onBildirim?.call(
        'Toplanti "${yeniToplanti.adi}" eklendi. (${yeniToplanti.tarih.day}/${yeniToplanti.tarih.month}/${yeniToplanti.tarih.year} - ${yeniToplanti.saat.hour.toString().padLeft(2, '0')}:${yeniToplanti.saat.minute.toString().padLeft(2, '0')})'
      );

      Navigator.of(context).pop();
    }
  }
  

  void _showEditDialog(int index) {
    final toplanti = toplantilar[index];
    final adController = TextEditingController(text: toplanti.adi);
    final aciklamaController = TextEditingController(text: toplanti.aciklama);
    String secilenDurum = toplanti.durumu;
    DateTime secilenTarih = toplanti.tarih;
    TimeOfDay secilenSaat = toplanti.saat;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Toplantı Düzenle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: adController,
                  decoration: InputDecoration(labelText: 'Toplantı Adı'),
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: secilenDurum,
                  decoration: InputDecoration(labelText: 'Toplantı Durumu'),
                  items: ['Acil', 'Günlük Toplantı', 'Haftalık Toplantı', 'Aylık Toplantı']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) secilenDurum = value;
                  },
                ),
                SizedBox(height: 10),
                TextField(
                  controller: aciklamaController,
                  decoration: InputDecoration(labelText: 'Toplantı Açıklaması'),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: secilenTarih,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) {
                      setState(() => secilenTarih = picked);
                    }
                  },
                  icon: Icon(Icons.calendar_today),
                  label: Text("Tarih Seç"),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: secilenSaat,
                    );
                    if (picked != null) {
                      setState(() => secilenSaat = picked);
                    }
                  },
                  icon: Icon(Icons.access_time),
                  label: Text("Saat Seç"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Sil", style: TextStyle(color: Colors.red)),
                onPressed: () async {
                  final toplantiId = toplanti.id;

                  setState(() {
                    toplantilar.removeAt(index);
                  });

                  await _kaydet();

                  if (toplantiId != null) {
                    await FirestoreService.toplantiSil(toplantiId);
                  }

                  Navigator.of(context).pop();
                },
            ),
            TextButton(
              child: Text("İptal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Kaydet"),
              onPressed: () async {
                final guncelToplanti = Toplanti(
                  id: toplanti.id,
                  adi: adController.text,
                  durumu: secilenDurum,
                  aciklama: aciklamaController.text,
                  tarih: secilenTarih,
                  saat: secilenSaat,
                );

                setState(() {
                  toplantilar[index] = guncelToplanti;
                });

                await _kaydet();

                if (guncelToplanti.id != null) {
                  await FirestoreService.toplantiGuncelle(guncelToplanti.id!, guncelToplanti.toMap());
                }
                Navigator.of(context).pop();
              },

            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Toplantılar")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _yeniToplantiEkle,
              icon: Icon(Icons.add),
              label: Text("Toplantı Ekle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: toplantilar.isEmpty
                ? Center(child: Text("Henüz toplantı eklenmedi."))
                : ListView.builder(
                    itemCount: toplantilar.length,
                    itemBuilder: (context, index) {
                      final t = toplantilar[index];
                      return Card(
                        margin: EdgeInsets.all(12),
                        child: ListTile(
                          title: Text(t.adi),
                          subtitle: Text(
                            "${t.durumu} - ${t.tarih.day}/${t.tarih.month}/${t.tarih.year} - ${t.saat.hour.toString().padLeft(2, '0')}:${t.saat.minute.toString().padLeft(2, '0')}"
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => _showEditDialog(index),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
