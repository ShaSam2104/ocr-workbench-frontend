import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:csv/csv.dart';
import 'package:synchronized/synchronized.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'auth/custom_auth/custom_auth_user_provider.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    secureStorage = FlutterSecureStorage();
    await _safeInitAsync(() async {
      _isLightOrDarkMode = await secureStorage.getInt('ff_isLightOrDarkMode') ??
          _isLightOrDarkMode;
      _isLightMode = await secureStorage.getBool('ff_isLightMode') ?? _isLightMode;
      
      // Load user preferences
      final prefsString = await secureStorage.getString('ff_userPreferences');
      if (prefsString != null) {
        try {
          _userPreferences = Map<String, dynamic>.from(jsonDecode(prefsString));
        } catch (_) {
          _userPreferences = {};
        }
      }
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late FlutterSecureStorage secureStorage;

  int _isLightOrDarkMode = 1;
  int get isLightOrDarkMode => _isLightOrDarkMode;
  set isLightOrDarkMode(int value) {
    _isLightOrDarkMode = value;
    secureStorage.setInt('ff_isLightOrDarkMode', value);
  }

  void deleteIsLightOrDarkMode() {
    secureStorage.delete(key: 'ff_isLightOrDarkMode');
  }

  // User authentication state
  OcrWorkbenchAuthUser? _currentUser;
  OcrWorkbenchAuthUser? get currentUser => _currentUser;
  set currentUser(OcrWorkbenchAuthUser? value) {
    _currentUser = value;
    notifyListeners();
  }

  // Book and chapter selection
  int? _selectedBook;
  int? get selectedBook => _selectedBook;
  void setSelectedBook(int bookId) {
    _selectedBook = bookId;
    _selectedChapter = null; // Clear chapter when book changes
    _selectedImages.clear();
    _selectedAudios.clear();
    notifyListeners();
  }

  int? _selectedChapter;
  int? get selectedChapter => _selectedChapter;
  void setSelectedChapter(int chapterId) {
    _selectedChapter = chapterId;
    _selectedImages.clear();
    _selectedAudios.clear();
    notifyListeners();
  }

  // OCR task management
  String? _ocrTaskId;
  String? get ocrTaskId => _ocrTaskId;
  void setOcrTaskId(String taskId) {
    _ocrTaskId = taskId;
    notifyListeners();
  }

  // Transcription task management
  String? _transcriptionTaskId;
  String? get transcriptionTaskId => _transcriptionTaskId;
  void setTranscriptionTaskId(String taskId) {
    _transcriptionTaskId = taskId;
    notifyListeners();
  }

  // OCR progress tracking
  Map<int, String> _ocrProgress = {};
  Map<int, String> get ocrProgress => _ocrProgress;
  void updateOcrProgress(Map<int, String> progress) {
    _ocrProgress = progress;
    notifyListeners();
  }

  String? getOcrStatus(int imageId) => _ocrProgress[imageId];
  void setOcrStatus(int imageId, String status) {
    _ocrProgress[imageId] = status;
    notifyListeners();
  }

  // Transcription progress tracking
  Map<int, String> _transcriptionProgress = {};
  Map<int, String> get transcriptionProgress => _transcriptionProgress;
  void updateTranscriptionProgress(Map<int, String> progress) {
    _transcriptionProgress = progress;
    notifyListeners();
  }

  String? getTranscriptionStatus(int audioId) => _transcriptionProgress[audioId];
  void setTranscriptionStatus(int audioId, String status) {
    _transcriptionProgress[audioId] = status;
    notifyListeners();
  }

  // Image selection
  Set<int> _selectedImages = {};
  Set<int> get selectedImages => _selectedImages;
  void toggleImageSelection(int imageId) {
    if (_selectedImages.contains(imageId)) {
      _selectedImages.remove(imageId);
    } else {
      _selectedImages.add(imageId);
    }
    notifyListeners();
  }

  bool isImageSelected(int imageId) => _selectedImages.contains(imageId);
  void selectImages(List<int> imageIds) {
    _selectedImages.addAll(imageIds);
    notifyListeners();
  }

  void deselectImages(List<int> imageIds) {
    _selectedImages.removeAll(imageIds);
    notifyListeners();
  }

  // Audio selection
  Set<int> _selectedAudios = {};
  Set<int> get selectedAudios => _selectedAudios;
  void toggleAudioSelection(int audioId) {
    if (_selectedAudios.contains(audioId)) {
      _selectedAudios.remove(audioId);
    } else {
      _selectedAudios.add(audioId);
    }
    notifyListeners();
  }

  bool isAudioSelected(int audioId) => _selectedAudios.contains(audioId);
  void selectAudios(List<int> audioIds) {
    _selectedAudios.addAll(audioIds);
    notifyListeners();
  }

  void deselectAudios(List<int> audioIds) {
    _selectedAudios.removeAll(audioIds);
    notifyListeners();
  }

  // Clear all selections
  void clearSelections() {
    _selectedImages.clear();
    _selectedAudios.clear();
    notifyListeners();
  }

  // Processing state
  bool _isOcrProcessing = false;
  bool get isOcrProcessing => _isOcrProcessing;
  set isOcrProcessing(bool value) {
    _isOcrProcessing = value;
    notifyListeners();
  }

  bool _isTranscriptionProcessing = false;
  bool get isTranscriptionProcessing => _isTranscriptionProcessing;
  set isTranscriptionProcessing(bool value) {
    _isTranscriptionProcessing = value;
    notifyListeners();
  }

  // Search state
  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    _searchQuery = '';
    notifyListeners();
  }

  // Theme preference
  bool _isLightMode = true;
  bool get isLightMode => _isLightMode;
  void setThemeMode(bool isLight) {
    _isLightMode = isLight;
    secureStorage.setBool('ff_isLightMode', isLight);
    notifyListeners();
  }

  // User preferences
  Map<String, dynamic> _userPreferences = {};
  Map<String, dynamic> get userPreferences => _userPreferences;
  
  void setUserPreference(String key, dynamic value) {
    _userPreferences[key] = value;
    _persistUserPreferences();
    notifyListeners();
  }

  dynamic getUserPreference(String key) => _userPreferences[key];
  
  void updateUserPreferences(Map<String, dynamic> preferences) {
    _userPreferences.addAll(preferences);
    _persistUserPreferences();
    notifyListeners();
  }

  void _persistUserPreferences() {
    try {
      secureStorage.setString(
        'ff_userPreferences',
        jsonEncode(_userPreferences),
      );
    } catch (_) {}
  }

  void clearUserPreferences() {
    _userPreferences.clear();
    secureStorage.delete(key: 'ff_userPreferences');
    notifyListeners();
  }

  // Convenience getters for common preferences
  String? get preferredLanguage => getUserPreference('language') as String?;
  void setPreferredLanguage(String language) => setUserPreference('language', language);

  String? get preferredTheme => getUserPreference('theme') as String?;
  void setPreferredTheme(String theme) => setUserPreference('theme', theme);

  // Reset all app state
  void resetAppState() {
    _currentUser = null;
    _selectedBook = null;
    _selectedChapter = null;
    _ocrTaskId = null;
    _transcriptionTaskId = null;
    _ocrProgress.clear();
    _transcriptionProgress.clear();
    _selectedImages.clear();
    _selectedAudios.clear();
    _isOcrProcessing = false;
    _isTranscriptionProcessing = false;
    _searchQuery = '';
    notifyListeners();
  }
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

extension FlutterSecureStorageExtensions on FlutterSecureStorage {
  static final _lock = Lock();

  Future<void> writeSync({required String key, String? value}) async =>
      await _lock.synchronized(() async {
        await write(key: key, value: value);
      });

  void remove(String key) => delete(key: key);

  Future<String?> getString(String key) async => await read(key: key);
  Future<void> setString(String key, String value) async =>
      await writeSync(key: key, value: value);

  Future<bool?> getBool(String key) async => (await read(key: key)) == 'true';
  Future<void> setBool(String key, bool value) async =>
      await writeSync(key: key, value: value.toString());

  Future<int?> getInt(String key) async =>
      int.tryParse(await read(key: key) ?? '');
  Future<void> setInt(String key, int value) async =>
      await writeSync(key: key, value: value.toString());

  Future<double?> getDouble(String key) async =>
      double.tryParse(await read(key: key) ?? '');
  Future<void> setDouble(String key, double value) async =>
      await writeSync(key: key, value: value.toString());

  Future<List<String>?> getStringList(String key) async =>
      await read(key: key).then((result) {
        if (result == null || result.isEmpty) {
          return null;
        }
        return CsvToListConverter()
            .convert(result)
            .first
            .map((e) => e.toString())
            .toList();
      });
  Future<void> setStringList(String key, List<String> value) async =>
      await writeSync(key: key, value: ListToCsvConverter().convert([value]));
}
