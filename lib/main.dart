import 'package:flutter/material.dart';
import 'package:proje/SifreDegistirEkrani.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'toplantiDuzen.dart';
import 'gorevDuzen.dart';
import 'bildirimler.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login_screen.dart'; // login_screen dosyanı ekle
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart'; // en üstte
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'loading_screen.dart';



class Toplanti {
  String adi;
  String durumu;
  String aciklama;
  DateTime tarih;
  TimeOfDay saat;

  Toplanti({
    required this.adi,
    required this.durumu,
    required this.aciklama,
    required this.tarih,
    required this.saat,
  });

  factory Toplanti.fromMap(Map<String, dynamic> map) {
    final saatSplit = (map['saat'] as String).split(":");
    return Toplanti(
      adi: map['adi'],
      durumu: map['durumu'],
      aciklama: map['aciklama'],
      tarih: DateTime.parse(map['tarih']),
      saat: TimeOfDay(hour: int.parse(saatSplit[0]), minute: int.parse(saatSplit[1])),
    );
  }
}

class Gorev {
  String kisiAdi;
  String gorevAdi;
  String gorevAmaci;
  DateTime tarih;
  TimeOfDay saat;

  Gorev({
    required this.kisiAdi,
    required this.gorevAdi,
    required this.gorevAmaci,
    required this.tarih,
    required this.saat,
  });

  factory Gorev.fromMap(Map<String, dynamic> map) {
    final saatSplit = (map['saat'] as String).split(":");
    return Gorev(
      kisiAdi: map['kisiAdi'],
      gorevAdi: map['gorevAdi'],
      gorevAmaci: map['gorevAmaci'],
      tarih: DateTime.parse(map['tarih']),
      saat: TimeOfDay(hour: int.parse(saatSplit[0]), minute: int.parse(saatSplit[1])),
    );
  }
}

class CalendarEventLoader {
  static Future<List<Toplanti>> getToplantilarForDay(DateTime day) async {
    final rawList = await FirestoreService.getirToplantilar();

    return rawList.map((map) => Toplanti.fromMap(map)).where((t) =>
        t.tarih.year == day.year &&
        t.tarih.month == day.month &&
        t.tarih.day == day.day).toList();
  }

  static Future<List<Gorev>> getGorevlerForDay(DateTime day) async {
    final rawList = await FirestoreService.getirGorevler();

    return rawList.map((map) => Gorev.fromMap(map)).where((g) =>
        g.tarih.year == day.year &&
        g.tarih.month == day.month &&
        g.tarih.day == day.day).toList();
  }
}

Widget buildEventList(BuildContext context, DateTime selectedDay) {
  final bool isDark = Theme.of(context).brightness == Brightness.dark;
  final Color kartRenk = isDark ? Color(0xFF1E1E1E) : Colors.white;

  return FutureBuilder(
    future: Future.wait([
      CalendarEventLoader.getToplantilarForDay(selectedDay),
      CalendarEventLoader.getGorevlerForDay(selectedDay),
    ]),
    builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      final toplantilar = snapshot.data![0] as List<Toplanti>;
      final gorevler = snapshot.data![1] as List<Gorev>;

      if (toplantilar.isEmpty && gorevler.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Bu gün için kayıtlı toplantı veya görev yok."),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kartRenk,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (gorevler.isNotEmpty) ...[
                SizedBox(height: 16),
                Text("Görevler", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                ...gorevler.map((g) => ListTile(
                      title: Text(g.gorevAdi),
                      subtitle: Text(
                          "${g.tarih.year}/${g.tarih.month}/${g.tarih.day} - ${g.saat.hour.toString().padLeft(2, '0')}:${g.saat.minute.toString().padLeft(2, '0')}"),
                    )),
              ],
            ],
          ),
        ),
      );
    },
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

   // 🔽 Splash ekranı başlat
  FlutterNativeSplash.preserve(widgetsBinding: WidgetsFlutterBinding.ensureInitialized());
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    // 🔽 Splash ekranı kapat
  FlutterNativeSplash.remove();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}


class AuthGate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return MeetingApp(
            onThemeChanged: (_) {},
            darkTheme: false,
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
}



class _MyAppState extends State<MyApp> {
  bool _darkTheme = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _darkTheme = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takvimli Planlayıcı',
      debugShowCheckedModeBanner: false,
      theme: _darkTheme
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(primary: Color(0xFF5D3FD3)),
              scaffoldBackgroundColor: Color(0xFF121212),
            )
          : ThemeData(
              fontFamily: 'Roboto',
              scaffoldBackgroundColor: Color(0xFFF3F0FF),
              colorScheme: ColorScheme.fromSeed(
                seedColor: Color(0xFF5D3FD3),
                brightness: Brightness.light,
              ),
            ),
            // 🔽 FirebaseAuth ile giriş kontrolü:
          home: AuthGate(), // ✅ Artık bu yeterli

    );
  }
}
class MeetingApp extends StatefulWidget {
  final Function(bool) onThemeChanged;
  final bool darkTheme;

