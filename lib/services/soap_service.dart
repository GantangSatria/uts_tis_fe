import 'package:http/http.dart' as http;

class SoapService {
  // Updated to match the endpoint used in main.dart
  final String endpoint = 'http://192.168.1.11:3000/wsdl';

  Future<String> getTickets() async {
    final body = '''
    <?xml version="1.0"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                      xmlns:tic="http://example.com/ticket">
      <soapenv:Header/>
      <soapenv:Body>
        <tic:GetTicketsRequest/>
      </soapenv:Body>
    </soapenv:Envelope>
    ''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://example.com/ticket/GetTicket', // Updated to match main.dart
      },
      body: body,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error fetching tickets: ${response.statusCode}');
    }
  }

  Future<String> addTicket({
    required String name,
    required String train,
    required String date, //format YYYY-MM-DD
  }) async {
    final soapEnvelope = '''
    <?xml version="1.0" encoding="utf-8"?>
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                      xmlns:tic="http://example.com/ticket">
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

  Future<String> updateTicket({
    required String id,
    required String name,
    required String train,
    required String date,
  }) async {
    final body = '''
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                      xmlns:tic="http://example.com/ticket">
      <soapenv:Header/>
      <soapenv:Body>
        <tic:UpdateTicketRequest>
          <tic:ticket>
            <tic:id>$id</tic:id>
            <tic:name>$name</tic:name>
            <tic:train>$train</tic:train>
            <tic:date>$date</tic:date>
          </tic:ticket>
        </tic:UpdateTicketRequest>
      </soapenv:Body>
    </soapenv:Envelope>
    ''';

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
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

  Future<String> deleteTicket(String id) async {
    final body = '''
  <?xml version="1.0" encoding="utf-8"?>
  <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
                    xmlns:tic="http://example.com/ticket">
    <soapenv:Header/>
    <soapenv:Body>
      <tic:DeleteTicketRequest>
        <tic:ticket>
          <tic:id>$id</tic:id>
        </tic:ticket>
      </tic:DeleteTicketRequest>
    </soapenv:Body>
  </soapenv:Envelope>
  ''';

    print('Sending DeleteTicket request for ID: $id');
    print('Request body: $body');

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Content-Type': 'text/xml; charset=utf-8',
        'SOAPAction': 'http://example.com/ticket/DeleteTicket',
      },
      body: body,
    );

    print('DeleteTicket response status: ${response.statusCode}');
    print('DeleteTicket response body: ${response.body}');

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error deleting ticket: ${response.statusCode} - ${response.body}');
    }
  }
}