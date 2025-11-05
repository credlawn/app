import 'package:flutter/material.dart';
import 'package:credlawn/screens/components/lead_list_item.dart';
import 'package:credlawn/helpers/lead_data_helper.dart';
import 'package:credlawn/models/leads_model.dart'; // Import LeadsModel

class LeadList extends StatelessWidget {
  final List<LeadWithCallInfo> leads;
  final String? expandedLeadId;
  final Function(String) onExpandItem;
  final VoidCallback onNavigate;
  final Function(LeadsModel lead) onCallPressed; // New callback
  final String selectedLeadGroup;

  const LeadList({
    super.key,
    required this.leads,
    required this.expandedLeadId,
    required this.onExpandItem,
    required this.onNavigate,
    required this.onCallPressed, // Required for the new callback
    required this.selectedLeadGroup,
  });

  @override
  Widget build(BuildContext context) {
    if (leads.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          ...leads.map((leadWithInfo) {
            return Column(
              children: [
                LeadListItem(
                  leadWithInfo: leadWithInfo,
                  isExpanded: expandedLeadId == leadWithInfo.lead.mobileNo,
                  onTap: () => onExpandItem(leadWithInfo.lead.mobileNo),
                  onNavigate: onNavigate,
                  onCallPressed: onCallPressed, // Pass the callback down
                  selectedLeadGroup: selectedLeadGroup,
                ),
                if (leadWithInfo != leads.last)
                  Container(
                    height: 0.5,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                  ),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