  const MeetingApp({
    required this.onThemeChanged,
    required this.darkTheme,
  });

  @override
  _MeetingAppState createState() => _MeetingAppState();
}

class _MeetingAppState extends State<MeetingApp> {
  int _selectedIndex = 1;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _notificationsEnabled = true;
  List<String> bildirimler = [];
  final List<String> _gonderilenBildirimler = [];
  final List<String> _gonderilenGorevBildirimleri = [];
  String _ad = '';
  String _soyad = '';
  String _sirket = '';


      void _kullaniciBilgileriniYukle() async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
          final data = doc.data();
          if (data != null) {
            setState(() {
              _ad = data['ad'] ?? '';
              _soyad = data['soyad'] ?? '';
              _sirket = data['sirket'] ?? '';
            });
          }
        }
      }


      void _bildirimEkleEtkinlik(String mesaj) {
        setState(() {
          bildirimler.add(mesaj);
        });
      }


@override
void initState() {
  super.initState();
  _startNotificationChecker(); // ✅ Burası olmazsa çalışmaz
  _startGorevNotificationChecker();  // görevler için ⬅ BUNU YENİ EKLE
  _kullaniciBilgileriniYukle(); // 👈 PROFİL BİLGİSİNİ AL
}


void _onItemTapped(int index) {
  if (index == 4) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BildirimlerSayfasi(
          bildirimler: bildirimler,
          onSekmeDegistir: _onItemTapped,
        ),
      ),
    );
  } else {
    setState(() {
      _selectedIndex = index;
    });
  }
}


void _startGorevNotificationChecker() {
  Timer.periodic(Duration(minutes: 1), (timer) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("gorev_listesi") ?? [];

    for (var json in list) {
      final map = jsonDecode(json);
      final saatSplit = (map['saat'] as String).split(":");
      final tarih = DateTime.parse(map['tarih']);
      final saat = TimeOfDay(
        hour: int.parse(saatSplit[0]),
        minute: int.parse(saatSplit[1]),
      );

      final gorevZamani = DateTime(
        tarih.year,
        tarih.month,
        tarih.day,
        saat.hour,
        saat.minute,
      );

      final fark = gorevZamani.difference(now);

      print("GÖREV KONTROL: şimdi: $now, görev zamanı: $gorevZamani, fark: ${fark.inMinutes} dk");

      if (fark.inSeconds <= 60) {
        final mesaj =
            'Görev "${map['gorevAdi']}" 30 dakika sonra sona eriyor (${tarih.day}/${tarih.month} - ${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')})';

        if (!_gonderilenGorevBildirimleri.contains(mesaj)) {
          _bildirimEkleEtkinlik(mesaj);
          _gonderilenGorevBildirimleri.add(mesaj);
        }
      }
    }
  });
}




void _startNotificationChecker() {
  Timer.periodic(Duration(minutes: 1), (timer) async {
    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList("toplanti_listesi") ?? [];

    for (var json in list) {
      final toplanti = Toplanti.fromMap(jsonDecode(json));
      final toplantZamani = DateTime(
        toplanti.tarih.year,
        toplanti.tarih.month,
        toplanti.tarih.day,
        toplanti.saat.hour,
        toplanti.saat.minute,
      );

      final fark = toplantZamani.difference(now);

      if (fark.inMinutes == 1) {
        final mesaj =
            'Toplanti "${toplanti.adi}" 30 dakika sonra başliyor (${toplanti.tarih.day}/${toplanti.tarih.month} ${toplanti.saat.hour.toString().padLeft(2, '0')}:${toplanti.saat.minute.toString().padLeft(2, '0')})';

        if (!_gonderilenBildirimler.contains(mesaj)) {
          _bildirimEkleEtkinlik(mesaj);
          _gonderilenBildirimler.add(mesaj);
        }
      }
    }
  });
}



  Widget _buildCustomAppBar() {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Color(0xFF5D3FD3),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, 1),
                  blurRadius: 6,
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          buildEventList(context, _selectedDay),
        ],
      ),
    );
  }

  


