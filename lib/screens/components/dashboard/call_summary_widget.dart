import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CallSummaryWidget extends StatelessWidget {
  final int totalAttempted;
  final int totalConnected;
  final int totalDuration;
  final String averageDuration;

  const CallSummaryWidget({
    super.key,
    required this.totalAttempted,
    required this.totalConnected,
    required this.totalDuration,
    required this.averageDuration,
  });

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Call Performance Summary',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildCallSummaryItem(
            icon: Icons.phone,
            label: 'Total Attempts',
            value: totalAttempted.toString(),
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildCallSummaryItem(
            icon: Icons.call,
            label: 'Connected Calls',
            value: totalConnected.toString(),
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildCallSummaryItem(
            icon: Icons.timer,
            label: 'Total Talk Time',
            value: _formatDuration(totalDuration),
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildCallSummaryItem(
            icon: Icons.av_timer,
            label: 'Avg Call Duration',
            value: averageDuration,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }

  Widget _buildCallSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
