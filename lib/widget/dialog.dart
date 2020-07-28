import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingDialog {
  static Future<void> show(GlobalKey key, BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      //barrierColor: Colors.black26,
      builder: (context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: SimpleDialog(
            key: key,
            //backgroundColor: Colors.black12,
            contentPadding: EdgeInsets.all(16.0),
            children: [
              Center(
                child: Row(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16.0,),
                    Text('Please wait....',
                      style: TextStyle(
                        //color: Colors.white
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }
    );
  } 
}