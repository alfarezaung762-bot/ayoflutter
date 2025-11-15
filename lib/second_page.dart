import 'package:flutter/material.dart';
import 'status_bar.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== STATUS BAR =====
                const CustomStatusBar(),

                SizedBox(height: 10),

                // ===== SEARCH BAR + PROFILE =====
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Cari Nama Pekerjaan",
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 10),

                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(
                        "https://i.pravatar.cc/300",
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // =======================
                // KATEGORI ICONS
                // =======================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    kategoriItem(Icons.public, "IT"),
                    kategoriItem(Icons.folder_shared, "ADMIN"),
                    kategoriItem(Icons.mic, "Marketing"),
                    kategoriItem(Icons.group, "Freelance"),
                  ],
                ),

                SizedBox(height: 30),

                // =======================
                // SEDANG POPULER
                // =======================
                Text(
                  "Sedang Populer",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 15),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    populerCard(
                      image:
                          "https://upload.wikimedia.org/wikipedia/commons/4/45/Starbucks_Coffee_Logo.svg",
                      title: "BEARBUCKS",
                      job: "Assisten Barista",
                      lokasi: "Jakarta Tengah",
                    ),
                    populerCard(
                      image:
                          "https://upload.wikimedia.org/wikipedia/commons/9/95/Instagram_logo_2022.svg",
                      title: "INSTAGRAM",
                      job: "Video Editing",
                      lokasi: "Bandung",
                    ),
                    populerCard(
                      image:
                          "https://upload.wikimedia.org/wikipedia/commons/8/88/J%26T_Express_logo.svg",
                      title: "J&E",
                      job: "Logistik Barang",
                      lokasi: "Jakarta Timur",
                    ),
                  ],
                ),

                SizedBox(height: 30),

                // =======================
                // Rekomendasi
                // =======================
                Text(
                  "Rekomendasi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                SizedBox(height: 10),

                rekomendasiItem(
                  image:
                      "https://cdn-icons-png.flaticon.com/512/733/733579.png",
                  title: "PETUGAS KEBERSIHAN",
                  perusahaan: "PT MITRA MAKMUR JAYA",
                  lokasi: "Jakarta",
                  gaji: "IDR 400.000 - 700.000 / DAY",
                ),

                rekomendasiItem(
                  image:
                      "https://cdn-icons-png.flaticon.com/512/281/281769.png",
                  title: "PELAYAN RESTORAN",
                  perusahaan: "PT AYAM BERNYANYI",
                  lokasi: "Medan",
                  gaji: "IDR 1.000.000 / WEEK",
                ),

                rekomendasiItem(
                  image: "https://cdn-icons-png.flaticon.com/512/25/25231.png",
                  title: "UI/UX DESIGNER",
                  perusahaan: "PT SIDO DESIGN",
                  lokasi: "Solo",
                  gaji: "IDR 4.000.000 - 9.000.000 / MONTH",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ====================================================================
  //  Widget Kategori
  // ====================================================================
  Widget kategoriItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 28, color: Colors.blueAccent),
        ),
        SizedBox(height: 6),
        Text(title),
      ],
    );
  }

  // ====================================================================
  // Card Sedang Populer
  // ====================================================================
  Widget populerCard({
    required String image,
    required String title,
    required String job,
    required String lokasi,
  }) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Image.network(image, height: 40),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          Text(
            job,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(lokasi, style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  // ====================================================================
  // List Item Rekomendasi
  // ====================================================================
  Widget rekomendasiItem({
    required String image,
    required String title,
    required String perusahaan,
    required String lokasi,
    required String gaji,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15),
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(blurRadius: 10, spreadRadius: 1, color: Colors.black12),
        ],
      ),
      child: Row(
        children: [
          Image.network(image, height: 50),
          SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(perusahaan),
                Text(lokasi),
                Text(
                  gaji,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          Icon(Icons.share, color: Colors.blue),
        ],
      ),
    );
  }
}
