import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../settings/settings_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _pick(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/avatar.jpg';
    await File(picked.path).copy(path);
    await FileImage(File(path)).evict();
    if (!mounted) return;
    await context.read<SettingsModel>().setAvatar(path);
  }

  Future<void> _takePhoto() async {
    final status = await Permission.camera.request();
    if (!mounted) return;
    switch (status) {
      case PermissionStatus.granted || PermissionStatus.limited:
        await _pick(ImageSource.camera);
      case PermissionStatus.permanentlyDenied:
        await _showSettingsDialog();
      case PermissionStatus.denied ||
          PermissionStatus.restricted ||
          PermissionStatus.provisional:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera access is needed to take a photo. '
              'You can still choose one from the gallery.',
            ),
          ),
        );
    }
  }

  Future<void> _showSettingsDialog() async {
    final open = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera is blocked'),
        content: const Text(
          'You said No to the camera, so Android will not ask again. '
          'Turn it on in the app settings to take a photo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
    if (open == true) {
      await openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<SettingsModel>().avatarPath;
    final file = path == null ? null : File(path);
    final hasPhoto = file != null && file.existsSync();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundImage: hasPhoto ? FileImage(file) : null,
              child: hasPhoto
                  ? null
                  : const Text('R', style: TextStyle(fontSize: 48)),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _pick(ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose photo'),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _takePhoto,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Take photo'),
            ),
          ],
        ),
      ),
    );
  }
}
