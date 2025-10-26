
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiFcmHelper {
  static Future<void> sendFcmTokenToServer(String token, String userId) async {
    // TODO: Replace with your actual API endpoint
    var url = Uri.parse('https://your-frappe-site.com/api/method/your_app.api.save_fcm_token');

    var body = json.encode({
      'fcm_token': token,
      'user': userId,
      // 'device_id': 'some_unique_device_id' // Optional
    });

    try {
      var response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // TODO: Add your authorization header if needed
          // "Authorization": "Bearer YOUR_AUTH_TOKEN"
        },
        body: body,
      );

      if (response.statusCode == 200) {
        print('FCM token sent to server successfully.');
      } else {
        print('Failed to send FCM token to server. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM token to server: $e');
    }
  }
}
