import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'feedback_base.dart';

class FeedbackBottomSheet extends FeedbackBase {
  const FeedbackBottomSheet({
    super.key,
    required super.mobileNo,
  });

  @override
  State<FeedbackBottomSheet> createState() => _FeedbackBottomSheetState();
}

class _FeedbackBottomSheetState extends FeedbackBaseState<FeedbackBottomSheet> {
  @override
  void onFeedbackSubmitted(bool success) {
    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget buildFeedbackContent() {
    return Padding(
      padding: EdgeInsets.only(
        left: 15,
        right: 15,
        top: 15,
        bottom: MediaQuery.of(context).viewInsets.bottom + 15,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Feedback for ${widget.mobileNo}',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: CustomColor.MainColor,
              ),
            ),
            const SizedBox(height: 15),
            FutureBuilder<String>(
              future: getCustomerName(widget.mobileNo),
              builder: (context, snapshot) {
                return Text(
                  snapshot.hasData ? snapshot.data! : 'Loading...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            ),
            const SizedBox(height: 20),
            buildStatusSection(),
            const SizedBox(height: 16),
            buildErrorMessage(),
            buildFormFields(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('Remind Me Later', style: GoogleFonts.poppins(color: Colors.black87)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CustomColor.MainColor,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: submitFeedback,
                    child: Text('Submit', style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildFeedbackContent();
  }
}
