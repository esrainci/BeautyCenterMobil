import 'package:flutter/material.dart';
import 'calisan.dart';
import 'randevu.dart';
import 'profile.dart';
import 'yorum_sistemi.dart';

void main() => runApp(HomeScreen());

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Global key to control the scaffold state (for opening drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Set the scaffold key here
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            // Open drawer using the scaffold key
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        title: Row(
          children: [
            Image.network('https://i.imgur.com/hzMfMET.png', width: 180, height: 40, fit: BoxFit.cover),
          ],
        ),
        actions: [],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF5FA8A8), // Koyu Pastel Cyan HEX kodu
                borderRadius: BorderRadius.circular(10),
              ),

              child: Text('Menü', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              title: Text('Anasayfa'),
              onTap: () {
                Navigator.pop(context); // Menü kapanacak
              },
            ),
            ListTile(
              title: Text('Randevu'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RandevuScreen()), // Çalışanlar sayfasına git
                );
              },
            ),
            ListTile(
              title: Text('Çalışanlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmployeeScreen()), // Çalışanlar sayfasına git
                );
              },
            ),

            ListTile(
              title: Text('Profilim'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()), // Çalışanlar sayfasına git
                );
              },
            ),
            ListTile(
              title: Text('Yorumlar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => YorumSistemiPage()), // Çalışanlar sayfasına git
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage('https://images.pexels.com/photos/6724402/pexels-photo-6724402.jpeg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color.fromRGBO(0, 0, 0, 0.5), // RGBO kullanarak opaklık ayarlama
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('En İyi Güzellik Hizmetleri Burada', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold)),
                    Text('Sağlıklı cilt, güzel saçlar ve rahatlatıcı masajlar için doğru adrestesiniz.', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              ),
            ),

            // Hizmetler Section
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ServiceCard(
                    title: 'Cilt Bakımı',
                    imageUrl: 'https://www.dermafix.co.za/wp-content/uploads/2016/05/Best-skin-care-advice-from-the-professionals.jpg',
                    description: 'Özel cilt bakımı seçeneklerimizle cildinizi tazeleyin ve yenileyin.',
                    onPressed: () {},
                  ),
                  ServiceCard(
                    title: 'Masaj Terapisi',
                    imageUrl: 'https://www.drnilgunestetik.com/images/tum-vucut-masaj.jpg',
                    description: 'Masaj terapisi, vücudunuzu rahatlatır ve stresinizi azaltır.',
                    onPressed: () {},
                  ),
                  ServiceCard(
                    title: 'Saç Bakımı',
                    imageUrl: 'https://cdn.shopify.com/s/files/1/0520/4983/8237/files/monthly_hair_care_maintenance.webp?v=1706626977',
                    description: 'Saçlarınızın sağlığını koruyun ve güzel görünmesini sağlayın.',
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // Saç Maskesi İçeriği
            Container(
              padding: EdgeInsets.all(20),
              color: Color(0xFFE3F7FB),
              child: Row(
                children: [
                  Image.network(
                    'https://cdn.dsmcdn.com/mrktng/seo/tyblog/1/avokado-sac-maskesi-3.jpg',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Saçlarınız İçin Avokado Maskesi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1D6B7B))),
                          SizedBox(height: 10),
                          Text(
                            'Avokado, içerdiği sağlıklı yağlar ve vitaminler sayesinde saçlarınızı besler ve nemlendirir. Saç maskesi olarak kullanmak için bir avokadoyu ezip, içerisine birkaç damla zeytinyağı ve bal ekleyin. Karışımı saç uçlarınıza uygulayıp 20-30 dakika beklettikten sonra ılık suyla durulayın.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Sıkça Sorulan Sorular
            Container(
              padding: EdgeInsets.all(20),
              color: Color(0xFFF1F1F1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sıkça Sorulan Sorular', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1D6B7B))),
                  SizedBox(height: 10),
                  FAQItem(question: 'Cilt bakımı nasıl yapılır?', answer: 'Cilt bakımı, cilt tipinize uygun ürünlerle yapılmalıdır. Uzmanlarımızdan yardım alabilirsiniz.'),
                  FAQItem(question: 'Masaj terapisi ne kadar sürer?', answer: 'Masaj terapisi genellikle 30 dakika ile 1 saat arasında değişir. İhtiyacınıza göre öneri alabilirsiniz.'),
                  FAQItem(question: 'Saç bakımı fiyatları nedir?', answer: 'Saç bakımı fiyatlarımız hizmete göre değişiklik göstermektedir. Detaylı bilgi için bizimle iletişime geçebilirsiniz.'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('İnci Güzellik Merkezi - Tüm hakları saklıdır', style: TextStyle(fontSize: 14, color: Colors.black)),
              SizedBox(height: 5),
              Text('Adres: 123 Bahçelievler, Ankara, Türkiye', style: TextStyle(fontSize: 12, color: Colors.black)),
              Text('Telefon: +90 555 555 55 55', style: TextStyle(fontSize: 12, color: Colors.black)),
              Text('Email: info@inciguzellik.com', style: TextStyle(fontSize: 12, color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String description;
  final VoidCallback onPressed;

  ServiceCard({required this.title, required this.imageUrl, required this.description, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 100,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Text(description, style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7BB9C0)),
                onPressed: onPressed,
                child: Text('Randevu Al', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text(answer, style: TextStyle(fontSize: 14, color: Colors.grey)),
        Divider(),
      ],
    );
  }
}