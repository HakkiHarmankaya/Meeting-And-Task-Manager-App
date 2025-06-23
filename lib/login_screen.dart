import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'sifre_sifirla_ekrani.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController(); // 🔁 Yalnızca kayıt için
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isLogin = true;
  bool _showPassword = false;
  String? _errorMessage;

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "E-posta ve şifre boş bırakılamaz.");
      return;
    }

    if (!_isLogin && password != confirmPassword) {
      setState(() => _errorMessage = "Şifreler uyuşmuyor.");
      return;
    }

    try {
      final auth = FirebaseAuth.instance;

      if (_isLogin) {
        await auth.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await auth.createUserWithEmailAndPassword(email: email, password: password);
        final user = auth.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'ad': _nameController.text.trim(),
            'soyad': _surnameController.text.trim(),
            'sirket': _companyController.text.trim(),
            'email': user.email,
            'createdAt': Timestamp.now(),
          });
        }
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MeetingApp(onThemeChanged: (_) {}, darkTheme: false),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'email-already-in-use':
            _errorMessage = "Bu e-posta zaten kullanılıyor.";
            break;
          case 'invalid-email':
            _errorMessage = "Geçersiz e-posta adresi.";
            break;
          case 'user-disabled':
            _errorMessage = "Kullanıcı hesabı devre dışı bırakıldı.";
            break;
          case 'user-not-found':
            _errorMessage = "Kullanıcı bulunamadı.";
            break;
          case 'wrong-password':
            _errorMessage = "Hatalı şifre.";
            break;
          case 'weak-password':
            _errorMessage = "Şifre en az 6 karakter olmalıdır.";
            break;
          default:
            _errorMessage = "Bir hata oluştu. Lütfen tekrar deneyin.";
        }
      });
    } catch (e) {
      setState(() => _errorMessage = "Bir hata oluştu: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF5D3FD3);

    return Scaffold(
      body: Container(
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
            children: [
              Image.asset('assets/logo.png', height: 120),
              SizedBox(height: 16),
              Text(_isLogin ? "Giriş Yap" : "Kayıt Ol",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Ad"),
                ),
                TextField(
                  controller: _surnameController,
                  decoration: InputDecoration(labelText: "Soyad"),
                ),
                TextField(
                  controller: _companyController,
                  decoration: InputDecoration(labelText: "Şirket"),
                ),
                SizedBox(height: 8),
              ],
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "E-posta"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Şifre",
                  suffixIcon: _isLogin
                      ? IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                        )
                      : null,
                ),
                obscureText: _isLogin ? !_showPassword : true,
              ),
              if (!_isLogin)
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: "Şifre Tekrar"),
                  obscureText: true,
                ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 48, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _handleAuth,
                child: Text(_isLogin ? "Giriş Yap" : "Kayıt Ol"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null;
                  });
                },
                child: Text(_isLogin
                    ? "Hesabın yok mu? Kayıt ol"
                    : "Zaten hesabın var mı? Giriş yap"),
              ),
              if (_isLogin)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SifreSifirlaEkrani()),
                    );
                  },
                  child: Text("Şifremi Unuttum?", style: TextStyle(color: Colors.deepPurple)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
