import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<void> compress(String directoryPath, String outFilePath) async {
  ZipFileEncoder encoder = ZipFileEncoder();
  encoder.create(outFilePath);

  await for (FileSystemEntity entry in Directory(directoryPath).list(recursive: true, followLinks: false)) {
    if (await FileSystemEntity.isDirectory(entry.path)) {
      await encoder.addDirectory(Directory(entry.path));
    }
  }
  encoder.close();
}

Future<String> uncompress(String archiveFilePath, String outFilePath) async {
  Archive archive = ZipDecoder().decodeBuffer(InputFileStream(archiveFilePath));

  Directory temporaryDirectory = await getTemporaryDirectory();
  Directory directory =
      Directory(join(temporaryDirectory.path, basename(archiveFilePath)));

  for (ArchiveFile file in archive.files) {
    final filePath = '$directory${Platform.pathSeparator}${file.name}';
    File output = File(filePath);
    await output.create(recursive: true);

    RandomAccessFile randomAccessFile =
        await output.open(mode: FileMode.writeOnly);
    await randomAccessFile.writeFrom(file.content as List<int>);

    file.clear();
    await randomAccessFile.close();
  }
  return directory.path;
}
