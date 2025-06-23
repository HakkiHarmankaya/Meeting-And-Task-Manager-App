import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SifreDegistirEkrani extends StatefulWidget {
  @override
  _SifreDegistirEkraniState createState() => _SifreDegistirEkraniState();
}

class _SifreDegistirEkraniState extends State<SifreDegistirEkrani> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _loading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: _currentPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(_newPasswordController.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Şifre başarıyla değiştirildi."),
        backgroundColor: Colors.green,
      ));
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = "Bir hata oluştu.";
      if (e.code == 'wrong-password') {
        message = "Mevcut şifre yanlış.";
      } else if (e.code == 'weak-password') {
        message = "Yeni şifre çok zayıf.";
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF5D3FD3);

    return Scaffold(
      backgroundColor: Color(0xFFF3F0FF),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 130,
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Container(
                      margin: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 40),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 16),
                            Text("Şifreyi Değiştir", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 16),
                            _buildTextField(
                              controller: _currentPasswordController,
                              label: "Mevcut Şifre",
                              obscure: true,
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              controller: _newPasswordController,
                              label: "Yeni Şifre",
                              obscure: true,
                            ),
                            SizedBox(height: 16),
                            _buildTextField(
                              controller: _confirmPasswordController,
                              label: "Yeni Şifre (Tekrar)",
                              obscure: true,
                              validator: (value) {
                                if (value != _newPasswordController.text) {
                                  return "Şifreler uyuşmuyor";
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 32),
                            ElevatedButton.icon(
                              onPressed: _loading ? null : _changePassword,
                              icon: Icon(Icons.lock),
                              label: Text("Şifreyi Güncelle"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          Positioned(
            top: 140,
            left: 20,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Colors.black54, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator ??
          (value) => value == null || value.isEmpty ? "Bu alan boş bırakılamaz" : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
