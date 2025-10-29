
import 'package:flutter/material.dart';
import 'package:credlawn/helpers/lead_data_helper.dart';
import 'package:credlawn/models/calling_data_model.dart';
import 'package:credlawn/screens/customer_details_screen.dart';
import 'package:credlawn/screens/call_history_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/screens/components/feedback_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LeadListItem extends StatefulWidget {
  final LeadWithCallInfo leadWithInfo;
  final bool isExpanded;
  final VoidCallback onTap;

  const LeadListItem({
    super.key,
    required this.leadWithInfo,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  State<LeadListItem> createState() => _LeadListItemState();
}

class _LeadListItemState extends State<LeadListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconFadeAnimation;
  late Animation<double> _nameSizeAnimation;
  late Animation<double> _namePaddingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _iconFadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(curvedAnimation);
    _nameSizeAnimation = Tween<double>(begin: 15.0, end: 17.0).animate(curvedAnimation);
    _namePaddingAnimation = Tween<double>(begin: 12.0, end: 0.0).animate(curvedAnimation);

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant LeadListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _callNumber(String mobileNo) async {
    await FlutterPhoneDirectCaller.callNumber(mobileNo);
  }

  void _openWhatsApp(String mobileNo) async {
    final url = "https://wa.me/91$mobileNo";
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _getStatusIcon(String status) {
    IconData icon;
    Color color;
    switch (status) {
      case 'New Lead':
        icon = Icons.call_received;
        color = Colors.blue;
        break;
      case 'CNR':
        icon = Icons.call_missed;
        color = Colors.red;
        break;
      default:
        icon = Icons.call;
        color = Colors.grey;
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  String _formatTime(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildSmallActionButton({
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 22),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (widget.leadWithInfo.callCount == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'New',
            style: GoogleFonts.poppins(
              color: Colors.white,

              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else if (widget.leadWithInfo.lastCallDuration == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.leadWithInfo.callCount > 99 ? '99+' : '${widget.leadWithInfo.callCount}',
                style: GoogleFonts.poppins(
                  color: Colors.blue,

                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 16), 
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'CNR',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            widget.leadWithInfo.callCount > 99 ? '99+' : '${widget.leadWithInfo.callCount}',
            style: GoogleFonts.poppins(
              color: Colors.blue,

              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Opacity(
              opacity: _iconFadeAnimation.value,
              child: SizedBox(
                width: _iconFadeAnimation.value * 32, // Animate width
                child: _getStatusIcon(widget.leadWithInfo.lead.leadStatus),
              ),
            ),
            SizedBox(width: _namePaddingAnimation.value),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _toTitleCase(widget.leadWithInfo.lead.customerName),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: _nameSizeAnimation.value,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(),
                ],
              ),
            ),
            Text(
              _formatTime(widget.leadWithInfo.lead.updateDate),
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Mobile: ${widget.leadWithInfo.lead.mobileNo}',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 24.0, bottom: 8.0), // Gap above the row
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the row of icons
              children: [
                _buildSmallActionButton(
                  icon: Icons.call,
                  backgroundColor: Colors.green,
                  iconColor: Colors.white,
                  onPressed: () => _callNumber(widget.leadWithInfo.lead.mobileNo),
                ),
                const SizedBox(width: 32), // Increased gap
                _buildSmallActionButton(
                  icon: FontAwesomeIcons.whatsapp,
                  backgroundColor: Colors.green,
                  iconColor: Colors.white,
                  onPressed: () => _openWhatsApp(widget.leadWithInfo.lead.mobileNo),
                ),
                const SizedBox(width: 32), // Increased gap
                _buildSmallActionButton(
                  icon: Icons.info_outline,
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  iconColor: Colors.purple,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailsScreen(
                          mobileNo: widget.leadWithInfo.lead.mobileNo,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 32), // Increased gap
                _buildSmallActionButton(
                  icon: Icons.feedback,
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  iconColor: Colors.orange,
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext dialogContext) {
                        return FeedbackDialog(mobileNo: widget.leadWithInfo.lead.mobileNo);
                      },
                    );
                  },
                ),
                const SizedBox(width: 32), // Increased gap
                _buildSmallActionButton(
                  icon: Icons.history,
                  backgroundColor: Colors.grey.shade600.withOpacity(0.1),
                  iconColor: Colors.grey.shade600,
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CallHistoryScreen(
                          customerName: widget.leadWithInfo.lead.customerName,
                          mobileNo: widget.leadWithInfo.lead.mobileNo,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            _buildHeader(),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: widget.isExpanded
                  ? _buildExpandedSection()
                  : const SizedBox.shrink(),
            ),
            Container(
              margin: const EdgeInsets.only(left: 44),
              height: 0.5,
              color: Colors.grey.shade300,
            ),
          ],
        );
      },
    );
  }
}
