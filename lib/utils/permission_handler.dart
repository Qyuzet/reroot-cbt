import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  // Check and request flashlight permission
  static Future<bool> requestFlashlightPermission(BuildContext context) async {
    var status = await Permission.camera.status;
    
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    
    if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Camera Permission Required',
          'Flashlight requires camera permission. Please enable it in app settings.',
        );
      }
      return false;
    }
    
    return status.isGranted;
  }
  
  // Check and request audio permission (if needed on the platform)
  static Future<bool> requestAudioPermission(BuildContext context) async {
    // On some platforms, audio playback might not require explicit permission
    // But we'll include this for completeness
    
    var status = await Permission.microphone.status;
    
    if (status.isDenied) {
      status = await Permission.microphone.request();
    }
    
    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Microphone Permission Required',
          'Audio features require microphone permission. Please enable it in app settings.',
        );
      }
      return false;
    }
    
    return status.isGranted;
  }
  
  // Show permission dialog
  static void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }
}
