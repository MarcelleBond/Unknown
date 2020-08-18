import 'dart:io';
import 'package:dart_tags/dart_tags.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;

void _setTargetPlatformForDesktop() {
  // No need to handle macOS, as it has now been added to TargetPlatform.
  if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  _setTargetPlatformForDesktop();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.grey[800],
      ),
      home: MyHomePage(title: 'EYE OF RA'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _songs = List<String>();
  int songCount = 0;
  Directory defaultDir;

  void initState() {
    super.initState();
    startup();
  }

  void startup() async {
    if (Platform.isWindows) {
      defaultDir = new Directory('C:\\Users\\AnyUser\\Music\\test');
      _addSongs(defaultDir);
    } else if (Platform.isAndroid) {
      await Permission.storage.request();
      if (await Permission.storage.isGranted) {
        defaultDir = new Directory('storage/emulated/0/Music');
        _addSongs(defaultDir);
      } else {
        await openAppSettings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: new Center(
            child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                child: Image.asset('images/RA.png',
                    width: 100, height: 50, fit: BoxFit.scaleDown))),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              _proceedArg(_songs[1]);
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: Text("Settings"),
                  value: 0,
                ),
                PopupMenuItem(
                  child: Text("Organise Music"),
                  value: 1,
                )
              ];
            },
            icon: Icon(Icons.menu),
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 1,
        scrollDirection: Axis.vertical,
        children: List.generate(songCount, (index) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 3.0),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Text(_songs[
                  index]), /*  Text(
                 'Video $index',
                 style: Theme.of(context).textTheme.headline,
               ), */
            ),
          );
        }),
      ),
    );
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

  void _showFilesinDir(Directory dir) {
    dir
        .list(recursive: false, followLinks: false)
        .listen((FileSystemEntity entity) {
      print(entity.path);
    });
  }

  Future<List<String>> platformDives() async {
    if (Platform.isWindows) {
      ProcessResult result =
          await Process.run('wmic', ['logicaldisk', 'get', 'caption']);
      String drives = result.stdout;
      List<String> driveList = drives.split('\n');
      driveList.removeWhere((test) => test.trim().length == 0);
      driveList.removeAt(0);
      for (var i = 0; i < driveList.length; i++) {
        driveList[i] = driveList[i].trim();
      }
      return driveList;
    } else if (Platform.isAndroid) {
      return null;
    }
    return null;
  }

/* var listTags = new List<Tag>();
    var tag = new Tag(); 
    tag.type = "ID3";
    tag.version = "2.3.0"; 
    tag.tags = {"PRIV" : "䴯啮楱略䙩汥䥤敮瑩晩敲AMGa_id=R   580126;AMGp_id=P     4099;AMGt_id=T  5518741�", "TPUB" : "Sony Music Distribution", "track": "7", "album": "A New Day Has Come [Australian Bonus Track]", "year": "2002", "TPE2": "Celine Dion", "title": "Goodbye's (The Saddest Word)", "genre": "3", "TCOM": "Robert John 'Mutt' Lange", "artist": "Mac Miller"};
    listTags.add(tag); */

  void _proceedArg(String path) {
    final fileType = FileStat.statSync(path).type;
    switch (fileType) {
      case FileSystemEntityType.directory:
        Directory(path)
            .list(recursive: true, followLinks: false)
            .listen((FileSystemEntity entity) {
          if (entity.statSync().type == FileSystemEntityType.file &&
              entity.path.endsWith('.mp3')) {
            printFileInfo(entity.path);
          }
        });
        break;
      case FileSystemEntityType.file:
        if (path.endsWith('.mp3')) {
          printFileInfo(path);
        }
        break;
      case FileSystemEntityType.notFound:
        print('file not found');
        break;
      default:
        print('sorry dude I don`t know what I must to do with that...\n');
    }
  }

  Future<void> printFileInfo(String fileName) async {
    print("made it to file info printing\n\n\n");
    final file = File(fileName);
    var check = await file.open();
    print("made it pass the file opening\n\n\n");
    // print(await check.read(check.lengthSync()));
    TagProcessor()
        .getTagsFromByteArray(check.read(check.lengthSync()))
        .then((l) {
      print('FILE: $fileName');
      var listTags = new List<Tag>();
      var tag = new Tag();
      tag.type = "ID3";
      tag.version = "2.3.0";
      tag.tags = {
        "PRIV":
            "䴯啮楱略䙩汥䥤敮瑩晩敲AMGa_id=R   580126;AMGp_id=P     4099;AMGt_id=T  5518741�",
        "TPUB": "Sony Music Distribution",
        "track": "7",
        "album": "A New Day Has Come [Australian Bonus Track]",
        "year": "2002",
        "TPE2": "Celine Dion",
        "title": "Goodbye's (The Saddest Word)",
        "genre": "3",
        "TCOM": "Robert John 'Mutt' Lange",
        "artist": "Mac Miller"
      };
      listTags.add(tag);
      check.setPositionSync(0);
      TagProcessor()
          .putTagsToByteArray(check.read(check.lengthSync()))
          .then((value) {
        check.writeFromSync(value);
        check.setPositionSync(0);
        TagProcessor()
            .getTagsFromByteArray(check.read(check.lengthSync()))
            .then((l) {
          print('FILE: $fileName');
          final output = File("C:\\Users\\AnyUser\\Music\\test.txt");
          output.writeAsStringSync(l.toString());
          print('\n');
          check.closeSync();
        });
      });
      // l.forEach(print);
    });
  }
}
