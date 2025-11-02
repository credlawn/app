import 'package:flutter/material.dart';
import 'package:credlawn/helpers/feedback_sync_service.dart';

class AppLifecycleHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App came to foreground - sync unsynced feedback
      FeedbackSyncService.syncUnsyncedFeedback();
    }
  }

  static void initialize() {
    WidgetsBinding.instance.addObserver(AppLifecycleHandler());
  }
}
