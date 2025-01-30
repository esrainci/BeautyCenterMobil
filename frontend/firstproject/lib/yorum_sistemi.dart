import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://192.168.1.35:5062/api/UserReviews';

class YorumSistemiPage extends StatefulWidget {
  @override
  _YorumSistemiPageState createState() => _YorumSistemiPageState();
}

class _YorumSistemiPageState extends State<YorumSistemiPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController ratingController = TextEditingController();
  TextEditingController commentController = TextEditingController();

  List<dynamic> yorumlar = [];
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _getSavedEmail();
    _loadReviews();
  }

  /// 📌 **LocalStorage'dan Kullanıcı E-postasını Getir**
  Future<void> _getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserEmail = prefs.getString('email');
      emailController.text = currentUserEmail ?? "";
    });
  }

  /// 📌 **API'den Yorumları Çek**
  Future<void> _loadReviews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/getAllReviews'));

      if (response.statusCode == 200) {
        final List<dynamic> fetchedReviews = json.decode(response.body);
        setState(() {
          yorumlar = fetchedReviews;
        });
      }
    } catch (e) {
      print('❌ Bağlantı Hatası: $e');
    }
  }

  /// 📌 **Yeni Yorum Ekle**
  Future<void> _addReview() async {
    final String email = emailController.text.trim();
    final int rating = int.tryParse(ratingController.text.trim()) ?? 0;
    final String comment = commentController.text.trim();

    if (email.isEmpty || rating < 1 || rating > 5 || comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lütfen geçerli bir e-posta, puan (1-5) ve yorum girin!'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/addReview'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"userEmail": email, "rating": rating, "comment": comment}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yorum eklendi!')));
        _loadReviews();
        commentController.clear();
        ratingController.clear();
      }
    } catch (e) {
      print('❌ Bağlantı Hatası: $e');
    }
  }

  /// 📌 **Yorumu Sil**
  Future<void> _deleteReview(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/deleteReview/$id?userEmail=$currentUserEmail'));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yorum silindi!')));
        _loadReviews();
      }
    } catch (e) {
      print('❌ Bağlantı Hatası: $e');
    }
  }

  /// 📌 **Yorumu Güncelle**
  Future<void> _editReview(int id, String oldComment, int oldRating) async {
    TextEditingController newCommentController = TextEditingController(text: oldComment);
    TextEditingController newRatingController = TextEditingController(text: oldRating.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Yorumu Güncelle"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: newCommentController, decoration: InputDecoration(labelText: "Yeni Yorum")),
            TextField(controller: newRatingController, decoration: InputDecoration(labelText: "Yeni Puan (1-5)")),
          ],
        ),
        actions: [
          TextButton(
            child: Text("İptal"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Kaydet"),
            onPressed: () async {
              final String newComment = newCommentController.text.trim();
              final int newRating = int.tryParse(newRatingController.text.trim()) ?? 0;

              if (newComment.isNotEmpty && newRating >= 1 && newRating <= 5) {
                final response = await http.put(
                  Uri.parse('$baseUrl/updateReview/$id'),
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode({"comment": newComment, "rating": newRating, "userEmail": currentUserEmail}),
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Yorum güncellendi!')));
                  _loadReviews();
                }
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  /// 📌 **Flutter UI (Daha Şık Görünüm)**
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Kullanıcı Yorumları"),
        backgroundColor: Colors.purple.shade800,
      ),
      backgroundColor: Colors.purple.shade50,
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            /// 📌 **Yorum Ekleme Formu**
            Card(
              color: Colors.white,
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(controller: emailController, decoration: InputDecoration(labelText: "E-posta")),
                    TextField(controller: ratingController, decoration: InputDecoration(labelText: "Puan (1-5)")),
                    TextField(controller: commentController, decoration: InputDecoration(labelText: "Yorum")),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addReview,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple, // Buton arka planı
                        foregroundColor: Colors.white,  // Yazı rengini beyaz yapar ✅
                      ),
                      child: Text("Yorumu Ekle"),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            /// 📌 **Yorum Listesi**
            Expanded(
              child: ListView.builder(
                itemCount: yorumlar.length,
                itemBuilder: (context, index) {
                  final yorum = yorumlar[index];

                  return Card(
                    color: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      title: Text(yorum["comment"], style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Puan: ${yorum["rating"]} - Tarih: ${yorum["createdAt"]}"),
                      trailing: yorum["userEmail"] == currentUserEmail
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(Icons.edit, color: Colors.blue), onPressed: () => _editReview(yorum["id"], yorum["comment"], yorum["rating"])),
                          IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => _deleteReview(yorum["id"])),
                        ],
                      )
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
