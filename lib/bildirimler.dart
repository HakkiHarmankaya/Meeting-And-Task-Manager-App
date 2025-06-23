import 'package:flutter/material.dart';

class BildirimlerSayfasi extends StatelessWidget {
  final List<String> bildirimler;
  final Function(int) onSekmeDegistir;

  const BildirimlerSayfasi({
    Key? key,
    required this.bildirimler,
    required this.onSekmeDegistir,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kartRenk = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Üst mor başlık alanı
          Container(
            height: 130,
            decoration: const BoxDecoration(
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
          ),

          // Logo
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

          // Bildirim içeriği
          Padding(
            padding: const EdgeInsets.only(top: 150, left: 16, right: 16, bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                color: kartRenk,
                borderRadius: BorderRadius.circular(24),
              ),
              child: bildirimler.isEmpty
                  ? const Center(child: Text("Henüz bildirim yok."))
                  : ListView.builder(
                      itemCount: bildirimler.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: const Icon(Icons.notifications_active),
                          title: Text(bildirimler[index]),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4, // Bildirim sekmesi
        selectedItemColor: const Color(0xFF5D3FD3),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index != 4) {
            onSekmeDegistir(index);
            Navigator.pop(context);
          }
        },
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
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Bildirimler",
          ),
        ],
      ),
    );
  }
}