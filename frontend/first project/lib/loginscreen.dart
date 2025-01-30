import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'homescreen.dart';
import 'calisantakvim.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isCustomerLogin = true; // Kullanıcı tipi (Müşteri mi, Çalışan mı?)

  final String apiUrl = 'http://192.168.1.35:5062/api/Auth/login';

  Future<void> login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
          'role': _isCustomerLogin ? 'customer' : 'employee', // ✅ Role'e göre giriş yapılıyor
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['token'] != null) {
          await _saveToken(data['token']); // ✅ Token'ı kaydet

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Giriş başarılı! Yönlendiriliyorsunuz...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // 1 saniye bekleyip yönlendirme yap
          await Future.delayed(Duration(seconds: 1));

          if (_isCustomerLogin) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen())); // ✅ Müşteri giriş yaptıysa HomeScreen'e yönlendir
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CalisanTakvimPage())); // ✅ Çalışan giriş yaptıysa CalisanTakvim'e yönlendir
          }
        } else {
          showErrorDialog('Giriş başarısız. Lütfen bilgilerinizi kontrol edin.');
        }
      } else {
        showErrorDialog('Hatalı giriş bilgileri.');
      }
    } catch (e) {
      showErrorDialog('Bağlantı hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tamam'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(
                'https://i.imgur.com/hzMfMET.png',
                height: 120,
              ),
              SizedBox(height: 20),
              Text(
                'İnci Güzellik Merkezine Hoş Geldiniz!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),

              /// 📌 **Müşteri / Çalışan Seçimi**
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => setState(() => _isCustomerLogin = true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isCustomerLogin ? Colors.purple : Colors.white,
                      foregroundColor: _isCustomerLogin ? Colors.white : Colors.purple,
                      side: BorderSide(color: Colors.purple, width: 2),
                    ),
                    child: Text('Müşteri Girişi'),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => setState(() => _isCustomerLogin = false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !_isCustomerLogin ? Colors.purple : Colors.white,
                      foregroundColor: !_isCustomerLogin ? Colors.white : Colors.purple,
                      side: BorderSide(color: Colors.purple, width: 2),
                    ),
                    child: Text('Çalışan Girişi'),
                  ),
                ],
              ),

              SizedBox(height: 20),
              _buildTextField(_emailController, 'E-posta ya da Telefon', Icons.email, false),
              SizedBox(height: 20),
              _buildTextField(_passwordController, 'Şifre', Icons.lock, true),
              SizedBox(height: 20),

              /// 📌 **Giriş Yap Butonu**
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  'Giriş Yap',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),

              SizedBox(height: 10),

              /// 📌 **Kayıt Ol Butonu**
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                child: Text(
                  'Hesabınız yok mu? Kayıt Olun',
                  style: TextStyle(color: Colors.purple.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(icon, color: Colors.purple),
      ),
    );
  }
}
