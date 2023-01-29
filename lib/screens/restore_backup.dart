import 'dart:io';

import 'package:collection/collection.dart';
import 'package:mail_backup/utils/append_mails.dart';
import 'package:path/path.dart' as pathlib;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import '../exceptions/mails.dart';
import '../repositories/app_config.dart';
import '../utils/compress.dart';
import '../utils/shared_preferences_util.dart';

class Restore extends StatelessWidget {
  const Restore({super.key});

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
  @override
  Widget build(BuildContext context) {
    return _body();
  }

  Widget _body() {
    return Center(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
          ),
          const SizedBox(
            child: Text('リストアするバックアップを選択してください。'),
          ),
          Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
          ),
          FutureBuilder(
              future: _getBackupItems(),
              builder:
                  (context, AsyncSnapshot<List<FileSystemEntity>> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.isEmpty) {
                    return const Text('バックアップデータがありません。');
                  }
                  return Expanded(
                    child: ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.backup_outlined),
                            title: Text(
                                pathlib.basename(snapshot.data![index].path)),
                            trailing: const Icon(Icons.arrow_forward_outlined),
                            shape: const Border(
                              bottom: BorderSide(color: Colors.grey),
                            ),
                            onTap: () async {
                              await _checkRestoreBackup(
                                  snapshot.data![index].path);
                            },
                          );
                        }),
                  );
                } else if (snapshot.hasError) {
                  return const Text('バックアップファイルを取得中にエラーが発生しました。');
                } else {
                  return const CircularProgressIndicator();
                }
              }),
        ],
      ),
    );
  }

  Future<List<FileSystemEntity>> _getBackupItems() async {
    Directory directory = Directory(pathlib.join(
        (await getApplicationDocumentsDirectory()).path, 'backups'));
    List<FileSystemEntity> files = [];
    await for (FileSystemEntity f in directory.list()) {
      files.add(f);
    }
    return files.sorted((a, b) => a.path.compareTo(b.path));
  }

  Future<void> _checkRestoreBackup(String backupFilePath) async {
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          title: Text(pathlib.basename(backupFilePath)),
          content: Text(
              '${pathlib.basename(backupFilePath)}をリストアしますか？\n※この操作は取り消せません。'),
          icon: Icon(Icons.error_outline,
              color: Colors.red,
              size: MediaQuery.of(context).size.shortestSide * 0.1),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => Navigator.of(context).pop(0),
            ),
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blueAccent),
              ),
              onPressed: () => {
                Navigator.of(context).pop(0),
                _restoreBackup(backupFilePath).then((value) => _restoreDone()),
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _restoreBackup(String backupFilePath) async {
    try {
      AppConfig config = await AppConfig.getInstance();
      Directory baseDir = await getTemporaryDirectory();
      Directory directory = Directory(pathlib.join(
          baseDir.path, 'restores', pathlib.basename(backupFilePath)));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      await uncompress(backupFilePath, directory.path);
      await appendMails(
          config.getHost(),
          config.getPort(),
          config.getUserName(),
          config.getPassword(),
          config.getIsSecure(),
          directory.path);
    } on PreferenceNotFound catch (e) {
      return _showError(e);
    } on NotConnectable catch (e) {
      return _showError(e);
    } catch (e) {
      return _showError(e);
    }
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

  Future<void> _restoreDone() async {
    double iconSize = MediaQuery.of(context).size.shortestSide * 0.1;
    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          title: const Text('バックアップのリストアが完了しました。'),
          icon: Icon(Icons.check_outlined, color: Colors.green, size: iconSize),
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
