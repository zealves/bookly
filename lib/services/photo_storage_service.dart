import 'dart:convert';
import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists photos attached by the user to calendar events.
///
/// `device_calendar` events have no native media attachment, so the mapping
/// `eventId -> [photoPath]` lives in [SharedPreferences] and the binary files
/// are copied into the app documents directory.
class PhotoStorageService {
  PhotoStorageService({
    ImagePicker? picker,
    Future<SharedPreferences> Function()? prefs,
    Future<Directory> Function()? documentsDir,
  })  : _picker = picker ?? ImagePicker(),
        _prefs = prefs ?? SharedPreferences.getInstance,
        _documentsDir = documentsDir ?? getApplicationDocumentsDirectory;

  static const String _indexKey = 'event_photos';
  static const String _photosFolder = 'event_photos';

  final ImagePicker _picker;
  final Future<SharedPreferences> Function() _prefs;
  final Future<Directory> Function() _documentsDir;

  Future<List<String>> getPhotos(String eventId) async {
    final index = await _readIndex();
    return List<String>.from(index[eventId] ?? const <String>[]);
  }

  /// Opens the gallery, copies the chosen image into the app's documents
  /// directory, and stores the new path under [eventId]. Returns the new
  /// absolute path, or `null` if the user cancelled.
  Future<String?> pickAndAttachPhoto(String eventId) async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return null;

    final docs = await _documentsDir();
    final eventDir = Directory(p.join(docs.path, _photosFolder, eventId));
    if (!await eventDir.exists()) {
      await eventDir.create(recursive: true);
    }

    final ext = p.extension(picked.path).isNotEmpty
        ? p.extension(picked.path)
        : '.jpg';
    final filename = '${DateTime.now().microsecondsSinceEpoch}$ext';
    final destPath = p.join(eventDir.path, filename);
    await File(picked.path).copy(destPath);

    final index = await _readIndex();
    final list = List<String>.from(index[eventId] ?? const <String>[]);
    list.add(destPath);
    index[eventId] = list;
    await _writeIndex(index);

    return destPath;
  }

  Future<void> removePhoto(String eventId, String path) async {
    final index = await _readIndex();
    final list = List<String>.from(index[eventId] ?? const <String>[]);
    list.remove(path);
    if (list.isEmpty) {
      index.remove(eventId);
    } else {
      index[eventId] = list;
    }
    await _writeIndex(index);

    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<Map<String, List<String>>> _readIndex() async {
    final prefs = await _prefs();
    final raw = prefs.getString(_indexKey);
    if (raw == null || raw.isEmpty) return <String, List<String>>{};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, List<String>.from(value as List)),
    );
  }

  Future<void> _writeIndex(Map<String, List<String>> index) async {
    final prefs = await _prefs();
    await prefs.setString(_indexKey, jsonEncode(index));
  }
}
