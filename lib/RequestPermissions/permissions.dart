import 'package:permission_handler/permission_handler.dart';

class permission{
 static Future<void> requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }
}