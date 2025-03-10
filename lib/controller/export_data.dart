import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

Future<void> exportData(List<List<String>> data, String filename) async {
  final String csvData = const ListToCsvConverter().convert(data);
  final directory = await getApplicationDocumentsDirectory();
  final path = '${directory.path}/$filename.csv';
  final File file = File(path);
  await file.writeAsString(csvData);
  print("CSV Exported: $path");
}
