import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mail_backup/repositories/app_config.dart';
import 'package:mail_backup/utils/check_imap_connection.dart';

import '../utils/preserve_mails.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

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
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mailServerController = TextEditingController();
  final TextEditingController _portNumberController =
      TextEditingController(text: '993');
  bool _isSecure = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _body(),
      resizeToAvoidBottomInset: false,
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text('IMAP設定'),
    );
  }

  Widget _body() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Column(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: _userNameController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.account_circle_outlined),
                    hintText: 'ユーザー名を入力してください。',
                    labelText: 'ユーザー名',
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: _passwordController,
                  maxLines: 1,
                  obscureText: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.password_outlined),
                    hintText: 'パスワードを入力してください。',
                    labelText: 'パスワード',
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: _mailServerController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.mail_outline_outlined),
                    hintText: 'メールサーバーを入力してください。',
                    labelText: 'メールサーバー',
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: TextField(
                  controller: _portNumberController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  maxLines: 1,
                  maxLength: 5,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.numbers_outlined),
                    hintText: 'ポート番号を入力してください。',
                    labelText: 'ポート番号',
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.height * 0.01),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: ButtonTheme(
                  alignedDropdown: true,
                  child: DropdownButtonFormField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.https_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: true,
                        child: Text('TLS'),
                      ),
                      DropdownMenuItem(
                        value: false,
                        child: Text('STARTTLS'),
                      ),
                    ],
                    value: _isSecure,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSecure = value ?? true;
                      });
                    },
                  ),
                ),
              )
            ],
          ),
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                OutlinedButton(
                  onPressed: () async {
                    await _checkConnection();
                  },
                  child: const Text('テスト接続'),
                ),
                Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                ),
                const Divider(),
                Padding(
                  padding:
                      EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await _saveSettings();
                  },
                  child: const Text('設定を保存'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkConnection() async {
    double iconSize = MediaQuery.of(context).size.shortestSide * 0.1;
    bool result = await checkImapConnection(
        _mailServerController.text.trim(),
        int.parse(_portNumberController.text.trim()),
        _userNameController.text.trim(),
        _passwordController.text.trim(),
        _isSecure);
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          title: result
              ? const Text(
                  '接続に成功しました。',
                )
              : const Text('接続に失敗しました。'),
          icon: result
              ? Icon(Icons.info_outline, color: Colors.green, size: iconSize)
              : Icon(Icons.error_outline, color: Colors.red, size: iconSize),
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
  }

  Future<void> _saveSettings() async {
    double iconSize = MediaQuery.of(context).size.shortestSide * 0.1;
    AppConfig config = await AppConfig.getInstance();
    config.host = _mailServerController.text.trim();
    config.port = int.parse(_portNumberController.text.trim());
    config.userName = _userNameController.text.trim();
    config.password = _passwordController.text.trim();
    config.isSecure = _isSecure;
    await config.save();

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return AlertDialog(
          title: const Text('接続設定を保存しました。'),
          icon: Icon(Icons.check_outlined, color: Colors.green, size: iconSize),
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
  }

  Future<void> _loadSettings() async {
    AppConfig config = await AppConfig.getInstance();
    _mailServerController.text = config.host ?? _mailServerController.text;
    _userNameController.text = config.userName ?? _userNameController.text;
    _passwordController.text = config.password ?? _passwordController.text;
    _portNumberController.text = config.port != null
        ? config.port.toString()
        : _portNumberController.text;
    _isSecure = config.isSecure ?? true;
  }
}
