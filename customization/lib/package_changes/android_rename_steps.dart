import 'dart:async';
import 'dart:io';

import 'package:customization/customization.dart' show AppEnv;
import 'package:path/path.dart' as path;

import 'file_utils.dart';

class AndroidRenameSteps {
  final String newPackageName;
  String? oldPackageName;
  String fileExtension = 'kotlin/';
  Map<String, String> data;

  final String PATH_BUILD_GRADLE;
  static const String PATH_MANIFEST = 'android/app/src/main/AndroidManifest.xml';
  static const String PATH_MANIFEST_DEBUG = 'android/app/src/debug/AndroidManifest.xml';
  static const String PATH_MANIFEST_PROFILE = 'android/app/src/profile/AndroidManifest.xml';

  static const String PATH_ACTIVITY = 'android/app/src/main/';

  AndroidRenameSteps(
      this.newPackageName,
      this.PATH_BUILD_GRADLE, {
        required this.data,
      });

  Future<void> process() async {
    if (!await File(PATH_BUILD_GRADLE).exists()) {
      print(
          'ERROR:: build.gradle file not found, Check if you have a correct android directory present in your project'
              '\n\nrun " flutter create . " to regenerate missing files.');
      return;
    }

    String? oldpackage = await AppEnv.checkAndChangeContent(
        filePath: PATH_BUILD_GRADLE,
        regexStr: 'namespace \"(.*)\"',
        replaceableString: this.newPackageName ?? '',
        isReplaceAll: true);
    if (oldpackage != newPackageName) {
      var mText = 'package="$newPackageName">';
      var mRegex = '(package=.*)';

      await replaceInFileRegex(PATH_MANIFEST, mRegex, mText);
      await replaceInFileRegex(PATH_MANIFEST_DEBUG, mRegex, mText);
      await replaceInFileRegex(PATH_MANIFEST_PROFILE, mRegex, mText);
      fileExtension = 'kotlin/';
      await relocateAndroidPackage(PATH_ACTIVITY + 'kotlin/' + oldpackage!.replaceAll('.', '/'),
          PATH_ACTIVITY + 'kotlin/' + newPackageName);
      fileExtension = 'graphql/';
      await relocateAndroidPackage(PATH_ACTIVITY + 'graphql/' + oldpackage.replaceAll('.', '/'),
          PATH_ACTIVITY + 'graphql/' + newPackageName);
    }
  }

  Future<void> relocateAndroidPackage(String? oldPackage, String newPackage) async {
    String updatepackage = newPackage.replaceAll('.', '/');
    print("Relocating package from $oldPackage → $updatepackage");
    if (oldPackage != updatepackage) {
      newPackage = newPackage.replaceAll('.', '/');
      await movePackageFiles(oldPackage!, newPackage);
      if (fileExtension != 'graphql/')
        await updatePackageImports(
            androidSrcPath: PATH_ACTIVITY + fileExtension, oldPackage: oldPackage, newPackage: newPackage);
      await deleteOldPackage(oldPackage);
      print("✔ Successfully relocated package");
    }
  }

  Future<void> movePackageFiles(String oldPath, String newPath) async {
    final oldDir = Directory(oldPath);

    if (!await oldDir.exists()) {
      print("Old package does not exist → $oldPath");
      return;
    }

    final newDir = Directory(newPath);
    if (!await newDir.exists()) {
      await newDir.create(recursive: true);
    }

    final oldRoot = oldDir.path;

    await for (var entity in oldDir.list(recursive: true)) {
      if (entity is File) {
        // 1️⃣ Get relative path inside the old package
        final relative = path.relative(entity.path, from: oldRoot);

        // 2️⃣ Build destination path (preserve subfolders)
        final destPath = path.join(newPath, relative);

        // 3️⃣ Ensure destination folder exists
        final destDir = Directory(path.dirname(destPath));
        if (!await destDir.exists()) {
          await destDir.create(recursive: true);
        }

        // 4️⃣ Copy the file
        await entity.copy(destPath);
        print("Moved: ${entity.path} → $destPath");
      }
    }

    print("All Kotlin files moved from $oldPath → $newPath");
  }

  Future<void> updatePackageImports({
    required String androidSrcPath, // typically android/app/src/main/kotlin
    required String oldPackage,
    required String newPackage,
  }) async {
    final srcDir = Directory(androidSrcPath);

    if (!await srcDir.exists()) {
      print("❌ Source directory not found: $androidSrcPath");
      return;
    }

    print("🔍 Updating packages in: $androidSrcPath");

    await for (var entity in srcDir.list(recursive: true)) {
      if (entity is File) {
        final ext = path.extension(entity.path);

        // only update Kotlin + Java files
        if (ext == ".kt" || ext == ".java") {
          await replaceInFileRegex(entity.path, r'^(package (?:\.|\w)+)', "package ${newPackageName}");

          final oldImport = oldPackage.replaceAll(androidSrcPath, '').replaceAll("/", '.');
          print("🔍 oldImport on packages in: $oldImport");
          final importRegex = 'import\\s+$oldImport';

          await replaceInFileRegex(
            entity.path,
            importRegex,
            'import $newPackageName',
          );
        }
      }
    }

    print("🎉 Package updated from $oldPackage → $newPackage");
  }

  Future<void> deleteOldPackage(String oldPackageName) async {
    final dir = Directory(oldPackageName);

    if (!await dir.exists()) {
      print("❌ Directory does not exist: $oldPackageName");
      return;
    }

    // Delete the folder
    print("🗑️ Deleting: $oldPackageName");
    await dir.delete(recursive: true);

    // Now go one level up
    final parentDir = Directory(path.dirname(oldPackageName));

    // Stop when reaching kotlin folder
    if (path.normalize(parentDir.path) == path.normalize(PATH_ACTIVITY + fileExtension)) {
      print("⛔ Stop deleting (reached Kotlin root) → ${parentDir.path}");
      return;
    }

    // Delete parent only if empty
    if (await parentDir.exists()) {
      final items = await parentDir.list().toList();

      final filteredItems = items.where((item) {
        final name = path.basename(item.path);
        return name != '.DS_Store'; // ignore macOS file
      }).toList();

      if (filteredItems.isEmpty) {
        print("🧹 Parent is empty, deleting: ${parentDir.path}");

        // delete .DS_Store if exists
        for (final item in items) {
          if (path.basename(item.path) == '.DS_Store') {
            await item.delete();
          }
        }

        await deleteOldPackage(parentDir.path);
      } else {
        print("📁 Parent not empty → stop cleaning: ${parentDir.path}");
      }
    }
  }

}
