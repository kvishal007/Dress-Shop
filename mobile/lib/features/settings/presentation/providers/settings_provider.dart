import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_dress_shop_pos/core/network/api_client.dart';
import 'package:smart_dress_shop_pos/features/settings/data/settings_repository.dart';
import 'package:smart_dress_shop_pos/features/settings/data/settings_model.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SettingsRepository(apiClient);
});

class SettingsState {
  final bool isLoading;
  final SettingsModel? settings;
  final String? errorMessage;

  SettingsState({
    this.isLoading = false,
    this.settings,
    this.errorMessage,
  });

  SettingsState copyWith({
    bool? isLoading,
    SettingsModel? settings,
    String? errorMessage,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      settings: settings ?? this.settings,
      errorMessage: errorMessage,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(SettingsState()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final settings = await _repository.getSettings();
      state = state.copyWith(isLoading: false, settings: settings);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> updateSettings(Map<String, dynamic> data) async {
    try {
      final updated = await _repository.updateSettings(data);
      state = state.copyWith(settings: updated);
    } catch (e) {
      throw Exception('Failed to update settings: $e');
    }
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repo);
});
