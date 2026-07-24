import 'package:flutter/material.dart';
import '../../domain/entities/user.dart';
import '../controllers/user_controller.dart';

void showAddEditUserDialog(
  BuildContext context,
  UserController controller, {
  User? user,
}) {
  final isEditing = user != null;
  final nameController = TextEditingController(text: user?.name ?? '');
  final emailController = TextEditingController(text: user?.email ?? '');
  final roleController = TextEditingController(text: user?.role ?? '');

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isEditing ? 'Edit User' : 'Add New User'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                if (isEditing) {
                  controller.updateUser(
                    user.copyWith(
                      name: nameController.text,
                      email: emailController.text,
                      role: roleController.text,
                    ),
                  );
                } else {
                  final newUser = User(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    name: nameController.text,
                    email: emailController.text,
                    role: roleController.text.isEmpty
                        ? 'Member'
                        : roleController.text,
                  );
                  controller.addUser(newUser);
                }
                Navigator.pop(context);
              }
            },
            child: Text(isEditing ? 'Save' : 'Add'),
          ),
        ],
      );
    },
  );
}
