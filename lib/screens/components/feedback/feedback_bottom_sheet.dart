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
            FutureBuilder<String>(
              future: getCustomerName(widget.mobileNo),
              builder: (context, snapshot) {
                final customerName = snapshot.hasData ? snapshot.data! : 'Loading...';
                return Column(
                  children: [
                    Text(
                      'You have a pending feedback',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade700,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.red.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    buildCustomerInfo(),
                  ],
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
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    onPressed: isSubmitting ? null : submitFeedback,
                    child: isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('Submitting...', style: GoogleFonts.poppins(color: Colors.white)),
                            ],
                          )
                        : Text('Submit', style: GoogleFonts.poppins(color: Colors.white)),
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
