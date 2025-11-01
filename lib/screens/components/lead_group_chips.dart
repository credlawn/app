import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LeadGroupChips extends StatelessWidget {
  final String selectedGroup;
  final Function(String) onGroupSelected;

  const LeadGroupChips({
    super.key,
    required this.selectedGroup,
    required this.onGroupSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLeadGroupChip('New Leads', Colors.green),
          const SizedBox(width: 8),
          _buildLeadGroupChip('CNR Leads', Colors.orange),
          const SizedBox(width: 8),
          _buildLeadGroupChip('Used Leads', Colors.purple),
        ],
      ),
    );
  }

  Widget _buildLeadGroupChip(String title, Color color) {
    return InkWell(
      onTap: () {
        onGroupSelected(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selectedGroup == title ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selectedGroup == title ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
