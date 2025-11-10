import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'feedback_base.dart';

class FeedbackScreen extends FeedbackBase {
  const FeedbackScreen({super.key, required super.mobileNo});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends FeedbackBaseState<FeedbackScreen> {
  @override
  void onFeedbackSubmitted(bool success) {
    if (success) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget buildFeedbackContent() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: CustomColor.MainColor,
        title: Text('Provide Feedback', style: GoogleFonts.poppins(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 15),
                buildCustomerInfo(),
                const SizedBox(height: 20),
                buildStatusSection(),
                const SizedBox(height: 16),
                buildErrorMessage(),
                buildFormFields(),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomColor.MainColor,
                    minimumSize: const Size(double.infinity, 50),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildFeedbackContent();
  }
}
