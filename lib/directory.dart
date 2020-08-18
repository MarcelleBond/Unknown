/* import 'dart:io';
import 'package:dart_tags/dart_tags.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

void startup() async {
  if (Platform.isWindows) {
    defaultDir = new Directory('C:/Users/AnyUser/Music/test');
  } else if (Platform.isAndroid) {
    await Permission.storage.request();
    defaultDir = new Directory('storage/emulated/0/Music');
  }
  _addSongs(defaultDir);
}

void _addSongs(Directory list) async {
  List<String> songs = List<String>();

  await list
      .list(recursive: true, followLinks: false)
      .forEach((FileSystemEntity entity) {
    if (entity.path.endsWith(".mp3")) {
      print(entity.path);
      songs.add(entity.path);
    }
  });
  print('i made it first ' + songs.toString());
  setState(() {
    _songs = songs;
    songCount = songs.length;
  });
  // _proceedArg(songs[0]);
}
 */