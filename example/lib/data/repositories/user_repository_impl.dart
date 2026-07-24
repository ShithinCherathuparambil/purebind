import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/mock_user_remote_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final MockUserRemoteDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  Future<List<User>> fetchUsers() {
    return dataSource.getUsersFromApi();
  }
}
