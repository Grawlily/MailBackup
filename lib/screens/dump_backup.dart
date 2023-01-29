import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mail_backup/repositories/app_config.dart';
import 'package:mail_backup/utils/compress.dart';
import 'package:mail_backup/utils/preserve_mails.dart';

import 'package:mail_backup/utils/shared_preferences_util.dart';
import 'package:path/path.dart' as pathlib;
import 'package:path_provider/path_provider.dart';

import 'package:mail_backup/exceptions/mails.dart';

class Backup extends StatelessWidget {
  const Backup({super.key});

  @override
  Widget build(BuildContext context) {
    return const Main();
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  bool _backupProcessing = false;

  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return _backupProcessing ? _processing() : _noProcessing();
  }

  Widget _noProcessing() {
    return Center(
      child: OutlinedButton(
        onPressed: () async {
          await _backupMails();
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          'メールをバックアップ',
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.shortestSide * 0.05),
        ),
      ),
    );
  }

  Widget _processing() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> _backupMails() async {
    setState(() {
      _backupProcessing = true;
    });
    try {
      AppConfig config = await AppConfig.getInstance();
      String outDir = await preserveMails(config.getHost(), config.getPort(),
          config.getUserName(), config.getPassword(), config.getIsSecure());
      Directory directory = Directory(pathlib.join(
          (await getApplicationDocumentsDirectory()).path, 'backups'));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      await compress(outDir, '${pathlib.join(directory.path, pathlib.basename(outDir))}.zip');
    } on PreferenceNotFound catch (e) {
      return _showError(e);
    } on NotConnectable catch (e) {
      return _showError(e);
    } catch (e) {
      return _showError(e);
    }
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          title: const Text('バックアップが終了しました。'),
          icon: Icon(
            Icons.check_outlined,
            color: Colors.green,
            size: MediaQuery.of(context).size.shortestSide * 0.1,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.blueAccent,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(0),
            ),
          ],
        );
      },
    );
    setState(() {
      _backupProcessing = false;
    });
  }

  Future<void> _showError(Object e) async {
    late String message;
    if (e is PreferenceNotFound) {
      message = 'メールサーバーの設定を行ってください。';
    } else if (e is NotConnectable) {
      message = 'メールサーバーに接続できませんでした。';
    } else {
      message = '予期しないエラーが発生しました。';
    }
    double iconSize = MediaQuery.of(context).size.shortestSide * 0.1;
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          title: Text(message),
          icon: Icon(Icons.error_outline, color: Colors.red, size: iconSize),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => Navigator.of(context).pop(0),
            ),
          ],
        );
      },
    );
  }
}
