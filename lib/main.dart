import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(home: DashboardPage(), debugShowCheckedModeBanner: false));
}

class DashboardPage extends StatelessWidget {
  final List<Map<String, String>> tickets = List.generate(
    3,
    (index) => {
      "kereta": "Agung Joyo",
      "penumpang": "Mr. Satria",
      "waktu": "Waktu",
    },
  );

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      // drawer: Drawer(), // Bisa diisi drawer sesuai kebutuhan
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(167),
        child: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
          title: Text(
            "Dashboard",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
         
        
          centerTitle: true,
          flexibleSpace: Stack(
            children: [
              // Gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.25, 1.0],
                    colors: [Color(0xFF8B00CC), Color(0xFFCF66FF)],
                  ),
                ),
              ),

              // Kotak putih
              // Positioned(
              //   bottom: 0, // Setengah keluar dari AppBar
              //   left: 0,
              //   right: 0,
              //   child: Center(
              //     child: Container(
              //       width: 300,
              //       padding: const EdgeInsets.all(20),
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(10),
              //         boxShadow: [
              //           BoxShadow(color: Colors.black12, blurRadius: 4),
              //         ],
              //       ),
              //       child: Column(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Text(
              //             "3",
              //             style: TextStyle(
              //               fontSize: 24,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //           SizedBox(height: 4),
              //           Text("Total tiket", style: TextStyle(fontSize: 12)),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          Column(
            children: [
              Container(),
              Expanded(
                child: Container(
                  color: const Color.fromARGB(
                    255,
                    255,
                    255,
                    255,
                  ), // Warna merah
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      top: 40,
                      left: 16,
                      right: 16,
                    ), // Padding atas diberi jarak karena kotak putih
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SizedBox(
                          child: ListTile(
                            leading: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF8B00CC), // Warna pertama
                                    Color(0xFFCF66FF), // Warna kedua
                                  ],
                                  begin:
                                      Alignment.topLeft, // Titik awal gradient
                                  end:
                                      Alignment
                                          .bottomRight, // Titik akhir gradient
                                  stops: [0.0, 1.0], // Komposisi warna
                                ),
                                borderRadius: BorderRadius.circular(
                                  8,
                                ), // Ubah ke 0 kalau mau benar-benar kotak
                              ),

                              child: Icon(
                                Icons.train,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            title: Text(ticket["kereta"]!),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ticket["penumpang"]!),
                                Row(
                                  children: [
                                    Icon(Icons.access_time, size: 24),
                                    SizedBox(width: 4),
                                    Text(ticket["waktu"]!),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    // aksi edit
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    // aksi hapus
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          // Positioned(
          //   top:
          //       50, // Posisi vertikal kotak putih agar setengah masuk ke bagian ungu
          //   left: 0,
          //   right: 0,
          //   child: Center(
          //     child: Container(
          //       padding: const EdgeInsets.all(20),
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(10),
          //         boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          //       ),
          //       child: Column(
          //         mainAxisSize: MainAxisSize.min,
          //         children: [
          //           Text(
          //             "3",
          //             style: TextStyle(
          //               fontSize: 24,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //           SizedBox(height: 4),
          //           Text("Total tiket", style: TextStyle(fontSize: 12)),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InputDataPage()),
          );
        },
        backgroundColor: Color(0xFF8B00CC),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            50,
          ), // Ubah angkanya sesuai kebutuhan
        ),

        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class InputDataPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController keretaController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambah Tiket',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nama Lengkap',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 11),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                hintText: 'Masukkan nama lengkap',
              ),
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 16),
            Text('Nama Kereta', style: TextStyle(fontSize: 16)),
            SizedBox(height: 11),
            TextField(
              controller: keretaController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan nama kereta',
              ),
              keyboardType: TextInputType.name,
            ),
            SizedBox(height: 16),
            Text('Tanggal:', style: TextStyle(fontSize: 16)),
            SizedBox(height: 11),
            TextField(
              controller: tanggalController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan nama kereta',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 175),
            Center(
              child: Container(
                height: 50,
                width: 700, // Mengatur lebar tombol
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton(
                  onPressed: () {
                    // Logika untuk menyimpan data
                    String name = nameController.text;
                    String email =
                        keretaController
                            .text; // Pastikan ini sesuai dengan controller yang benar
                    String phone =
                        tanggalController
                            .text; // Pastikan ini sesuai dengan controller yang benar

                    // Tampilkan data atau simpan ke database
                    print('Nama: $name, Email: $email, Telepon: $phone');

                    // Logika untuk menyimpan data ke database bisa ditambahkan di sini

                    // Kembali ke halaman dashboard
                    Navigator.pop(context); // Kembali ke halaman sebelumnya
                    // Jika Anda ingin mengganti halaman, gunakan Navigator.pushReplacement
                    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardPage()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B00CC), // Warna tombol
                  ),
                  child: Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
