import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // 🔐 UID her seferinde dinamik alınmalı
  static String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  // ✅ Toplantı ekle
  static Future<void> toplantiEkle(Map<String, dynamic> data) async {
    if (_userId == null) return;
    await _db
        .collection('users')
        .doc(_userId)
        .collection('toplantilar')
        .add(data);
  }
  static Future<void> toplantiSil(String docId) async {
  if (_userId == null) return;
  await _db
      .collection('users')
      .doc(_userId)
      .collection('toplantilar')
      .doc(docId)
      .delete();
}

static Future<void> toplantiGuncelle(String docId, Map<String, dynamic> data) async {
  if (_userId == null) return;
  await _db
      .collection('users')
      .doc(_userId)
      .collection('toplantilar')
      .doc(docId)
      .update(data);
}


  // ✅ Görev ekle
static Future<String?> gorevEkle(Map<String, dynamic> data) async {
  if (_userId == null) return null;
  final docRef = await _db
      .collection('users')
      .doc(_userId)
      .collection('gorevler')
      .add(data);
  return docRef.id; // 📌 DÖNEN ID
}


  // ✅ Görev güncelle
  static Future<void> gorevGuncelle(String docId, Map<String, dynamic> data) async {
    if (_userId == null) return;
    await _db
        .collection('users')
        .doc(_userId)
        .collection('gorevler')
        .doc(docId)
        .update(data);
  }

  // ✅ Görev sil
  static Future<void> gorevSil(String docId) async {
    if (_userId == null) return;
    await _db
        .collection('users')
        .doc(_userId)
        .collection('gorevler')
        .doc(docId)
        .delete();
  }

  // ✅ Tüm toplantıları getir
  static Future<List<Map<String, dynamic>>> getirToplantilar() async {
    if (_userId == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('toplantilar')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  // ✅ Tüm görevleri getir (doc.id dahil)
  static Future<List<Map<String, dynamic>>> getirGorevler() async {
    if (_userId == null) return [];
    final snapshot = await _db
        .collection('users')
        .doc(_userId)
        .collection('gorevler')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // 🔁 ID eklendi
      return data;
    }).toList();
  }
}
