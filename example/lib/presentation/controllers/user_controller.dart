import 'package:purebind/purebind.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';

class UserController {
  final UserRepository repository;

  UserController(this.repository) {
    loadUsers();
  }

  // Reactive State Signals
  final users = Pure<List<User>>([]);
  final isLoading = Pure<bool>(true);
  final errorMessage = Pure<String?>(null);
  final searchQuery = Pure<String>('');

  // Computed Signal: Filter users automatically based on search query
  late final filteredUsers = Pure<List<User>>.computed(() {
    final list = users.value;
    final query = searchQuery.value.toLowerCase().trim();
    if (query.isEmpty) return list;
    return list.where((user) {
      return user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query);
    }).toList();
  });

  // Computed Signal: Total count of users
  late final userCount = Pure<int>.computed(() {
    return filteredUsers.value.length;
  });

  // Actions / CRUD Operations
  Future<void> loadUsers() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      users.value = await repository.fetchUsers();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void addUser(User newUser) {
    users.value = [...users.value, newUser];
  }

  void updateUser(User updatedUser) {
    users.value = users.value.map((u) {
      return u.id == updatedUser.id ? updatedUser : u;
    }).toList();
  }

  void deleteUser(String userId) {
    users.value = users.value.where((u) => u.id != userId).toList();
  }
}
