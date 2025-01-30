import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'loginscreen.dart';

const String baseUrl = "http://192.168.1.35:5062/api";

class CalisanTakvimPage extends StatefulWidget {
  @override
  _CalisanTakvimPageState createState() => _CalisanTakvimPageState();
}

class _CalisanTakvimPageState extends State<CalisanTakvimPage> {
  String employeeName = "Bilgiler yükleniyor...";
  String email = "";
  List<dynamic> appointments = [];
  Map<DateTime, List<String>> events = {}; // Takvim için randevular

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    loadEmployeeAppointments();
  }

  /// 📌 **Çalışana Ait Randevuları Getir**
  Future<void> loadEmployeeAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      Navigator.pushReplacementNamed(context, "/login");
      return;
    }

    try {
      /// 📌 **Çalışan Bilgilerini Getir**
      final profileResponse = await http.get(
        Uri.parse("$baseUrl/profile/getMyProfile"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (profileResponse.statusCode != 200) throw Exception("Profil bilgisi alınamadı.");
      final profileData = json.decode(profileResponse.body);
      setState(() {
        employeeName = profileData["name"];
        email = profileData["email"];
      });

      /// 📌 **Tüm Randevuları Getir**
      final appointmentsResponse = await http.get(
        Uri.parse("$baseUrl/appointments/all"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (appointmentsResponse.statusCode != 200) throw Exception("Randevu bilgisi alınamadı.");
      final allAppointments = json.decode(appointmentsResponse.body);

      /// 📌 **Sadece Çalışanın Randevularını Filtrele**
      final employeeAppointments = allAppointments.where((app) => app["employee"] == employeeName).toList();

      setState(() {
        appointments = employeeAppointments;
        _loadAppointmentsToCalendar();
      });

    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Bir hata oluştu: $error")));
    }
  }

  /// 📌 **Randevuları Takvime Yükle**
  void _loadAppointmentsToCalendar() {
    setState(() {
      events.clear();
      for (var app in appointments) {
        if (app["date"] == null || app["date"].isEmpty) {
          print("❌ HATA: Tarih boş veya null geldi: ${app["date"]}");
          continue; // ❌ Hatalı veriyi atla
        }

        DateTime date = DateTime.parse(app["date"]).toLocal();
        DateTime eventDate = DateTime(date.year, date.month, date.day);

        String serviceInfo = "${app["service"]} - ${app["date"]}"; // API'dan nasıl geldiyse öyle göster

        if (!events.containsKey(eventDate)) {
          events[eventDate] = [];
        }
        events[eventDate]!.add(serviceInfo);
      }
    });
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
        title: Text("Çalışan Randevuları"),
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

            /// 📌 **Çalışan Bilgileri**
            Card(
              child: ListTile(
                title: Text("Çalışan Bilgileri", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Ad: $employeeName"),
                    Text("Email: $email"),
                  ],
                ),
              ),
            ),

            SizedBox(height: 15),

            /// 📌 **Çalışana Ait Randevular Listesi**
            Card(
              child: Column(
                children: [
                  ListTile(title: Text("Randevularınız", style: TextStyle(fontWeight: FontWeight.bold))),
                  ...appointments.map((app) {
                    return ListTile(
                      title: Text("${app["service"]}"),
                      subtitle: Text("📅 Tarih: ${app["date"]}\n👤 Müşteri: ${app["customer"] ?? "Bilinmiyor"}"),
                    );
                  }),
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
                        return events[eventDate] ?? [];
                      },
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });

                        /// 📌 Seçili günün etkinliklerini Snackbar ile göster
                        if (events[selectedDay] != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Randevular: ${events[selectedDay]!.join(', ')}"),
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
