import 'package:flutter/material.dart';
import 'data/datasources/mock_user_remote_data_source.dart';
import 'data/repositories/user_repository_impl.dart';
import 'presentation/controllers/user_controller.dart';
import 'presentation/screens/user_list_screen.dart';

final userController = UserController(
  UserRepositoryImpl(MockUserRemoteDataSource()),
);

void main() {
  runApp(const UserManagementApp());
}

class UserManagementApp extends StatelessWidget {
  const UserManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PureBind Clean Architecture Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: UserListScreen(controller: userController),
    );
  }
}
