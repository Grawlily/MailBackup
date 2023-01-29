import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';

Future<void> compress(String directoryPath, String outFilePath) async {
  ZipFileEncoder encoder = ZipFileEncoder();
  encoder.create(outFilePath);

  await for (FileSystemEntity entry
      in Directory(directoryPath).list(recursive: true, followLinks: false)) {
    if (await FileSystemEntity.isDirectory(entry.path)) {
      await encoder.addDirectory(Directory(entry.path));
    }
  }
  encoder.close();
}

Future<void> uncompress(String archiveFilePath, String outDirectoryPath) async {
  Archive archive = ZipDecoder().decodeBuffer(InputFileStream(archiveFilePath));

  for (ArchiveFile file in archive.files) {
    final filePath = join(outDirectoryPath, file.name);
        '${Directory(outDirectoryPath)}${Platform.pathSeparator}${file.name}';
    File output = File(filePath);
    await output.create(recursive: true);

    RandomAccessFile randomAccessFile =
        await output.open(mode: FileMode.writeOnly);
    await randomAccessFile.writeFrom(file.content as List<int>);

    file.clear();
    await randomAccessFile.close();
  }
}
