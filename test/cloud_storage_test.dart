import 'dart:convert';
import 'dart:io';

import 'package:cloud_storage_issue/cloud_storage_issue.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() async {
  recordStackTraceAtLevel = Level.WARNING;

  Logger.root.level = Level.ALL;

  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print(
      '[${record.loggerName}]: ${record.level.name}: ${record.time}: ${record.message}',
    );
    if (record.error != null) {
      // ignore: avoid_print
      print('${record.error}');
    }
    if (record.stackTrace != null) {
      // ignore: avoid_print
      print('${record.stackTrace}');
    }
  });

  setUpAll(() async {
    final csUrl =
        Platform.environment['STORAGE_URL'] ?? 'http://localhost:9199/';
    final bucket =
        Platform.environment['STORAGE_BUCKET'] ?? 'fake-server.appspot.com';
    final serviceAccount = Platform.environment['FIREBASE_SERVICE_ACCOUNT'] ??
        File('service_account.json').readAsStringSync();

    await Deployer.deploy(
      serviceAccount: serviceAccount,
      storageBucket: bucket,
      storageUrl: csUrl,
    );
  });

  final baseDir = Directory('data');
  final files = baseDir.listSync().whereType<File>().where(
        (f) => !p.basename(f.path).startsWith('.'),
      );

  final outDir = Directory('output');
  for (var file in files) {
    final path = relativePath(
      file,
      baseDir,
    );
    test('content matches: [$path]', () {
      final src = file.readAsBytesSync();
      final dst = File('${outDir.path}/$path').readAsBytesSync();

      final text = path.endsWith('.json') ||
          path.endsWith('.txt') ||
          path.endsWith('.yaml');

      if (text) {
        expect(
          utf8.decode(dst),
          utf8.decode(src),
        );
      } else {
        expect(src, dst);
      }
    });

    test('content not base64: [$path]', () {
      var passed = false;
      try {
        final src = file.readAsBytesSync();
        final dst = base64.decode(
          File('${outDir.path}/$path').readAsStringSync().trim(),
        );

        final text = path.endsWith('.json') ||
            path.endsWith('.txt') ||
            path.endsWith('.yaml');

        if (text) {
          expect(
            utf8.decode(dst),
            utf8.decode(src),
          );
        } else {
          expect(src, dst);
        }
      } catch (e) {
        passed = true;
      }

      expect(
        passed,
        true,
      );
    });
  }
}
