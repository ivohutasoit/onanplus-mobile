import 'package:flashlight/flashlight.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScannerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final GlobalKey _qrViewKey = GlobalKey(debugLabel: "QRScanner");
  QRViewController _qrViewController;
  //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(debugLabel: 'Scanner');
  bool _hasFlashlight = false;
  bool _flashOn = false;
  //String _data;

  @override
  void initState() {
    super.initState();
    initFlashlight();
  }

  @override
  void dispose() {
    _qrViewController?.dispose();
    // if (_flashOn) {
    //   Flashlight.lightOff();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size.width * 0.6;
    return Scaffold(
      //key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        brightness: Brightness.dark,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: ModalRoute.of(context).canPop
            ? IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.of(context).pop(null),
              )
            : null,
        actions: [
          _hasFlashlight
              ? IconButton(
                  icon: Icon(!_flashOn ? Icons.flash_on : Icons.flash_off,
                      size: 20.0, color: Colors.white),
                  onPressed: () {
                    _qrViewController.toggleFlash();
                    // if (_flashOn) {
                    //   Flashlight.lightOff();
                    // } else {
                    //   Flashlight.lightOn();
                    // }
                    setState(() {
                      _flashOn = !_flashOn;
                    });
                  },
                )
              : Container(),
        ],
      ),
      // body: Center(
      //   child: SizedBox(
      //     width: size,
      //     height: size,
      //     child: QrCamera(
      //       onError: (context, error) => Text(
      //             error.toString(),
      //             style: TextStyle(color: Colors.red)
      //           ),
      //       qrCodeCallback: (code) {
      //         Navigator.of(context).pop(code);
      //       },
      //       child: Container(
      //         decoration: BoxDecoration(
      //           //color: Colors.transparent,
      //           border: Border.all(
      //             color: Theme.of(context).primaryColor,
      //             width: 0.5,
      //             style: BorderStyle.solid
      //           ),
      //         ),
      //       ),
      //     ),
      //   ),
      // ),
      body: QRView(
        key: _qrViewKey,
        onQRViewCreated: (controller) {
          _qrViewController = controller;
          _qrViewController.scannedDataStream
              .listen((data) {
                _qrViewController?.dispose();
                Navigator.pop(context, data);
                //Navigator.of(context).pop(data);
            });
        },
        overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).accentColor,
            borderRadius: 0.0,
            borderLength: 30.0,
            borderWidth: 4.0,
            cutOutSize: size,
            overlayColor: Colors.black87),
      ),
    );
  }

  void initFlashlight() async {
    bool hasFlash = await Flashlight.hasFlashlight;
    print("Device has flash ? $hasFlash");
    setState(() {
      _hasFlashlight = hasFlash;
    });
  }
}
