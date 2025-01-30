import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RandevuScreen extends StatefulWidget {
  @override
  _RandevuScreenState createState() => _RandevuScreenState();
}

class _RandevuScreenState extends State<RandevuScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String? _selectedEmployee;
  String? _selectedService;
  String? _selectedTime;

  final Map<String, List<String>> servicesByEmployee = {
    "Samir Bey": ["Cilt Bakımı", "Masaj"],
    "Esranur Hanım": ["Saç Bakımı", "Cilt Bakımı"],
    "İnci Hanım": ["Masaj", "Saç Bakımı"],
  };

  final List<String> availableTimes = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30",
    "12:00", "12:30", "13:00", "13:30", "14:00", "14:30"
  ];

  Future<void> _bookAppointment() async {
    if (_selectedEmployee == null || _selectedService == null ||
        _dateController.text.isEmpty || _selectedTime == null ||
        _emailController.text.isEmpty) {
      _showMessage("Lütfen tüm alanları doldurun.");
      return;
    }

    DateTime selectedDateTime = DateFormat("yyyy-MM-dd HH:mm").parse(
        "${_dateController.text} $_selectedTime");

    DateTime adjustedDateTime = selectedDateTime.subtract(Duration(hours: 3));

    String finalDateTime = adjustedDateTime.toIso8601String(); // UTC'ye gönderilecek hali

    final Map<String, dynamic> appointment = {
      "service": _selectedService,
      "employee": _selectedEmployee,
      "date": finalDateTime, // 3 saat geriye alınmış saat
      "userEmail": _emailController.text
    };


    try {
      final response = await http.post(
        Uri.parse("http://192.168.1.35:5062/api/appointments/create"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(appointment),
      );

      if (response.statusCode == 200) {
        _showMessage("Randevunuz başarıyla oluşturuldu!");
      } else {
        _showMessage("Randevu oluşturulamadı. Lütfen tekrar deneyin.");
      }
    } catch (error) {
      _showMessage("Bağlantı hatası. Lütfen internet bağlantınızı kontrol edin.");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Randevu Al"),
        backgroundColor: Color(0xFF8E44AD),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedEmployee,
              decoration: InputDecoration(labelText: "Çalışan Seçin"),
              items: servicesByEmployee.keys.map((String employee) {
                return DropdownMenuItem<String>(
                  value: employee,
                  child: Text(employee),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedEmployee = value;
                  _selectedService = null;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedService,
              decoration: InputDecoration(labelText: "Hizmet Seçin"),
              items: (servicesByEmployee[_selectedEmployee] ?? []) // Eğer null ise boş liste döndür
                  .map((String service) {
                return DropdownMenuItem<String>(
                  value: service,
                  child: Text(service),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedService = value;
                });
              },
            ),

            TextField(
              controller: _dateController,
              decoration: InputDecoration(labelText: "Tarih Seçin"),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    _dateController.text = DateFormat("yyyy-MM-dd").format(pickedDate);
                  });
                }
              },
            ),
            Wrap(
              spacing: 10,
              children: availableTimes.map((time) {
                return ChoiceChip(
                  label: Text(time),
                  selected: _selectedTime == time,
                  onSelected: (selected) {
                    setState(() {
                      _selectedTime = selected ? time : null;
                    });
                  },
                );
              }).toList(),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: "E-posta"),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _bookAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8E44AD),
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: Text("Randevu Al"),
            ),
          ],
        ),
      ),
    );
  }
}
