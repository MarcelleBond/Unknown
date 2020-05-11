import 'dart:io';
import 'package:dart_tags/dart_tags.dart';
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
    if (Platform.isWindows) {
      defaultDir = new Directory('\\Users\\AnyUser\\Music\\test');
    } else if (Platform.isAndroid) {
      defaultDir = new Directory('storage/emulated/0/Music');
    }

    _addSongs(defaultDir);
   
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
            itemBuilder: (context) {
              return [
                PopupMenuItem(child: Text("Settings")),
                PopupMenuItem(child: Text("Organise Music"))
                ];
            },
            icon: Icon(Icons.menu),
          )
        ],
      ),
      body: GridView.count(
        crossAxisCount: 1,
        scrollDirection: Axis.vertical,
        children: List.generate(songCount, (index){
          return Center(
            child: Container(
               decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 3.0),
               ),
               padding: const EdgeInsets.all(16.0),
               child:  Text(_songs[index]), /*  Text(
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
    _proceedArg(songs[0]);
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
  }

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
  final file = File(fileName);
  List<Tag> newTags = new List<Tag>();
  Tag tags = new Tag();
  // Map<String, dynamic> test = new Map<String, dynamic>();
  // test.addAll({'artist' : "Bond"});
  tags.type = 'id3';
  tags.version = '2.3.0';
  tags.tags = {'title' : "Bond"};
  newTags.add(tags);
  await TagProcessor().getTagsFromByteArray(file.readAsBytes()).then((l) {
    print('FILE: $fileName');
    l.forEach(print);
    print('\n');
  });



  print('\n');
  print(newTags[0]);
  print('\n');

  await TagProcessor().putTagsToByteArray(file.readAsBytes(), newTags).then((value) => file.writeAsBytes(value));

  await TagProcessor().getTagsFromByteArray(file.readAsBytes()).then((l) {
    print('FILE: $fileName');
    l.forEach(print);
    print('\n');
  });
}
}
