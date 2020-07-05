import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TaskDAO {
  static const String _tablename = 'data';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File("${dir.path}/$_tablename.json");
  }

  Future<File> saveData(List<Map<String, dynamic>> toDoList) async {
    String data = json.encode(toDoList);

    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String> readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
