// ignore_for_file: non_constant_identifier_names, file_names, prefer_typing_uninitialized_variables, avoid_print, prefer_const_constructors, unused_catch_clause

import 'dart:io';

import 'package:TEDxSJEC/Pages/details.dart';
import 'package:TEDxSJEC/Pages/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

var status = 'Scan QR Code';
late Response response;
var dio = Dio();
var id;
Future CheckCode(id) async {
  try {
    response = await dio.post(
      'https://tedxsjec-2022.vigneshcodes.in/api/payment/flag?id=$id',
      options: Options(
        headers: {
          'Authorization': token,
        },
      ),
    );
    if (response.statusCode == 200) {
      print('Success !!!');
      qrCode.value = 'Success';
      return;
    } else if (response.statusCode == 400) {
      qrCode.value = 'Already Scanned';
      Future.delayed(Duration(seconds: 4), () {
        qrCode.value = 'Scan Qr Code';
      });
      return;
    } else {
      qrCode.value = 'Invalid QR Code';
      Future.delayed(Duration(seconds: 4), () {
        qrCode.value = 'Scan Qr Code';
      });
      return;
    }
  } on SocketException catch (_) {
    qrCode.value = 'No Internet Connection';
    throw Exception('No Internet Connection');
  } on Exception catch (e) {
    Future.delayed(Duration(seconds: 4), () {
      qrCode.value = 'Scan Qr Code';
    });
    qrCode.value = 'Invalid QR Code or already scanned';
    Future.delayed(Duration(seconds: 4), () {
      qrCode.value = 'Scan Qr Code';
    });
    throw Exception('Invalid QR Code or already scanned');
  }
  // print(response.data);
}

ValueNotifier qrCode = ValueNotifier('Scan Qr Code');

class _HomeState extends State<Home> {
  @override
  void initState() {
    qrCode.value = 'Scan Qr Code';
    super.initState();
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/logo.png'),
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'Scan Result',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: qrCode,
                  builder: (context, value, child) => Text(
                    qrCode.value.toString(),
                    style: TextStyle(
                      fontSize: 20,
                      color: qrCode.value == 'Success'
                          ? Colors.green
                          : qrCode.value == 'Scan Qr Code'
                              ? Colors.white
                              : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 72),
                GestureDetector(
                  onTap: () => scanQRCode(),
                  child: Container(
                    width: 170,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Tap to scan',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: () async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    prefs.setString('', token);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 140, 37, 29),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Future<void> scanQRCode() async {
    var qrCode = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancel',
      false,
      ScanMode.QR,
    );

    if (!mounted) return;

    setState(() {
      qrCode = qrCode;
    });
    await CheckCode(qrCode);
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Details(
            data: response.data,
          ),
        ),
      );
    }
  }
}
