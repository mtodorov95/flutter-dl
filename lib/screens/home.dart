import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutterdl/services/directory_picker.dart';

class FlutterDl extends StatefulWidget {
  @override
  _FlutterDlState createState() => _FlutterDlState();
}

class _FlutterDlState extends State<FlutterDl> {
  String output = '';
  String targetUrl = '';
  String localName = '';
  String dlPath = '';
  String audioFormat = 'mp3';
  bool audioOnly = false;
  bool isDownloading = false;
  bool hasError = false;
  TextEditingController urlController = TextEditingController();
  Color bgColor = Colors.grey[200];
  Color textColor = Colors.blue;
  Color accentColor = Colors.deepOrange;
  Widget emptyBox = SizedBox(width: 0);

  void download() async {
    setState(() {
      isDownloading = true;
    });
    List<String> args = [];
    if (audioOnly) {
      args = [
        '-i',
        '-x',
        '--audio-format',
        audioFormat,
        '-o',
        '$dlPath\\%(title)s.%(ext)s',
        targetUrl
      ];
    } else {
      args = ['-i', '-f', 'best', '-o', '$dlPath\\%(title)s.%(ext)s', targetUrl];
    }
    Process.start('youtube-dl', args).then((Process process) async {
      process.exitCode.then((int code) {
        setState(() {
          if(code != 0){
            hasError = true;
          }
          isDownloading = false;
          targetUrl = '';
          urlController.clear();
          dlPath = '';
          output = '';
        });
      });
      process.stdout.transform(utf8.decoder).forEach((String decoded) {
        setState(() {
          output = decoded;
        });
      });
      if (await process.exitCode != 0) {
        String out = await process.stderr.transform(utf8.decoder).last;
        setState(() {
          output = out;
        });
      }
    });
  }

  Widget loading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Downloading',
          style: TextStyle(color: textColor),
        ),
        const SizedBox(height: 15),
        CircularProgressIndicator(),
        const SizedBox(height: 15),
        showOutput()
      ],
    );
  }

  Widget showEnterUrlContainer() {
    return Container(
      width: 350,
      child: TextField(
        controller: urlController,
        decoration: InputDecoration(
          labelText: 'Enter Url',
          labelStyle: TextStyle(color: textColor),
        ),
        onChanged: (String value) {
          setState(() {
            targetUrl = urlController.text;
          });
        },
      ),
    );
  }

  Widget showDownloadLocationContainer() {
    if (targetUrl != '') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
            border: Border.all(color: textColor),
            borderRadius: BorderRadius.all(Radius.circular(15)),
            color: Colors.white),
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
      );
    } else {
      return emptyBox;
    }
  }

  Widget showAudioOnlyButton() {
    if (targetUrl != '' && dlPath != '') {
      return Column(
        children: [
          IconButton(
              color: accentColor,
              icon: Icon(audioOnly ? Icons.music_note : Icons.video_library),
              onPressed: () {
                setState(() {
                  audioOnly = !audioOnly;
                });
              }),
          Text(
            audioOnly ? 'Audio only (.mp3)' : 'Audio & Video',
            style: TextStyle(color: textColor),
          )
        ],
      );
    } else {
      return emptyBox;
    }
  }

  Widget showDownloadButton() {
    if (targetUrl != '' && dlPath != '') {
      return Column(
        children: [
          IconButton(
            icon: Icon(Icons.download_outlined),
            onPressed: download,
            iconSize: 36,
          ),
          Text(
            'Download',
            style: TextStyle(color: textColor),
          )
        ],
      );
    } else {
      return emptyBox;
    }
  }

  Widget showOutput() {
    if (output != '') {
      return Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration(
              border: Border.all(color: textColor),
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.white),
          child: Text(
            output,
            style: TextStyle(color: textColor),
          ));
    } else {
      return emptyBox;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Container(
        width: double.maxFinite,
        child: isDownloading
            ? loading()
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'flutter-dl',
                    style: TextStyle(fontSize: 32, color: textColor),
                  ),
                  showEnterUrlContainer(),
                  showDownloadLocationContainer(),
                  showAudioOnlyButton(),
                  showDownloadButton(),
                ],
              ),
      ),
    );
  }
}
