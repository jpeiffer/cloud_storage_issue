import 'dart:io';

import 'package:cloud_storage_issue/cloud_storage_issue.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

class Deployer {
  static Future<void> deploy({
    required String serviceAccount,
    String storageUrl = 'http://localhost:9199/',
    String storageBucket = 'fake-server.appspot.com',
  }) async {
    final logger = Logger('Deployer');

    final csDir = Directory('./data');

    logger.info('[STORAGE BUCKET]: [$storageBucket]');
    logger.info('[STORAGE URL]: [$storageUrl]');

    if (!csDir.existsSync()) {
      throw Exception(
          'Unable to locate cloud storage data directory: [$csDir]');
    }

    final csFiles = csDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((e) => !p.basename(e.path).startsWith('.'));

    final client = CloudStorageClient(
      bucket: storageBucket,
      serviceAccount: serviceAccount,
      storageRootUrl: storageUrl,
    );

    for (var file in csFiles) {
      await client.write(file, csDir);
    }

    final outDir = Directory('output');
    if (outDir.existsSync()) {
      outDir.deleteSync(recursive: true);
    }

    for (var file in csFiles) {
      await client.read(relativePath(file, csDir), outDir);
    }
  }
}
