import 'package:http/http.dart' as http;

class SoapService {
  final String endpoint = 'http://localhost:3000/wsdl'; //perlu diganti

  //endpoint call buat get nya
  Future<String> getTickets() async {
    final body = '''
    <?xml version="1.0"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                      xmlns:tns="http://example.com/ticket">
      <soapenv:Header/>
      <soapenv:Body>
        <tns:GetTicketsRequest/>
      </soapenv:Body>
    </soapenv:Envelope>
    ''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'text/xml',
        'SOAPAction': 'http://example.com/ticket/GetTickets',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error fetching tickets');
    }
  }

  //endpoint call buat add nya
  Future<String> addTicket({
    required String name,
    required String train,
    required String date, //format YYYY-MM-DD
  }) async {
    final soapEnvelope = '''
    <?xml version="1.0" encoding="utf-8"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                      xmlns:tns="http://example.com/ticket">
       <soapenv:Header/>
       <soapenv:Body>
          <tns:AddTicketRequest>
             <tns:ticket>
                <tns:name>$name</tns:name>
                <tns:train>$train</tns:train>
                <tns:date>$date</tns:date>
             </tns:ticket>
          </tns:AddTicketRequest>
       </soapenv:Body>
    </soapenv:Envelope>
    ''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://example.com/ticket/AddTicket',
      },
      body: soapEnvelope,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('SOAP Error: ${response.statusCode} - ${response.body}');
    }
  }

  //endpoint call buat update nya
  Future<String> updateTicket({
    required String id,
    required String name,
    required String train,
    required String date,
  }) async {
    final body = '''
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                      xmlns:tns="http://example.com/ticket">
      <soapenv:Header/>
      <soapenv:Body>
        <tns:UpdateTicketRequest>
          <tns:ticket>
            <tns:id>$id</tns:id>
            <tns:name>$name</tns:name>
            <tns:train>$train</tns:train>
            <tns:date>$date</tns:date>
          </tns:ticket>
        </tns:UpdateTicketRequest>
      </soapenv:Body>
    </soapenv:Envelope>
    ''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'text/xml',
        'SOAPAction': 'http://example.com/ticket/UpdateTicket',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error updating ticket');
    }
  }

  //endpoint call buat delete nya
  Future<String> deleteTicket(String id) async {
    final body = '''
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                      xmlns:tns="http://example.com/ticket">
      <soapenv:Header/>
      <soapenv:Body>
        <tns:DeleteTicketRequest>
          <tns:id>$id</tns:id>
        </tns:DeleteTicketRequest>
      </soapenv:Body>
    </soapenv:Envelope>
    ''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'text/xml',
        'SOAPAction': 'http://example.com/ticket/DeleteTicket',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error deleting ticket');
    }
  }
}
