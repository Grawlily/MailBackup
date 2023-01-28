import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import "package:intl/intl.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mail_backup/utils/check_imap_connection.dart';
import 'package:mail_backup/repositories/shared_preferences_util.dart';
import 'package:enough_mail/enough_mail.dart';

class NotConnectable implements Exception {
  NotConnectable();
}

Stream<List<MimeMessage>> pagedMessageStream(ImapClient client, Mailbox box) async* {
  int pageSize = (box.messagesExists / 500).ceil();
  for (var i=0;i<pageSize;i++) {
     MessageSequence sequence = MessageSequence.fromPage(i, pageSize, box.messagesExists);
     FetchImapResult result = await client.fetchMessages(sequence, null);
     yield result.messages;
  }
}

Future<String> preserveMail(MimeMessage message, Mailbox box) async {
  Directory baseDir = await getApplicationDocumentsDirectory();
  DateFormat dateFormat = DateFormat('yyyyMMdd-HHmm');
  String backupDirPath = join(baseDir.path, dateFormat.format(DateTime.now()));

  File file = await File(join(backupDirPath, box.name, '${message.internalDate}.mlbk')).create();
  await file.writeAsString(message.toString());
  return file.path;
}

Future<void> preserveMails() async {
  ImapClient client = ImapClient();
  SharedPreferences sp = await SharedPreferences.getInstance();
  String host = getStringSafe(sp, 'host');
  int port = getIntSafe(sp, 'port');
  bool isSecure = getBoolSafe(sp, 'isSecure');
  String username = getStringSafe(sp, 'username');
  String password = getStringSafe(sp, 'password');

  final connectable = await checkImapConnection(host, port, username, password, isSecure);
  if (!connectable) {
    throw NotConnectable();
  }

  await client.connectToServer(host, port, isSecure: isSecure);

  if (isSecure) {
    await client.startTls();
  }

  await client.login(username, password);

  List<Mailbox> mailboxes = await client.listMailboxes();
  for (var box in mailboxes) {
    await for (var msg in pagedMessageStream(client, box)) {
      for (var m in msg) {await preserveMail(m, box);}
    }
  }
  
  await client.logout();
  await client.disconnect();
}