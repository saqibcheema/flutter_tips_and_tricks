import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(const MyApp());
}

Future<bool> requestPermission() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      var status = await Permission.photos.request();
      return status.isGranted;
    } else {
      // for under 12 version
      var status = await Permission.storage.request();
      return status.isGranted;
    }
  }
  return true;
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final imageUrl = 'https://images.unsplash.com/photo-1608748010899-18f300247112';

  Future<void> downloadImage(BuildContext context,String imageUrl) async {
    try {
      // 1. Permission check
      var status = await requestPermission();
      if (!status) {
        print("Storage permission not granted!");
        return;
      }

      // 2. Download image with Dio
      var response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // 3. Save in temporary directory
      // final tempDir = await getTemporaryDirectory();
      // final filePath = "${tempDir.path}/downloaded_image.jpg";

      // Save image in Gallery directly
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "downloaded_image${DateTime.now().millisecondsSinceEpoch}",
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image Saved to Gallery: $result")));
    } catch (e) {
      print("Error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Saver',style: TextStyle(color: Colors.white),),centerTitle: true,backgroundColor: Colors.teal,),
      body: Center(
        child: Image.network(imageUrl),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            downloadImage(context,imageUrl);
          },
        backgroundColor: Colors.teal,
          child: Icon(Icons.download,color: Colors.white,),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

