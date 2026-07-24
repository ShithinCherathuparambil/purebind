import 'dart:convert';
import '../../domain/entities/user.dart';

class MockUserRemoteDataSource {
  static const String _dummyJsonData = '''
  [
    {"id": "101", "name": "Alice Johnson", "email": "alice@example.com", "role": "Developer"},
    {"id": "102", "name": "Bob Smith", "email": "bob@example.com", "role": "Designer"},
    {"id": "103", "name": "Charlie Brown", "email": "charlie@example.com", "role": "Product Manager"},
    {"id": "104", "name": "Diana Prince", "email": "diana@example.com", "role": "QA Engineer"}
  ]
  ''';

  Future<List<User>> getUsersFromApi() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));
    final List<dynamic> parsedJson = jsonDecode(_dummyJsonData);
    return parsedJson
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
