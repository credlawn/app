
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

Future<String?> getDeviceId() async {
  final prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');

  if (deviceId == null) {
    var uuid = Uuid();
    deviceId = uuid.v4();
    await prefs.setString('device_id', deviceId);
  }

  return deviceId;
}