Widget _buildHomeContent() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final kartRenk = isDark ? Color(0xFF1E1E1E) : Colors.white;

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Center(child: Text("Kullanıcı oturumu açık değil."));
  }

  return FutureBuilder(
    future: Future.wait([
      FirebaseFirestore.instance
          .collection('toplantilar')
          .where('uid', isEqualTo: user.uid)
          .get(),
      FirebaseFirestore.instance
          .collection('gorevler')
          .where('uid', isEqualTo: user.uid)
          .get(),
    ]),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return Center(child: CircularProgressIndicator());
      }

      final toplantilarDocs = snapshot.data![0].docs;
      final gorevlerDocs = snapshot.data![1].docs;

      final toplantilar = toplantilarDocs.map((doc) {
        final data = doc.data();
        final saatSplit = (data['saat'] as String).split(":");
        return Toplanti(
          adi: data['adi'],
          durumu: data['durumu'],
          aciklama: data['aciklama'],
          tarih: DateTime.parse(data['tarih']),
          saat: TimeOfDay(
            hour: int.parse(saatSplit[0]),
            minute: int.parse(saatSplit[1]),
          ),
        );
      }).toList();

      final gorevler = gorevlerDocs.map((doc) {
        final data = doc.data();
        final saatSplit = (data['saat'] as String).split(":");
        return Gorev(
          kisiAdi: data['kisiAdi'],
          gorevAdi: data['gorevAdi'],
          gorevAmaci: data['gorevAmaci'],
          tarih: DateTime.parse(data['tarih']),
          saat: TimeOfDay(
            hour: int.parse(saatSplit[0]),
            minute: int.parse(saatSplit[1]),
          ),
        );
      }).toList();

      return Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Toplantı ve Görev Yönetimi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5D3FD3),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              MeetingButton(
                icon: Icons.manage_accounts,
                text: "Ekip Görevi Ekle ve Düzenle",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GorevDuzen(
                        onBildirim: _bildirimEkleEtkinlik,
                      ),
                    ),
                  );
                },
              ),
              MeetingButton(
                icon: Icons.edit_calendar,
                text: "Toplantı Ekle ve Düzenle",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ToplantiDuzen(
                        onBildirim: _bildirimEkleEtkinlik,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}


  Widget _buildSettingsContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kartRenk = isDark ? Color(0xFF1E1E1E) : Colors.white;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kartRenk,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SwitchListTile(
              title: Text("Koyu Tema"),
              value: widget.darkTheme,
              onChanged: widget.onThemeChanged,
              secondary: Icon(Icons.dark_mode),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kartRenk,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SwitchListTile(
              title: Text("Bildirimler"),
              value: _notificationsEnabled,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
              secondary: Icon(Icons.notifications),
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kartRenk,
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              leading: Icon(Icons.info),
              title: Text("Hakkında"),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: "Takvimli Planlayıcı",
                  applicationVersion: "1.0.0",
                  applicationLegalese: "© 2025 Hakkı",
                );
              },
            ),
          ),
        ],
      ),
    );
  }

Widget _buildProfileContent() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final kartRenk = isDark ? Color(0xFF1E1E1E) : Colors.white;

  return Center(
    child: Container(
      margin: EdgeInsets.all(20),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple.shade100,
            child: Icon(Icons.person, size: 50, color: Colors.deepPurple),
          ),
          SizedBox(height: 16),
          Text("$_ad $_soyad", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(_sirket, style: TextStyle(color: Colors.grey)),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SifreDegistirEkrani()),
              );
            },
            icon: Icon(Icons.lock_outline),
            label: Text("Şifreyi Değiştir"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
              );
            },
            icon: Icon(Icons.logout),
            label: Text("Çıkış Yap"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            ),
          ),
        ],
      ),
    ),
  );
}





  @override
  Widget build(BuildContext context) {
    Widget currentContent;
    switch (_selectedIndex) {
      case 0:
        currentContent = _buildHomeContent();
        break;
      case 1:
        currentContent = _buildCalendarContent();
        break;
      case 2:
        currentContent = _buildSettingsContent();
        break;
      case 3:
        currentContent = _buildProfileContent();
        break;
        case 4:
          currentContent = BildirimlerSayfasi(
            bildirimler: bildirimler,
            onSekmeDegistir: _onItemTapped,
          );
          break;
      default:
        currentContent = _buildHomeContent();
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Column(
            children: [
              _buildCustomAppBar(),
              Expanded(child: SingleChildScrollView(child: currentContent)),
            ],
          ),
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/logo.png',
                height: 100,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF5D3FD3),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Ana Sayfa",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: "Takvim",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Ayarlar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profil",
          ),
          BottomNavigationBarItem( //111111111111111111111111111111111111111111111111111111111111111111111111111
            icon: Icon(Icons.notifications),
            label: "Bildirimler",
          ),
        ],
      ),
    );
  }
}

      

class MeetingButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const MeetingButton({
    required this.icon,
    required this.text,
    required this.onTap,
  });


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 26),
          label: Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF5D3FD3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }
}
