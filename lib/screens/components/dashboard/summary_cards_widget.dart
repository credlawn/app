import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryCardsWidget extends StatelessWidget {
  final int ipApprovedToday;
  final int ipDeclineToday;
  final int todayLogin;
  final double approvalRate;

  const SummaryCardsWidget({
    super.key,
    required this.ipApprovedToday,
    required this.ipDeclineToday,
    required this.todayLogin,
    required this.approvalRate,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildSummaryCard(
          title: 'IP Approved',
          value: ipApprovedToday.toString(),
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        _buildSummaryCard(
          title: 'IP Decline',
          value: ipDeclineToday.toString(),
          icon: Icons.cancel,
          color: Colors.red,
        ),
        _buildSummaryCard(
          title: 'Today Login',
          value: todayLogin.toString(),
          icon: Icons.login,
          color: Colors.blue,
        ),
        _buildSummaryCard(
          title: 'Approval Rate',
          value: '${approvalRate.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
