
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/models/call_log_model.dart';
import 'package:credlawn/helpers/database_service.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class CallHistoryScreen extends StatefulWidget {
  final String customerName;
  final String mobileNo;

  const CallHistoryScreen({super.key, required this.customerName, required this.mobileNo});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> with WidgetsBindingObserver {
  late Future<List<CallLogModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _historyFuture = _syncAndFetchLogs();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshLogs();
    }
  }

  void _refreshLogs() {
    setState(() {
      _historyFuture = _syncAndFetchLogs();
    });
  }

  Future<List<CallLogModel>> _syncAndFetchLogs() async {
    await DatabaseService.instance.callHistoryRepository.syncPhoneCallLogs();
    return DatabaseService.instance.callHistoryRepository.getLogsForNumber(widget.mobileNo);
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}h ${twoDigitMinutes}m ${twoDigitSeconds}s";
    }
    if (duration.inMinutes > 0) {
      return "${twoDigitMinutes}m ${twoDigitSeconds}s";
    }
    return "${twoDigitSeconds}s";
  }

  Widget _buildCallTypeRow(String callType, int duration) {
    IconData icon;
    Color color;
    String typeText;

    switch (callType.toUpperCase()) {
      case 'INCOMING':
        icon = Icons.call_received;
        color = Colors.green;
        typeText = 'Incoming';
        break;
      case 'OUTGOING':
        icon = Icons.call_made;
        if (duration > 0) {
          color = Colors.grey.shade600;
          typeText = 'Outgoing';
        } else {
          color = Colors.orange;
          typeText = 'CNR';
        }
        break;
      case 'MISSED':
        icon = Icons.call_missed;
        color = Colors.red;
        typeText = 'Missed';
        break;
      case 'REJECTED':
        icon = Icons.block;
        color = Colors.red;
        typeText = 'Rejected';
        break;
      default:
        icon = Icons.call;
        color = Colors.grey;
        typeText = callType.toLowerCase().capitalize();
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          duration > 0 && typeText != 'CNR' ? '$typeText, ${_formatDuration(duration)}' : typeText,
          style: GoogleFonts.poppins(color: color, fontSize: 14),
        ),
      ],
    );
  }

  String _formatTimestamp(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('h:mm a').format(dateTime);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, d MMMM').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.customerName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(widget.mobileNo, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<CallLogModel>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No call history found.'));
          } else {
            final logs = snapshot.data!;
            final groupedLogs = groupBy(logs, (CallLogModel log) {
              final date = DateTime.fromMillisecondsSinceEpoch(log.timestamp);
              return DateTime(date.year, date.month, date.day);
            });

            return ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: groupedLogs.length,
              itemBuilder: (context, index) {
                final date = groupedLogs.keys.elementAt(index);
                final logsForDate = groupedLogs[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Text(
                        _formatDateHeader(date),
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: logsForDate.length,
                        itemBuilder: (context, i) {
                          final log = logsForDate[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                            child: Row(
                              children: [
                                _buildCallTypeRow(log.callType, log.duration),
                                const Spacer(),
                                Text(_formatTimestamp(log.timestamp), style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14)),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, i) => Divider(height: 1, indent: 16, endIndent: 16, color: Colors.grey.shade200),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}

extension StringExtension on String {
    String capitalize() {
      return "${this[0].toUpperCase()}${substring(1)}";
    }
}
