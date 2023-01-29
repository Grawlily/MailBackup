import 'dart:io';
import 'package:collection/collection.dart';
import 'package:enough_mail/enough_mail.dart';
import 'package:path/path.dart';

import 'package:mail_backup/exceptions/mails.dart';
import 'check_imap_connection.dart';

Future<MimeMessage> parseMail(String mailFilePath) async {
  File file = File(mailFilePath);
  String content = await file.readAsString();
  return MimeMessage.parseFromText(content);
}

Future<void> appendMails(String host, int port, String userName,
    String password, bool isSecure, String backupDirectoryPath) async {
  ImapClient client = ImapClient();
  final bool connectable =
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

  await for (FileSystemEntity entry in Directory(backupDirectoryPath)
      .list(recursive: true, followLinks: false)) {
    String boxName = basename(entry.parent.path);
    Mailbox? targetBox;

    if (await FileSystemEntity.isDirectory(entry.path)) {
      continue;
    }
    targetBox ??= mailboxes.firstWhereOrNull((box) => box.name == boxName);
    targetBox ??= await client.createMailbox(boxName);

    MimeMessage message = await parseMail(entry.path);
    await client.appendMessage(message, targetMailbox: targetBox);
  }
}
