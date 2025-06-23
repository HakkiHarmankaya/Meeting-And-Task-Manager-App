import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gorevEkle.dart';
import 'firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Gorev {
  String? id; // 🔴 Firestore document ID (güncelleme/silme için gerekli)
  String kisiAdi;
  String gorevAdi;
  String gorevAmaci;
  DateTime tarih;
  TimeOfDay saat;

  Gorev({
    this.id,
    required this.kisiAdi,
    required this.gorevAdi,
    required this.gorevAmaci,
    required this.tarih,
    required this.saat,
  });

  Map<String, dynamic> toMap() {
    return {
      'kisiAdi': kisiAdi,
      'gorevAdi': gorevAdi,
      'gorevAmaci': gorevAmaci,
      'tarih': tarih.toIso8601String(),
      'saat': '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}',
    };
  }

  // Firestore'dan direkt DocumentSnapshot ile oluştur
  factory Gorev.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final saatSplit = (data['saat'] as String).split(":");

    return Gorev(
      id: doc.id,
      kisiAdi: data['kisiAdi'],
      gorevAdi: data['gorevAdi'],
      gorevAmaci: data['gorevAmaci'],
      tarih: DateTime.parse(data['tarih']),
      saat: TimeOfDay(
        hour: int.parse(saatSplit[0]),
        minute: int.parse(saatSplit[1]),
      ),
    );
  }

  // SharedPreferences gibi map'ten okuma için
  factory Gorev.fromMap(Map<String, dynamic> map) {
    final saatSplit = (map['saat'] as String).split(":");

    return Gorev(
      kisiAdi: map['kisiAdi'],
      gorevAdi: map['gorevAdi'],
      gorevAmaci: map['gorevAmaci'],
      tarih: DateTime.parse(map['tarih']),
      saat: TimeOfDay(
        hour: int.parse(saatSplit[0]),
        minute: int.parse(saatSplit[1]),
      ),
    );
  }
}


class GorevDuzen extends StatefulWidget {
  final Function(String)? onBildirim;

  const GorevDuzen({Key? key, this.onBildirim}) : super(key: key);

  @override
  _GorevDuzenState createState() => _GorevDuzenState();
}

class _GorevDuzenState extends State<GorevDuzen> {
  List<Gorev> gorevler = [];
  final String gorevKey = "gorev_listesi";

  @override
  void initState() {
    super.initState();
    _yukle();
  }

Future<void> _yukle() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('gorevler')
      .orderBy('tarih')
      .get();

  setState(() {
    gorevler = snapshot.docs.map((doc) => Gorev.fromFirestore(doc)).toList();
  });
}



  Future<void> _kaydet() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonList = gorevler.map((g) => jsonEncode(g.toMap())).toList();
    await prefs.setStringList(gorevKey, jsonList);
  }

void _yeniGorevEkle() async {
  final Gorev? yeniGorev = await Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => GorevEkle()),
  );

  if (yeniGorev != null) {
    final docId = await FirestoreService.gorevEkle({
      'kisiAdi': yeniGorev.kisiAdi,
      'gorevAdi': yeniGorev.gorevAdi,
      'gorevAmaci': yeniGorev.gorevAmaci,
      'tarih': yeniGorev.tarih.toIso8601String(),
      'saat': '${yeniGorev.saat.hour}:${yeniGorev.saat.minute.toString().padLeft(2, '0')}',
      'uid': FirebaseAuth.instance.currentUser?.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (docId != null) {
      final gorevWithId = Gorev(
        id: docId,
        kisiAdi: yeniGorev.kisiAdi,
        gorevAdi: yeniGorev.gorevAdi,
        gorevAmaci: yeniGorev.gorevAmaci,
        tarih: yeniGorev.tarih,
        saat: yeniGorev.saat,
      );

      setState(() {
        gorevler.add(gorevWithId);
      });

      await _kaydet();

      final tarihStr = "${yeniGorev.tarih.day.toString().padLeft(2, '0')}/"
          "${yeniGorev.tarih.month.toString().padLeft(2, '0')}/"
          "${yeniGorev.tarih.year}";
      final saatStr = "${yeniGorev.saat.hour.toString().padLeft(2, '0')}:"
          "${yeniGorev.saat.minute.toString().padLeft(2, '0')}";

      widget.onBildirim?.call(
        'Görev "${yeniGorev.gorevAdi}" eklendi. ($tarihStr - $saatStr)',
      );
    }
  }
}


  void _showEditDialog(int index) {
    final gorev = gorevler[index];
    final kisiAdController = TextEditingController(text: gorev.kisiAdi);
    final gorevAdController = TextEditingController(text: gorev.gorevAdi);
    final gorevAmacController = TextEditingController(text: gorev.gorevAmaci);
    DateTime secilenTarih = gorev.tarih;
    TimeOfDay secilenSaat = gorev.saat;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Görev Düzenle"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: kisiAdController,
                  decoration: InputDecoration(labelText: "Kişi Adı"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: gorevAdController,
                  decoration: InputDecoration(labelText: "Görev Adı"),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: gorevAmacController,
                  decoration: InputDecoration(labelText: "Görev Amacı"),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
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
                    final TimeOfDay? picked = await showTimePicker(
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
                final gorevId = gorev.id;

                setState(() {
                  gorevler.removeAt(index);
                });

                await _kaydet();

                if (gorevId != null) {
                  await FirestoreService.gorevSil(gorevId);
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
                final guncelGorev = Gorev(
                  id: gorev.id,
                  kisiAdi: kisiAdController.text,
                  gorevAdi: gorevAdController.text,
                  gorevAmaci: gorevAmacController.text,
                  tarih: secilenTarih,
                  saat: secilenSaat,
                );

                setState(() {
                  gorevler[index] = guncelGorev;
                });

                await _kaydet();

                if (guncelGorev.id != null) {
                  await FirestoreService.gorevGuncelle(guncelGorev.id!, guncelGorev.toMap());
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
      appBar: AppBar(title: Text("Görevler")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _yeniGorevEkle,
              icon: Icon(Icons.add),
              label: Text("Görev Ekle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: gorevler.isEmpty
                ? Center(child: Text("Henüz görev eklenmedi."))
                : ListView.builder(
                    itemCount: gorevler.length,
                    itemBuilder: (context, index) {
                      final g = gorevler[index];
                      return Card(
                        margin: EdgeInsets.all(12),
                        child: ListTile(
                          title: Text(g.gorevAdi),
                          subtitle: Text("${g.kisiAdi} - ${g.tarih.day}/${g.tarih.month}/${g.tarih.year} - ${g.saat.hour.toString().padLeft(2, '0')}:${g.saat.minute.toString().padLeft(2, '0')}"),
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
