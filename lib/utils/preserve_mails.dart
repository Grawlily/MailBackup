import 'package:enough_mail/enough_mail.dart';
import 'package:shared_preferences/shared_preferences.dart';

Stream<List<MimeMessage>>pagedMessageStream(ImapClient client, Mailbox box) async* {
  int pageSize = (box.messagesExists / 500).ceil();
  for (var i=0;i<pageSize;i++) {
     MessageSequence sequence = MessageSequence.fromPage(i, pageSize, box.messagesExists);
     FetchImapResult result = await client.fetchMessages(sequence, null);
     yield result.messages;
  }
}
