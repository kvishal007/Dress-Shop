import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/settings/data/user_repository.dart';
import 'package:smart_dress_shop_pos/features/settings/data/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return UserRepository(apiClient);
});

class UserState {
  final bool isLoading;
  final List<UserModel> users;
  final String? errorMessage;

  UserState({
    this.isLoading = false,
    this.users = const [],
    this.errorMessage,
  });

  UserState copyWith({
    bool? isLoading,
    List<UserModel>? users,
    String? errorMessage,
  }) {
    return UserState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      errorMessage: errorMessage,
    );
  }
}

class UserNotifier extends StateNotifier<UserState> {
  final UserRepository _repository;

  UserNotifier(this._repository) : super(UserState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final users = await _repository.getUsers();
      state = state.copyWith(isLoading: false, users: users);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createUser(Map<String, dynamic> data) async {
    try {
      final newUser = await _repository.createUser(data);
      state = state.copyWith(users: [newUser, ...state.users]);
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<void> deactivateUser(String id) async {
    try {
      await _repository.deactivateUser(id);
      loadUsers(); // refresh list
    } catch (e) {
      throw Exception('Failed to deactivate user: $e');
    }
  }

  Future<void> resetPassword(String id, String newPassword) async {
    try {
      await _repository.resetPassword(id, newPassword);
    } catch (e) {
      throw Exception('Failed to reset password: $e');
    }
  }

  Future<void> updateRole(String id, String role) async {
    try {
      await _repository.updateRole(id, role);
      loadUsers();
    } catch (e) {
      throw Exception('Failed to update role: $e');
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return UserNotifier(repo);
});
