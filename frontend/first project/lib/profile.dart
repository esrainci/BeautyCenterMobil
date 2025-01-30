import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'loginscreen.dart';

const String baseUrl = "http://192.168.1.35:5062/api";

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "Bilgiler yükleniyor...";
  String email = "";
  String phone = "Bilinmiyor";
  List<String> favorites = [];
  List<dynamic> appointments = [];
  List<dynamic> points = [];
  Map<DateTime, List<String>> events = {}; // Takvim için randevular

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController favoriteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProfileData();
  }

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/profile/getMyProfile"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        name = data["name"];
        email = data["email"];
        phone = data["phone"] ?? "Bilinmiyor";
        favorites = List<String>.from(data["favorites"]);
        appointments = data["appointments"];
        points = data["points"];
        _loadAppointmentsToCalendar();
      });
    } else {
      print("Profil verisi çekilemedi.");
    }
  }

  Future<void> addFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    if (favoriteController.text.isEmpty) return;

    final response = await http.post(
      Uri.parse("$baseUrl/profile/addFavorite"),
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: json.encode({"serviceName": favoriteController.text}),
    );

    if (response.statusCode == 200) {
      setState(() {
        favorites.add(favoriteController.text);
      });
      favoriteController.clear();
    }
  }
  Future<void> updatePassword() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Oturum açmanız gerekiyor.")));
      return;
    }

    final response = await http.put(
      Uri.parse("$baseUrl/Auth/updatePassword"),
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: json.encode({
        "currentPassword": currentPasswordController.text,
        "newPassword": newPasswordController.text,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Şifre başarıyla güncellendi")));
      currentPasswordController.clear();
      newPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Şifre güncelleme başarısız.")));
    }
  }

  Future<void> removeFavorite(String favorite) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.delete(
      Uri.parse("$baseUrl/profile/removeFavorite"),
      headers: {"Authorization": "Bearer $token", "Content-Type": "application/json"},
      body: json.encode({"serviceName": favorite}),
    );

    if (response.statusCode == 200) {
      setState(() {
        favorites.remove(favorite);
      });
    }
  }

  void _loadAppointmentsToCalendar() {
    setState(() {
      events.clear();
      for (var app in appointments) {
        DateTime date = DateTime.parse(app["date"]).toLocal();
        DateTime eventDate = DateTime(date.year, date.month, date.day); // 🔥 SADECE TARİH ALINIYOR

        String serviceInfo = "${app["service"]} (${app["employee"] ?? 'Bilinmiyor'})";

        if (!events.containsKey(eventDate)) {
          events[eventDate] = [];
        }
        events[eventDate]!.add(serviceInfo);
      }
    });

    print("Takvim etkinlikleri yüklendi: $events"); // ✅ Hata ayıklamak için
  }
  Future<void> cancelAppointment(int appointmentId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.delete(
      Uri.parse("$baseUrl/appointments/cancel/$appointmentId"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        appointments.removeWhere((app) => app["id"] == appointmentId);
        _loadAppointmentsToCalendar();
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Randevu iptal edildi.")));
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profilim ve Takvim"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: logout,
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 10),

            /// 📌 Kişisel Bilgiler Kartı
            Card(
              child: ListTile(
                title: Text("Kişisel Bilgiler", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ad: $name"),
                    Text("Email: $email"),
                    Text("Telefon: $phone"),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            /// 📌 Favoriler Kartı
            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Favori Hizmetler", style: TextStyle(fontWeight: FontWeight.bold))),
                  ...favorites.map((fav) => ListTile(
                    title: Text(fav),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => removeFavorite(fav),
                    ),
                  )),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: favoriteController,
                            decoration: InputDecoration(labelText: "Yeni Favori Ekle"),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: addFavorite,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 15),

            /// 📌 Puanlar Kartı
            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Puanlar", style: TextStyle(fontWeight: FontWeight.bold))),
                  ...points.map((point) => ListTile(title: Text("${point['points']} puan - ${point['earnedDate']}"))),
                ],
              ),
            ),

            SizedBox(height: 15),

            /// 📌 Şifre Güncelleme Kartı
            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Şifre Güncelle", style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: currentPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(labelText: "Mevcut Şifre"),
                        ),
                        TextField(
                          controller: newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(labelText: "Yeni Şifre"),
                        ),
                        ElevatedButton(
                          onPressed: updatePassword,
                          child: Text("Şifreyi Güncelle"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 📌 **Randevular Listesi**
            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Randevular", style: TextStyle(fontWeight: FontWeight.bold))),
                  ...appointments.map((app) => ListTile(
                    title: Text("${app["service"]} - ${app["date"]}"),
                    subtitle: Text("Çalışan: ${app["employee"] ?? "Bilinmiyor"}"),
                    trailing: IconButton(
                      icon: Icon(Icons.cancel, color: Colors.red),
                      onPressed: () => cancelAppointment(app["id"]),
                    ),
                  )),
                ],
              ),
            ),

            SizedBox(height: 15),

            /// 📌 **Takvim (Randevular İşaretlenmiş)**
            Card(
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text("Randevu Takvimi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Divider(),
                    TableCalendar(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => _selectedDay != null && isSameDay(_selectedDay, day),
                      eventLoader: (day) {
                        DateTime eventDate = DateTime(day.year, day.month, day.day);
                        return events[eventDate] ?? []; // 🔥 DÜZELTİLDİ!
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });

                        /// 📌 Seçili günün etkinliklerini göster
                        if (events[selectedDay] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Etkinlikler: ${events[selectedDay]!.join(', ')}"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
