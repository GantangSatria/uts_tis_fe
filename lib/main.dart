import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

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

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    try {
      print('Fetching tickets from server...');
      final soapEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://example.com/ticket">
  <soapenv:Header/>
  <soapenv:Body>
    <tic:GetTicketsRequest/>
  </soapenv:Body>
</soapenv:Envelope>
''';

      final response = await http.post(
        Uri.parse('http://192.168.1.11:3000/wsdl'), // Ganti dengan IP server Anda
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://example.com/ticket/GetTicket',
        },
        body: soapEnvelope,
      );

      print('GetTickets response status: ${response.statusCode}');
      print('GetTickets response body: ${response.body}');

      if (response.statusCode == 200) {
        final ticketList = parseTicketsXml(response.body);
        print('Parsed tickets: $ticketList');

        setState(() {
          tickets = ticketList;
        });

        print('Updated tickets state: $tickets');
      } else {
        print('Failed to load tickets: ${response.statusCode}');
        setState(() {
          tickets = [
            {"kereta": "Agung Joyo", "penumpang": "Mr. Satria", "waktu": "2025-04-23"},
            {"kereta": "[Dummy] Argo Bromo", "penumpang": "Ms. Maya", "waktu": "2025-04-24"},
          ];
        });
      }
    } catch (e) {
      print('Error fetching tickets: $e');
      setState(() {
        tickets = [
          {"kereta": "Agung Joyo", "penumpang": "Mr. Satria", "waktu": "2025-04-23"},
          {"kereta": "[Error] Argo Bromo", "penumpang": "Ms. Maya", "waktu": "2025-04-24"},
        ];
      });
    }
  }

  List<Map<String, String>> parseTicketsXml(String xmlString) {
    List<Map<String, String>> result = [];

    print('Parsing XML response...');

    try {
      // Coba mencari pola ticket dengan namespace tns
      RegExp ticketRegex = RegExp(r'<(?:tns:)?ticket>.*?<\/(?:tns:)?ticket>', dotAll: true);
      Iterable<RegExpMatch> ticketMatches = ticketRegex.allMatches(xmlString);

      print('Found ${ticketMatches.length} ticket entries');

      for (var match in ticketMatches) {
        String ticketXml = match.group(0) ?? '';

        // Coba berbagai variasi namespace
        String? name = extractXmlValue(ticketXml, 'name');
        String? train = extractXmlValue(ticketXml, 'train');
        String? date = extractXmlValue(ticketXml, 'date');

        print('Extracted ticket data: name=$name, train=$train, date=$date');

        if (name != null && train != null && date != null) {
          result.add({
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
      body: ListView.builder(
        padding: const EdgeInsets.only(top: 40, left: 16, right: 16),
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
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

  Future<void> sendTicketToSoap(String name, String train, String date) async {
    try {
      final soapEnvelope = '''
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tic="http://example.com/ticket">
  <soapenv:Header/>
  <soapenv:Body>
    <tic:AddTicketRequest>
      <tic:ticket>
        <tic:name>$name</tic:name>
        <tic:train>$train</tic:train>
        <tic:date>$date</tic:date>
      </tic:ticket>
    </tic:AddTicketRequest>
  </soapenv:Body>
</soapenv:Envelope>
''';

      // Print the request for debugging
      print('Sending SOAP request:');
      print(soapEnvelope);

      final response = await http.post(
        Uri.parse('http://192.168.1.11:3000/wsdl'),
        headers: {
          'Content-Type': 'text/xml; charset=utf-8',
          'SOAPAction': 'http://example.com/ticket/AddTicket',
        },
        body: soapEnvelope,
      );

      // Print the complete response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body:');
      print(response.body);

      if (response.statusCode == 200) {
        if (response.body.contains('success') ||
            response.body.toLowerCase().contains('success')) {
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
      } else {
        print('Gagal: ${response.statusCode}');
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan tiket: ${response.statusCode}')),
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
                      await sendTicketToSoap(name, train, date);
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

