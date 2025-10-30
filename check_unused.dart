import 'dart:io';
import 'package:yaml/yaml.dart';

void main() async {
  final pubspec = File('pubspec.yaml');
  final libDir = Directory('lib');

  if (!pubspec.existsSync()) {
    print('❌ pubspec.yaml not found in current directory.');
    exit(1);
  }

  if (!libDir.existsSync()) {
    print('❌ lib/ folder not found.');
    exit(1);
  }

  final yamlContent = loadYaml(await pubspec.readAsString());
  final deps = <String>[];

  // extract both dependencies and dev_dependencies (if any)
  if (yamlContent['dependencies'] != null) {
    deps.addAll(yamlContent['dependencies'].keys.cast<String>());
  }
  if (yamlContent['dev_dependencies'] != null) {
    deps.addAll(yamlContent['dev_dependencies'].keys.cast<String>());
  }

  // exclude flutter and sdk-only dependencies
  final filteredDeps = deps.where((d) =>
      d != 'flutter' &&
      d != 'sdk' &&
      !d.startsWith('flutter_test') &&
      !d.startsWith('flutter_lints')).toList();

  final used = <String>[];
  final unused = <String>[];

  for (final dep in filteredDeps) {
    final searchPattern = "import 'package:$dep/";
    bool found = false;

    await for (final entity
        in libDir.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final content = await entity.readAsString();
        if (content.contains(searchPattern)) {
          found = true;
          break;
        }
      }
    }

    if (found) {
      used.add(dep);
    } else {
      unused.add(dep);
    }
  }

  print('\n✅ USED PACKAGES (${used.length}):');
  for (var d in used) {
    print('  • $d');
  }

  print('\n⚠️ UNUSED PACKAGES (${unused.length}):');
  for (var d in unused) {
    print('  • $d');
  }

  print('\n📊 Total checked: ${filteredDeps.length}');
}
