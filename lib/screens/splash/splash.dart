import 'dart:convert';
import 'dart:io';

import 'package:appupdate2/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  OtaEvent currentEvent = OtaEvent(OtaStatus.DOWNLOADING, "");

  void goToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );
  }

  @override
  void initState() {
    super.initState();

    verifyUpdate();
  }

  void verifyUpdate() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    try {
      var response = await Dio().get(
          'https://raw.githubusercontent.com/Luuck4s/updateapp/main/app-update-changelog.json');

      var json = jsonDecode(response.data);

      var buildNumber = int.parse(packageInfo.buildNumber);
      var version = packageInfo.version;

      int lastBuildNumber = int.parse(json['latestVersionCode']);
      var lastVersion = json['latestVersion'];
      String linkDownload = json['url'];

      if (buildNumber < lastBuildNumber && buildNumber != lastVersion) {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Nova atualização disponível'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Nova versão ${lastVersion.toString()} está disponível, clique em ok para realizar o download'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  updateApp(linkDownload);
                },
              ),
            ],
          ),
        );
      } else {
        goToHome();
      }
    } catch (e) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Erro ao busca atualização'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Erro ao buscar atualização ${e.toString()}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                exit(1);
              },
            ),
          ],
        ),
      );
      print(e);
    }
  }

  updateApp(String url) {
    try {
      OtaUpdate()
          .execute(
        '${url}',
      )
          .listen(
        (OtaEvent event) {
          setState(() => currentEvent = event);
        },
      );
    } catch (e) {
      print('Failed to make OTA update. Details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Center(
          child: Column(
            children: [
              Text(
                "Buscando Atualizações",
                textScaleFactor: 2,
              ),
              Text(
                  'OTA status: ${currentEvent.status.toString()} : ${currentEvent.value.toString()} \n'),
            ],
          ),
        ),
      ),
    );
  }
}
