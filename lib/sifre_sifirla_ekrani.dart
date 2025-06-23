import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SifreSifirlaEkrani extends StatefulWidget {
  @override
  _SifreSifirlaEkraniState createState() => _SifreSifirlaEkraniState();
}

class _SifreSifirlaEkraniState extends State<SifreSifirlaEkrani> {
  final TextEditingController _emailController = TextEditingController();
  String mesaj = '';
  bool isLoading = false;

  Future<void> sifremiSifirla() async {
    setState(() {
      isLoading = true;
      mesaj = '';
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      setState(() {
        mesaj = "📩 Şifre sıfırlama e-postası gönderildi.";
      });
    } catch (e) {
      setState(() {
        mesaj = "❌ Hata: ${e.toString()}";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF5D3FD3);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              primaryColor.withOpacity(0.9),
              primaryColor.withOpacity(0.2),
              Color(0xFFF3F0FF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 120),
              SizedBox(height: 24),
              Text(
                "Şifre Sıfırlama",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "E-posta",
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: isLoading ? null : sifremiSifirla,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: Text("Sıfırlama Linki Gönder"),
              ),
              SizedBox(height: 16),
              Text(
                mesaj,
                style: TextStyle(
                  color: mesaj.contains("Hata") ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("← Giriş ekranına dön", style: TextStyle(color: Colors.deepPurple)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
