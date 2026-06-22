import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();

  // Register
  final regReq = await client.postUrl(Uri.parse('http://localhost:5024/api/auth/register'));
  regReq.headers.set('Content-Type', 'application/json');
  regReq.write(jsonEncode({"email": "test4@test.com", "password": "Password123!", "name": "Test User"}));
  final regRes = await regReq.close();
  final regBody = await regRes.transform(utf8.decoder).join();
  print('Register Status: ${regRes.statusCode}, Body: $regBody');
  
  // Login
  final loginReq = await client.postUrl(Uri.parse('http://localhost:5024/api/auth/login'));
  loginReq.headers.set('Content-Type', 'application/json');
  loginReq.write(jsonEncode({"email": "test4@test.com", "password": "Password123!"}));
  final loginRes = await loginReq.close();
  final loginBody = await loginRes.transform(utf8.decoder).join();
  
  if (loginRes.statusCode != 200) {
    print("Login failed: $loginBody");
    client.close();
    return;
  }

  final token = jsonDecode(loginBody)['token'];

  // Put
  final body = {
    "categoryId": "11111111-1111-1111-1111-111111111111", 
    "title": "Test",
    "description": "",
    "amount": 10.0,
    "expenseDate": "2026-06-22",
    "imagesToAdd": ["http://localhost:5024/uploads/fake.jpg"],
    "imagesToRemove": []
  };

  final request = await client.putUrl(Uri.parse('http://localhost:5024/api/expenses/9b3440f9-3e83-41c2-aaed-b29aef8720e0'));
  request.headers.set('Content-Type', 'application/json');
  request.headers.set('Authorization', 'Bearer $token');
  request.write(jsonEncode(body));
  
  final response = await request.close();
  final resBody = await response.transform(utf8.decoder).join();
  
  print('PUT Status: ${response.statusCode}');
  print('PUT Body: $resBody');
  client.close();
}
