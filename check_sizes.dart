import 'dart:io';

void main() {
  final dir = Directory('lib/features/parent/espace_enfant');
  final files = dir.listSync(recursive: true).whereType<File>().toList();
  files.sort((a, b) => b.lengthSync().compareTo(a.lengthSync()));
  
  for (var file in files) {
    print('${file.path}: ${file.lengthSync()} bytes');
  }
}
