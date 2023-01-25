import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mail_backup/screens/dump_backup.dart';
import 'package:mail_backup/screens/restore_backup.dart';
import 'package:mail_backup/screens/settings.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      routes: <String, WidgetBuilder>{
        '/settings': (BuildContext context) => const Settings(),
      },
      home: const MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mail Backup'),
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(icon: Icon(Icons.backup_outlined)),
              Tab(icon: Icon(Icons.restore_outlined)),
            ],
          ),
        ),
        drawer: SafeArea(
          child: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    image: const DecorationImage(
                      image: AssetImage(
                        'assets/grawlily_header.png',
                      ),
                      fit: BoxFit.fill,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      Text(
                        'MailBackup v0.1.0',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.black87
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: const Text(
                    'Settings',
                    style: TextStyle(color: Colors.grey),
                  ),
                  leading: const Icon(Icons.settings),
                  trailing: const Icon(Icons.arrow_forward_outlined),
                  onTap: () => Navigator.of(context).pushNamed('/settings'),
                ),
              ],
            ),
          ),
        ),
        body: const TabBarView(
          children: <Widget>[
            Backup(),
            Restore(),
          ],
        ),
      ),
    );
  }
}
