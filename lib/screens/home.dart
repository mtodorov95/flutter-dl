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
  Color bgColor = Colors.grey[200];
  Color textColor = Colors.blue;
  Color accentColor = Colors.deepOrange;

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
      backgroundColor: bgColor,
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
                  style: TextStyle(fontSize: 32, color: textColor),
                ),
                Text(
                  'youtube-dl ver: ' + ytDlVersion,
                  style: TextStyle(fontSize: 14, color: textColor),
                ),
              ],
            ),
            Container(
              width: 350,
              child: TextField(
                controller: urlController,
                decoration: InputDecoration(
                    labelText: 'Enter Url',
                    labelStyle: TextStyle(color: textColor),
                ),
                onChanged: (String value){
                  targetUrl = urlController.text;
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: textColor),
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.white
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 300,
                    child: Text(
                      dlPath == '' ? 'Select download location' : dlPath,
                      maxLines: 1,
                      style: TextStyle(
                          color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.folder_open,
                      color: textColor,
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
            ),
            Column(
              children: [
                ToggleButtons(
                  renderBorder: false,
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  color: Colors.grey[600],
                  selectedColor: accentColor,
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
                Text('Audio only (.mp3)', style: TextStyle(color: textColor),)
              ],
            ),
            Column(
              children: [
                IconButton(
                    icon: Icon(Icons.download_outlined),
                    onPressed: download,
                    iconSize: 36,
                ),
                Text('Download', style: TextStyle(color: textColor),)
              ],
            ),
            Container(
                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                decoration: output != '' ? BoxDecoration(
                    border: Border.all(color: textColor),
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    color: Colors.white
                ):null,
                child: Text(output, style: TextStyle(color: textColor),
                )
            ),
          ],
        ),
      ),
    );
  }
}
