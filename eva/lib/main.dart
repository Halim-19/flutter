import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:io';

class FileUploadApp extends StatelessWidget {
  const FileUploadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('File Upload App')),
        body: const FileUploadScreen(),
      ),
    );
  }
}

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  _FileUploadScreenState createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? _fileName;
  String? _fileContent;
  String? _filePath;
  bool _isPdf = false;

  Future<void> _pickFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);

    if (result != null) {
      final PlatformFile platformFile = result.files.single;
      setState(() {
        _fileName = platformFile.name;
      });

      if (platformFile.bytes != null) {
        _readFileWeb(platformFile);
      }
    }
  }

  void _readFileWeb(PlatformFile platformFile) {
    if (_fileName!.endsWith('.xlsx')) {
      var bytes = platformFile.bytes!;
      var excel = Excel.decodeBytes(bytes);

      // Process Excel file
      String excelContent = '';
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          excelContent +=
              '${row.map((cell) => cell?.value.toString()).join(', ')}\n';
        }
      }
      setState(() {
        _fileContent = excelContent;
      });
    } else if (_fileName!.endsWith('.json')) {
      String jsonString = String.fromCharCodes(platformFile.bytes!);
      setState(() {
        _fileContent = jsonString; // Display JSON content
      });
    } else if (_fileName!.endsWith('.pdf')) {
      setState(() {
        _fileContent = 'PDF preview is not available on web yet: $_fileName';
      });
    } else {
      setState(() {
        _fileContent = 'Unsupported file type';
      });
    }
  }

  void _readFile(File file) {
    if (_fileName!.endsWith('.xlsx')) {
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Process Excel file
      String excelContent = '';
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          excelContent +=
              '${row.map((cell) => cell?.value.toString()).join(', ')}\n';
        }
      }
      setState(() {
        _fileContent = excelContent;
      });
    } else if (_fileName!.endsWith('.pdf')) {
      // PDF content will be displayed using a PDF viewer widget
      setState(() {
        _fileContent = 'PDF file uploaded: $_fileName';
      });
    } else if (_fileName!.endsWith('.json')) {
      String jsonString = file.readAsStringSync();
      setState(() {
        _fileContent = jsonString; // Display JSON content
      });
    } else {
      setState(() {
        _fileContent = 'Unsupported file type';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: _pickFile,
            child: const Text('Upload File'),
          ),
          if (_fileName != null) Text('File Name: $_fileName'),
          if (_fileContent != null && !_isPdf)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Text('Content:\n$_fileContent'),
              ),
            ),
          if (_isPdf && _filePath != null)
            Expanded(
              child: PDFView(
                filePath: _filePath!,
              ),
            ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const FileUploadApp());
}
