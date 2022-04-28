import 'dart:io';
import 'package:path_provider/path_provider.dart';

///Reading and writing for documents directory,
///A directory for the app to store files that only it can access. The system clears the directory only when the app is deleted.
class PreviousOfficeHandler {
  static final PreviousOfficeHandler _instance = PreviousOfficeHandler._();

  PreviousOfficeHandler._();

  static void initialize() {
  }

  static PreviousOfficeHandler getInstance() {
    return _instance;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/previous_choice.txt');
  }

  Future<File> writeChoice(String choice) async {
    final file = await _localFile;
    return file.writeAsString(choice);
  }

  Future<String> readPrevChoice() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents.toString();
    } catch (e) {
      return e.toString();
    }
  }

}

