import 'package:flutter/material.dart';
import 'package:purebind/purebind.dart';
import '../../domain/entities/user.dart';
import '../controllers/user_controller.dart';
import '../widgets/add_edit_user_dialog.dart';

class UserListScreen extends StatelessWidget {
  final UserController controller;

  const UserListScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management (Clean Architecture)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadUsers(),
            tooltip: 'Reload Data',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Summary Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => controller.searchQuery.value = val,
                  decoration: InputDecoration(
                    labelText: 'Search Users',
                    hintText: 'Search by name, email, or role',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: PureBuilder<String>(
                      pure: controller.searchQuery,
                      builder: (context, query) {
                        if (query.isEmpty) return const SizedBox.shrink();
                        return IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => controller.searchQuery.value = '',
                        );
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PureBuilder<int>(
                      pure: controller.userCount,
                      builder: (context, count) {
                        return Text(
                          'Showing $count user(s)',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // User List View
          Expanded(
            child: PureBuilder<bool>(
              pure: controller.isLoading,
              builder: (context, loading) {
                if (loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return PureBuilder<String?>(
                  pure: controller.errorMessage,
                  builder: (context, error) {
                    if (error != null) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Error loading users: $error'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => controller.loadUsers(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    return PureBuilder<List<User>>(
                      pure: controller.filteredUsers,
                      builder: (context, users) {
                        if (users.isEmpty) {
                          return const Center(
                            child: Text(
                              'No users found.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        return ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(user.name.substring(0, 1)),
                              ),
                              title: Text(
                                user.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text('${user.role} • ${user.email}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => showAddEditUserDialog(
                                      context,
                                      controller,
                                      user: user,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () =>
                                        controller.deleteUser(user.id),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEditUserDialog(context, controller),
        icon: const Icon(Icons.person_add),
        label: const Text('Add User'),
      ),
    );
  }
}
