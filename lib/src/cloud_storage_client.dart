import 'dart:io';

import 'package:cloud_storage_issue/cloud_storage_issue.dart';
import 'package:googleapis/storage/v1.dart' as storage;
import 'package:googleapis_auth/auth_io.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class CloudStorageClient {
  CloudStorageClient({
    required this.bucket,
    List<String> scopes = const [
      'https://www.googleapis.com/auth/userinfo.email',
      storage.StorageApi.devstorageReadWriteScope,
    ],
    required String serviceAccount,
    String storageRootUrl = 'https://storage.googleapis.com/',
  })  : _client = clientViaServiceAccount(
          ServiceAccountCredentials.fromJson(serviceAccount),
          scopes,
        ),
        _storageRootUrl = storageRootUrl;

  static final Logger _logger = Logger('CloudStorageClient');

  final String bucket;

  final Future<AutoRefreshingAuthClient> _client;
  final String _storageRootUrl;

  Future<void> read(String path, Directory outDir) async {
    final client = await _client;
    final api = storage.StorageApi(
      client,
      rootUrl: _storageRootUrl,
    );

    final dynamic result = await api.objects.get(
      bucket,
      path,
      downloadOptions: storage.DownloadOptions.fullMedia,
    );

    final data = await result.stream.toBytes();

    final file = File('${outDir.path}/$path');
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsBytesSync(data);
  }

  Future<void> write(
    File file,
    Directory baseDir,
  ) async {
    final path = relativePath(file, baseDir);

    final contents = file.readAsBytesSync();
    final client = await _client;

    final api = storage.StorageApi(
      client,
      rootUrl: _storageRootUrl,
    );

    final contentType =
        lookupMimeType(p.basename(path)) ?? 'application/octet-stream';
    final object = storage.Object();
    object.bucket = bucket;
    object.name = path;
    object.contentType = contentType;

    final media = storage.Media(
      Stream.fromFuture(Future.value(contents)),
      contents.length,
      contentType: contentType,
    );
    await api.objects.insert(
      object,
      bucket,
      uploadMedia: media,
    );

    _logger.fine({
      'message': 'Wrote cloud storage: [$path]',
    });
  }
}
