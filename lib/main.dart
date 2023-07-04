import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_thumbnail_app/file_extension.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Video Thumbnail App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // 1) Create an picker object for our ImagePicker
  final ImagePicker picker = ImagePicker(); 

  // 2) A file object which can be null
  File? file;

  // 3) An async call to a pick media file
  Future<void> pickMedia() async {
    final mediaFile = await picker.pickMedia();

    if (mediaFile != null) {
      final file = File(mediaFile.path);
      setState(() {
        this.file = file;
      });
    } else {
      // User canceled the picker
    }
  }

  /// generate jpeg thumbnail
  Future<Uint8List?> _generateThumbnail(File file) async {
    final thumbnailAsUint8List = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          320, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 50,
    );
    return thumbnailAsUint8List!;
  }

  /// depending on file type show particular image
  Future<ImageProvider<Object>>? _imageProvider(File file) async {
    if (file.fileType == FileType.video) {
      final thumbnail = await _generateThumbnail(file);
      return MemoryImage(thumbnail!);
    } else if (file.fileType == FileType.image) {
      return FileImage(file);
    } else {
      throw Exception("Unsupported media format");
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 28.0,
                left: 10,
                right: 10,
                bottom: 30,
              ),
              child: file == null
                  ? const NoMediaPicked()
                  : FutureBuilder<ImageProvider>(
                      future: _imageProvider(file!),
                      builder: (context, snapshot) {
                        if (snapshot.data != null && snapshot.connectionState == ConnectionState.done ) {
                          return Container(
                            height: 300,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(9),
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: snapshot.data!,
                              ),
                            ),
                          );
                        }
                        return const NoMediaPicked();
                      }),
            ),
            ElevatedButton(
                onPressed: pickMedia, child: const Text('Pick Media'))
          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class NoMediaPicked extends StatelessWidget {
  const NoMediaPicked({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(9)),
      child: const Center(child: Text('Click the button to pick media')),
    );
  }
}
