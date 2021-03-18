import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterdl/services/directory_picker.dart';


class FlutterDl extends StatefulWidget {
  @override
  _FlutterDlState createState() => _FlutterDlState();
}

class _FlutterDlState extends State<FlutterDl> {
  String ytDlVersion = '';
  String output = '';
  String targetUrl = '';
  String localName = '';
  String dlPath = '';
  bool audioOnly = false;
  List<bool> buttons = [false];
  TextEditingController urlController = TextEditingController();
  TextEditingController localNameController = TextEditingController();

  void getYtDlVersion() {
    Process.run('youtube-dl', ['--version']).then((ProcessResult results) {
      setState(() {
        ytDlVersion = results.stdout;
      });
    });
  }

  void download() {
    List<String> args = [];
    if(audioOnly){
      args = ['-x', '--audio-format', 'mp3', '-o', '$dlPath\\%(title)s.%(ext)s', targetUrl];
      print(args);
      Process.start('youtube-dl', args).then((Process process) {
        process.stdout.transform(utf8.decoder)
            .forEach((String decoded){
          setState(() {
            output = decoded;
          });
        });
      });
    }
    else{
      args = ['-f', 'best', '-o', '$dlPath\\%(title)s.%(ext)s', targetUrl];
      print(args);
      Process.start('youtube-dl', args).then((Process process) {
        process.stdout.transform(utf8.decoder)
            .forEach((String decoded){
          setState(() {
            output = decoded;
          });
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getYtDlVersion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  'flutter-dl',
                  style: TextStyle(fontSize: 32, color: Colors.blue),
                ),
                Text(
                  'youtube-dl ver: ' + ytDlVersion,
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ],
            ),
            Container(
              width: 350,
              child: TextField(
                controller: urlController,
                decoration: InputDecoration(
                    labelText: 'Enter Url',
                    labelStyle: TextStyle(color: Colors.blue)),
                onChanged: (String value){
                  targetUrl = urlController.text;
                },
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 350,
                  child: Text(
                    dlPath == '' ? 'Download location' : dlPath,
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.folder_open,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    final dir = DirectoryPicker();
                    dir.hidePinnedPlaces = false;
                    dir.title = 'Select download location';
                    final result = dir.getDirectory();
                    if (result != null) {
                      setState(() {
                        dlPath = result.path;

                      });
                    }
                  },
                )
              ],
            ),
            ToggleButtons(
              color: Colors.blue,
              borderColor: Colors.white38,
              selectedColor: Colors.deepOrange,
              children: [
                Icon(Icons.music_note),
              ],
              isSelected: buttons,
              onPressed: (int index) {
                setState(() {
                  audioOnly = buttons[index] = !buttons[index];
                });
              },
            ),
            IconButton(icon: Icon(Icons.download_outlined), onPressed: download),
            Text(output, style: TextStyle(color: Colors.blue),)
          ],
        ),
      ),
    );
  }
}
