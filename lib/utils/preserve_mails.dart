import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import "package:intl/intl.dart";
import 'package:shared_preferences/shared_preferences.dart';
import 'package:enough_mail/enough_mail.dart';

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
  await client.connectToServer(
    sp.getString('host')!,
    sp.getInt('port')!,
    isSecure: sp.getBool('isSecure')!
  );

  if (!sp.getBool('isSecure')!) {
    await client.startTls();
  }

  await client.login(
    sp.getString('username')!,
    sp.getString('password')!
  );

  List<Mailbox> mailboxes = await client.listMailboxes();
  for (var box in mailboxes) {
    await for (var msg in pagedMessageStream(client, box)) {
      for (var m in msg) {await preserveMail(m, box);}
    }
  }

  await client.logout();
  await client.disconnect();
}