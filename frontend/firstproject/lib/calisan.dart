import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EmployeeScreen(),
    );
  }
}

class EmployeeScreen extends StatelessWidget {
  final List<Map<String, String>> employees = [
    {
      'name': 'Samir Bey',
      'services': 'Cilt Bakımı, Masaj',
      'description':
      'Samir Bey, yılların verdiği tecrübeyle cilt bakımında derinlemesine analiz yaparak, cildin ihtiyacına göre kişiye özel bakım uygulamaktadır. Aynı zamanda, masaj teknikleriyle vücudunuzu rahatlatır ve stresinizi azaltarak kendinizi yenilenmiş hissetmenizi sağlar.'
    },
    {
      'name': 'Esranur Hanım',
      'services': 'Saç Bakımı, Cilt Bakımı',
      'description':
      'Esranur Hanım, saç bakımında ve cilt bakımında derinlemesine bilgiye sahip olup, her türlü saç tipi ve cilt yapısına göre profesyonel çözümler sunmaktadır. Yüzeysel değil, kapsamlı bakım yaparak, doğal güzelliğinizi ortaya çıkarır ve sağlıklı bir görünüm kazanmanıza yardımcı olur.'
    },
    {
      'name': 'İnci Hanım',
      'services': 'Masaj, Saç Bakımı',
      'description':
      'İnci Hanım, rahatlatıcı masaj teknikleri ile vücudunuzu dinlendirirken, aynı zamanda saç bakımında da uzmandır. Saç tipinizi analiz ederek uygun bakım ürünlerini seçer ve saçı besleyerek sağlıklı uzamasını sağlar. Hem fiziksel hem de ruhsal olarak kendinizi yenilenmiş hissedebilirsiniz.'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE6F7FF),
      appBar: AppBar(
        backgroundColor: Color(0xFFA6D0FF),
        title: Text('Çalışanlarımız', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            return EmployeeCard(
              name: employees[index]['name']!,
              services: employees[index]['services']!,
              description: employees[index]['description']!,
            );
          },
        ),
      ),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final String name;
  final String services;
  final String description;

  EmployeeCard({
    required this.name,
    required this.services,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFE6F7FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border(left: BorderSide(color: Color(0xFFA6D0FF), width: 5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4FA3D1),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Yaptığı Hizmetler: $services',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}