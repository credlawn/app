import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:credlawn/api/server_api.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ErrorLogger {
  static Future<void> logError({
    required String title,
    required String errorMessage,
    String? errorType,
    String? userId,
  }) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceInfoString = 'Unknown Device';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceInfoString = 'Android ${androidInfo.version.release} - ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceInfoString = 'iOS ${iosInfo.systemVersion} - ${iosInfo.model}';
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';

      final body = {
        'title': title,
        'error_message': errorMessage,
        'error_type': errorType ?? 'General',
        'user_id': userId ?? 'Guest',
        'device_info': '$deviceInfoString - App v$appVersion',
      };

      await http.post(
        ServerApi.appErrorLog,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );
    } catch (e) {}
  }

  static Future<void> logApiError({
    required String endpoint,
    required String method,
    required int statusCode,
    required String responseBody,
    String? userId,
  }) async {
    final title = 'API Error: $method $endpoint';
    final errorMessage = 'Status: $statusCode\nResponse: $responseBody';

    await logError(
      title: title,
      errorMessage: errorMessage,
      errorType: 'API',
      userId: userId,
    );
  }

  static Future<void> logException({
    required String context,
    required dynamic exception,
    String? userId,
  }) async {
    final title = 'Exception in $context';
    final errorMessage = exception.toString();

    await logError(
      title: title,
      errorMessage: errorMessage,
      errorType: 'Exception',
      userId: userId,
    );
  }
}
