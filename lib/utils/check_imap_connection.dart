import 'dart:io';

import 'package:enough_mail/enough_mail.dart';
import 'package:flutter/foundation.dart';

Future<bool> checkImapConnection(String host, int port, String userName,
    String password, bool isSecure) async {
  final client = ImapClient(isLogEnabled: false);
  try {
    await client.connectToServer(host, port, isSecure: isSecure);
    if (!isSecure) {
      await client.startTls();
    }
    await client.login(userName, password);
    await client.logout();
    return true;
  } on ImapException catch (e) {
    if (kDebugMode) print(e);
    return false;
  } on SocketException catch (e) {
    if (kDebugMode) print(e);
    return false;
  }
}
