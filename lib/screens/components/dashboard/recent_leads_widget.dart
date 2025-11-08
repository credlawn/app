import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/helpers/lead_data_helper.dart';
import 'package:credlawn/screens/customer_details_screen.dart';

class RecentLeadsWidget extends StatelessWidget {
  final List<LeadWithCallInfo> recentLeads;

  const RecentLeadsWidget({
    super.key,
    required this.recentLeads,
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
            'Recent Leads',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLeads.length,
            itemBuilder: (context, index) {
              final leadWithInfo = recentLeads[index];
              return _buildRecentLeadItem(leadWithInfo, context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLeadItem(LeadWithCallInfo leadWithInfo, BuildContext context) {
    final lead = leadWithInfo.lead;

    Color statusColor;
    switch (lead.leadStatus) {
      case 'New':
        statusColor = Colors.blue;
        break;
      case 'Called':
        statusColor = Colors.green;
        break;
      case 'Failed':
      case 'Customer Denied':
      case 'Docs Not Available':
        statusColor = Colors.red;
        break;
      case 'IP Approved':
      case 'IP Decline':
        statusColor = Colors.orange;
        break;
      case 'Follow up':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.grey;
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      title: Text(
        lead.customerName,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Container(
        padding: const EdgeInsets.only(top: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: IntrinsicWidth(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 100, minWidth: 50),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lead.leadStatus ?? 'Unknown',
                style: GoogleFonts.poppins(
                  fontSize: 9,
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${leadWithInfo.callCount} calls',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          if (leadWithInfo.lastCallDuration != null && leadWithInfo.lastCallDuration! > 0)
            Text(
              '${leadWithInfo.lastCallDuration}s',
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: Colors.grey.shade500,
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerDetailsScreen(mobileNo: lead.mobileNo),
          ),
        );
      },
    );
  }
}
