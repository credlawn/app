import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          SizedBox(
            height: 36,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    _buildLeadGroupChip('New Leads', Colors.green, FontAwesomeIcons.userPlus),
                    const SizedBox(width: 8),
                    _buildLeadGroupChip('Called', Colors.teal, FontAwesomeIcons.phoneVolume),
                    const SizedBox(width: 8),
                    _buildLeadGroupChip('CNR Leads', Colors.orange, FontAwesomeIcons.phoneSlash),
                    const SizedBox(width: 8),
                    _buildLeadGroupChip('Login', Colors.teal, FontAwesomeIcons.signInAlt),
                    const SizedBox(width: 8),
                    _buildLeadGroupChip('Used Leads', Colors.indigo, FontAwesomeIcons.checkCircle),
                    const SizedBox(width: 8),
                    _buildLeadGroupChip('Follow Up', Colors.blue, FontAwesomeIcons.calendarCheck),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildLeadGroupChip(String title, Color color, IconData icon) {
    final isSelected = selectedGroup == title;
    return InkWell(
      onTap: () {
        onGroupSelected(title);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
