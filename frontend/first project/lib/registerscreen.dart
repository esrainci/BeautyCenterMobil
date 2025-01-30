import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'homescreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Şifreler uyuşmuyor.')),
        );
        return;
      }

      // API'ye kullanıcı verisini gönderme
      try {
        final response = await http.post(
          Uri.parse('http://192.168.1.35:5062/api/Auth/register'), // API URL
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'email': _emailController.text,
            'phone': _phoneController.text,
            'password': _passwordController.text,
            'name': '${_firstNameController.text} ${_lastNameController.text}',
            'role': 'Customer', // Varsayılan olarak 'Customer' gönderiyoruz
            'favorites': [],
            'points': [],
          }),
        );

        if (response.statusCode == 200) {
          // Başarılı kayıt
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          // API yanıtını log'la
          print('Error: ${response.statusCode}');
          print('Response body: ${response.body}');

          // Hata mesajını kullanıcıya göster
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Kayıt sırasında bir hata oluştu: ${response.body}')),
          );
        }
      } catch (e) {
        // Bağlantı hatası
        print('Exception: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Bağlantı hatası. Lütfen tekrar deneyin.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFDF3F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black), // 🔙 Geri Butonu
          onPressed: () {
            Navigator.pop(context); // ✅ Önceki sayfaya geri dön
          },
        ),
        title: Text(
          "Kayıt Ol",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(2, 5),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _firstNameController,
                      label: "Ad",
                      hintText: "Adınızı giriniz",
                    ),
                    _buildTextField(
                      controller: _lastNameController,
                      label: "Soyad",
                      hintText: "Soyadınızı giriniz",
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: "E-posta",
                      hintText: "E-posta adresinizi giriniz",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: "Telefon Numarası",
                      hintText: "Telefon numaranızı giriniz",
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      label: "Şifre",
                      hintText: "Şifrenizi giriniz",
                      obscureText: true,
                    ),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: "Şifreyi Onayla",
                      hintText: "Şifrenizi tekrar giriniz",
                      obscureText: true,
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD89290),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        onPressed: _submitForm,
                        child: Text(
                          "Kayıt Ol",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label alanı boş bırakılamaz.';
          }
          return null;
        },
      ),
    );
  }
}