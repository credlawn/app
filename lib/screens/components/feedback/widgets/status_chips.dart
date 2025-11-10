import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/helpers/error_logger.dart';
import 'package:credlawn/helpers/session_manager.dart';

class StatusChips extends StatelessWidget {
  final String? selectedStatus;
  final Function(String?) onStatusChanged;
  final List<String> statusOptions;

  const StatusChips({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.statusOptions,
  });



  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 22.0,
      runSpacing: 10.0,
      children: statusOptions.map((String status) {
        final chipWidth = (MediaQuery.of(context).size.width - 30 - 12) * 0.42;

        // Define color schemes for each status type
        Color backgroundColor, selectedColor, borderColor, textColor;
        IconData? icon;

        switch (status) {
          case 'IP Approved':
            backgroundColor = Colors.green.shade50.withOpacity(0.5);
            selectedColor = Colors.green.shade600;
            borderColor = Colors.green.shade100;
            textColor = Colors.green.shade800;
            icon = Icons.check_circle_outline;
            break;
          case 'IP Decline':
            backgroundColor = Colors.red.shade50.withOpacity(0.5);
            selectedColor = Colors.red.shade600;
            borderColor = Colors.red.shade100;
            textColor = Colors.red.shade800;
            icon = Icons.cancel_outlined;
            break;
          case 'Customer Denied':
            backgroundColor = Colors.orange.shade50.withOpacity(0.5);
            selectedColor = Colors.orange.shade600;
            borderColor = Colors.orange.shade100;
            textColor = Colors.orange.shade800;
            icon = Icons.block_outlined;
            break;
          case 'Docs Not Available':
            backgroundColor = Colors.blue.shade50.withOpacity(0.5);
            selectedColor = Colors.blue.shade600;
            borderColor = Colors.blue.shade100;
            textColor = Colors.blue.shade800;
            icon = Icons.description_outlined;
            break;
          case 'Already Carded':
            backgroundColor = Colors.purple.shade50.withOpacity(0.5);
            selectedColor = Colors.purple.shade600;
            borderColor = Colors.purple.shade100;
            textColor = Colors.purple.shade800;
            icon = Icons.credit_card_outlined;
            break;
          case 'Recently Applied':
            backgroundColor = Colors.teal.shade50.withOpacity(0.5);
            selectedColor = Colors.teal.shade600;
            borderColor = Colors.teal.shade100;
            textColor = Colors.teal.shade800;
            icon = Icons.history_outlined;
            break;
          case 'Follow up':
            backgroundColor = Colors.indigo.shade50.withOpacity(0.5);
            selectedColor = Colors.indigo.shade600;
            borderColor = Colors.indigo.shade100;
            textColor = Colors.indigo.shade800;
            icon = Icons.access_time_outlined;
            break;
          case 'Hold':
            backgroundColor = Colors.amber.shade50.withOpacity(0.5);
            selectedColor = Colors.amber.shade600;
            borderColor = Colors.amber.shade100;
            textColor = Colors.amber.shade800;
            icon = Icons.pause_circle_outline;
            break;
          case 'Voicemail':
            backgroundColor = Colors.cyan.shade50.withOpacity(0.5);
            selectedColor = Colors.cyan.shade600;
            borderColor = Colors.cyan.shade100;
            textColor = Colors.cyan.shade800;
            icon = Icons.voicemail_outlined;
            break;
          case 'Not Eligible':
            backgroundColor = Colors.grey.shade50.withOpacity(0.5);
            selectedColor = Colors.grey.shade600;
            borderColor = Colors.grey.shade100;
            textColor = Colors.grey.shade800;
            icon = Icons.not_interested_outlined;
            break;
          default:
            backgroundColor = Colors.grey.shade100;
            selectedColor = CustomColor.MainColor;
            borderColor = Colors.grey.shade200;
            textColor = Colors.black54;
            icon = null;
        }

        return SizedBox(
          width: chipWidth,
          child: ChoiceChip(
            label: Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 14, color: selectedStatus == status ? Colors.white : textColor),
                    const SizedBox(width: 3),
                  ],
                  Flexible(
                    child: Text(
                      status,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: selectedStatus == status ? Colors.white : textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            selected: selectedStatus == status,
            selectedColor: selectedColor,
            backgroundColor: backgroundColor,
            onSelected: (bool selected) async {
              FocusScope.of(context).unfocus();
              final newStatus = selected ? status : null;
              onStatusChanged(newStatus);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
              side: BorderSide(
                color: selectedStatus == status ? selectedColor : borderColor,
                width: 1.2,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            labelPadding: const EdgeInsets.symmetric(horizontal: 2),
            elevation: selectedStatus == status ? 1.5 : 0.5,
            shadowColor: selectedStatus == status ? selectedColor.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          ),
        );
      }).toList(),
    );
  }
}
