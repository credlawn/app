import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ConversionFunnelWidget extends StatelessWidget {
  final int totalLeads;
  final int calledLeads;
  final int connectedLeads;
  final int feedbackGiven;
  final int approvedLeads;

  const ConversionFunnelWidget({
    super.key,
    required this.totalLeads,
    required this.calledLeads,
    required this.connectedLeads,
    required this.feedbackGiven,
    required this.approvedLeads,
  });

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
            'Conversion Funnel',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          _buildFunnelStep(
            label: 'Total Leads',
            count: totalLeads,
            percentage: 100.0,
            color: Colors.blue,
            widthFactor: 1.0,
          ),
          _buildFunnelConnector(),
          _buildFunnelStep(
            label: 'Called',
            count: calledLeads,
            percentage: totalLeads > 0 ? (calledLeads / totalLeads) * 100 : 0,
            color: Colors.orange,
            widthFactor: 0.8,
          ),
          _buildFunnelConnector(),
          _buildFunnelStep(
            label: 'Connected',
            count: connectedLeads,
            percentage: totalLeads > 0 ? (connectedLeads / totalLeads) * 100 : 0,
            color: Colors.green,
            widthFactor: 0.6,
          ),
          _buildFunnelConnector(),
          _buildFunnelStep(
            label: 'Feedback Given',
            count: feedbackGiven,
            percentage: totalLeads > 0 ? (feedbackGiven / totalLeads) * 100 : 0,
            color: Colors.purple,
            widthFactor: 0.4,
          ),
          _buildFunnelConnector(),
          _buildFunnelStep(
            label: 'Approved',
            count: approvedLeads,
            percentage: totalLeads > 0 ? (approvedLeads / totalLeads) * 100 : 0,
            color: Colors.teal,
            widthFactor: 0.4,
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelStep({
    required String label,
    required int count,
    required double percentage,
    required Color color,
    required double widthFactor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              height: 32,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Center(
                  child: Text(
                    '$count (${percentage.round()}%)',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelConnector() {
    return Container(
      height: 8,
      alignment: Alignment.center,
      child: Icon(
        Icons.arrow_downward,
        size: 16,
        color: Colors.grey.shade400,
      ),
    );
  }
}
