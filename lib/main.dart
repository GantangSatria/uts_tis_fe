import 'package:flutter/material.dart';
import 'services/soap_service.dart';

void main() {
  runApp(MaterialApp(home: DashboardPage(), debugShowCheckedModeBanner: false));
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<Map<String, String>> tickets = [];
  final SoapService soapService = SoapService();

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      print('Fetching tickets from server...');
      final response = await soapService.getTickets();
      print('GetTickets response: $response');

      final ticketList = parseTicketsXml(response);
      print('Parsed tickets: $ticketList');

      setState(() {
        tickets = ticketList;
      });

      print('Updated tickets state: $tickets');
    } catch (e) {
      print('Error fetching tickets: $e');
      setState(() {
        tickets = [
          {"id": "1", "kereta": "Agung Joyo", "penumpang": "Mr. Satria", "waktu": "2025-04-23"},
          {"id": "2", "kereta": "[Error] Argo Bromo", "penumpang": "Ms. Maya", "waktu": "2025-04-24"},
        ];
      });
    }
  }

  List<Map<String, String>> parseTicketsXml(String xmlString) {
    List<Map<String, String>> result = [];

    print('Parsing XML response...');

    try {
      // Coba mencari pola ticket dengan namespace tns atau tic
      RegExp ticketRegex = RegExp(r'<(?:tns:|tic:)?ticket>.*?<\/(?:tns:|tic:)?ticket>', dotAll: true);
      Iterable<RegExpMatch> ticketMatches = ticketRegex.allMatches(xmlString);

      print('Found ${ticketMatches.length} ticket entries');

      for (var match in ticketMatches) {
        String ticketXml = match.group(0) ?? '';

        // Coba berbagai variasi namespace
        String? id = extractXmlValue(ticketXml, 'id');
        String? name = extractXmlValue(ticketXml, 'name');
        String? train = extractXmlValue(ticketXml, 'train');
        String? date = extractXmlValue(ticketXml, 'date');

        print('Extracted ticket data: id=$id, name=$name, train=$train, date=$date');

        // Pastikan id ada, kalau tidak buat temporary ID
        final ticketId = id ?? DateTime.now().millisecondsSinceEpoch.toString();

        if (name != null && train != null && date != null) {
          result.add({
            "id": ticketId,
            "penumpang": name,
            "kereta": train,
            "waktu": date,
          });
        }
      }
    } catch (e) {
      print('Error during XML parsing: $e');
    }

    return result;
  }

  String? extractXmlValue(String xml, String tagName) {
    final regexPatterns = [
      '<$tagName>(.*?)</$tagName>',
      '<[^:]+:$tagName>(.*?)</[^:]+:$tagName>',
    ];

    for (var pattern in regexPatterns) {
      RegExp regex = RegExp(pattern);
      final match = regex.firstMatch(xml);
      if (match != null && match.groupCount >= 1) {
        return match.group(1);
      }
    }

    return null;
  }

  void openInputPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InputDataPage()),
    );
    await Future.delayed(Duration(milliseconds: 300));
    await fetchTickets();
  }

  Future<void> deleteTicket(String id) async {
    try {
      // Show confirmation dialog
      bool confirm = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin ingin menghapus tiket ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Hapus'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ) ?? false;

      if (!confirm) return;

      // Call SOAP service to delete the ticket
      await soapService.deleteTicket(id);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tiket berhasil dihapus')),
      );

      // Refresh ticket list
      await fetchTickets();
    } catch (e) {
      print('Error deleting ticket: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus tiket: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(167),
        child: AppBar(
          title: Text("Dashboard", style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B00CC), Color(0xFFCF66FF)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          centerTitle: true,
        ),
      ),
      body: tickets.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.train_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Tidak ada tiket', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Dismissible(
              key: Key(ticket["id"] ?? index.toString()),
              background: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                if (ticket["id"] != null) {
                  await deleteTicket(ticket["id"]!);
                }
                return false; // Let our delete function handle the UI updates
              },
              child: ListTile(
                contentPadding: EdgeInsets.all(12),
                leading: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B00CC), Color(0xFFCF66FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.train, color: Colors.white, size: 40),
                ),
                title: Text(ticket["kereta"]!, style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket["penumpang"]!),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 4),
                        Text(ticket["waktu"]!, style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    if (ticket["id"] != null) {
                      deleteTicket(ticket["id"]!);
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openInputPage,
        backgroundColor: Color(0xFF8B00CC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class InputDataPage extends StatefulWidget {
  @override
  _InputDataPageState createState() => _InputDataPageState();
}

class _InputDataPageState extends State<InputDataPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController keretaController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();
  final SoapService soapService = SoapService();

  Future<void> sendTicket() async {
    try {
      String name = nameController.text;
      String train = keretaController.text;
      String date = tanggalController.text;

      // Print the request for debugging
      print('Sending ticket with name: $name, train: $train, date: $date');

      final response = await soapService.addTicket(
        name: name,
        train: train,
        date: date,
      );

      // Print the complete response for debugging
      print('Response body:');
      print(response);

      if (response.contains('success') ||
          response.toLowerCase().contains('success')) {
        print('Ticket berhasil dikirim!');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tiket berhasil ditambahkan')),
        );
      } else {
        print('Response format may not be what we expected, but request was sent');
        // You might want to consider it a success if the status code is 200
        // even if we don't find the explicit "success" text
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tiket dikirim, tetapi respons tidak sesuai format yang diharapkan')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

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
            Text('Nama Lengkap', style: TextStyle(fontSize: 16)),
            SizedBox(height: 11),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                hintText: 'Masukkan nama lengkap',
              ),
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
            ),
            SizedBox(height: 16),
            Text('Tanggal', style: TextStyle(fontSize: 16)),
            SizedBox(height: 11),
            TextField(
              controller: tanggalController,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Pilih tanggal',
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  tanggalController.text = "${pickedDate.toLocal()}".split(' ')[0];
                }
              },
            ),
            SizedBox(height: 175),
            Center(
              child: Container(
                height: 50,
                width: 700,
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: ElevatedButton(
                  onPressed: () async {
                    String name = nameController.text;
                    String train = keretaController.text;
                    String date = tanggalController.text;

                    if (name.isNotEmpty && train.isNotEmpty && date.isNotEmpty) {
                      await sendTicket();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Semua field harus diisi')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B00CC),
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