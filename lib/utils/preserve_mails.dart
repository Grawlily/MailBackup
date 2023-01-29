import 'dart:io';
import "package:intl/intl.dart";
import 'package:path/path.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:path_provider/path_provider.dart';

import 'package:mail_backup/utils/check_imap_connection.dart';

import 'package:mail_backup/exceptions/mails.dart';

Stream<List<MimeMessage>> pagedMessageStream(
    ImapClient client, Mailbox box) async* {
  int pageSize = (box.messagesExists / 500).ceil();
  for (int i = 1; i < pageSize + 1; i++) {
    MessageSequence sequence =
        MessageSequence.fromPage(i, pageSize, box.messagesExists);
    FetchImapResult result =
        await client.fetchMessages(sequence, 'BODY.PEEK[]');
    yield result.messages;
  }
}

Future<String> preserveMail(
    MimeMessage message, Mailbox box, String backupDirPath) async {
  File file =
      await File(join(backupDirPath, box.name, '${message.hashCode}.mlbk'))
          .create(recursive: true);
  await file.writeAsString(message.toString());
  return file.path;
}

Future<String> preserveMails(String host, int port, String userName,
    String password, bool isSecure) async {
  Directory baseDir = await getTemporaryDirectory();
  DateFormat dateFormat = DateFormat('yyyyMMdd-HHmm');
  String backupDirPath = join(baseDir.path, dateFormat.format(DateTime.now()));

  ImapClient client = ImapClient();

  final connectable =
      await checkImapConnection(host, port, userName, password, isSecure);
  if (!connectable) {
    throw NotConnectable();
  }

  await client.connectToServer(host, port, isSecure: isSecure);

  if (!isSecure) {
    await client.startTls();
  }

  await client.login(userName, password);

  List<Mailbox> mailboxes = await client.listMailboxes();
  for (Mailbox box in mailboxes) {
    await client.selectMailbox(box);
    await for (List<MimeMessage> messages in pagedMessageStream(client, box)) {
      for (MimeMessage m in messages) {
        await preserveMail(m, box, backupDirPath);
      }
    }
  }

  await client.logout();
  await client.disconnect();
  return backupDirPath;
}
