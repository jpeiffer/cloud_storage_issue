import 'dart:io';

String relativePath(File file, Directory baseDir) {
  final base = baseDir.absolute.path;
  final path = file.absolute.path.substring(base.length + 1);

  return path;
}
