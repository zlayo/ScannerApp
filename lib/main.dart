import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:path/path.dart';

String barcodeResult = '';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final barcodeResultController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('I Am Scanner App'),
          backgroundColor: Color.fromARGB(255, 8, 110, 161),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/qrcodelogo.jpg'),
              SizedBox(height: 20),
              TextField(
                controller: barcodeResultController,
              ),
              RawMaterialButton(
                onPressed: () async {
                  if (await Permission.camera.request().isGranted) {
                    String barcodeResult = await scanBarcode();
                    print('Scanned code: $barcodeResult');
                    barcodeResultController.text =
                        'Scanned code: $barcodeResult';
                  }
                },
                fillColor: Color.fromARGB(255, 8, 110, 161),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 100.0, vertical: 15.0),
                  child:
                      Text('Scan Away', style: TextStyle(color: Colors.white)),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> scanBarcode() async {
  String barcodeScanRes = '';
  try {
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", 'Scan another', true, ScanMode.BARCODE);
    print(barcodeScanRes);
    insertData({'ticketno': barcodeScanRes, 'scanned': true});
  } catch (e) {
    print('Unknown error: $e');
  }
  return barcodeScanRes;
}

class DBHelper {
  static Database? _db = null;

  Future<Database?> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDatabase();
    return _db;
  }

  initDatabase() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'tickets.db');
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE tickets (id INTEGER PRIMARY KEY, ticketno TEXT, scanned boolean DEFAULT false, created_at TEXT DEFAULT CURRENT_TIMESTAMP, updated_at TEXT DEFAULT CURRENT_TIMESTAMP)');
  }
}

Future<void> insertData(Map<String, dynamic> data) async {
  var dbClient = await DBHelper().db;
  await dbClient!.insert('tickets', data);
}
