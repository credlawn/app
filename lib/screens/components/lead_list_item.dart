
import 'package:flutter/material.dart';
import 'package:credlawn/helpers/lead_data_helper.dart';
import 'package:credlawn/models/leads_model.dart';
import 'package:credlawn/screens/customer_details_screen.dart';
import 'package:credlawn/screens/call_history_screen.dart';
import 'package:credlawn/screens/components/feedback/feedback_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LeadListItem extends StatefulWidget {
  final LeadWithCallInfo leadWithInfo;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final Function(LeadsModel lead) onCallPressed;

  const LeadListItem({
    super.key,
    required this.leadWithInfo,
    required this.isExpanded,
    required this.onTap,
    required this.onNavigate,
    required this.onCallPressed,
  });

  @override
  State<LeadListItem> createState() => _LeadListItemState();
}

class _LeadListItemState extends State<LeadListItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconTurnsAnimation;
  late Animation<double> _heightFactorAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconTurnsAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _heightFactorAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _backgroundColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.grey.shade50,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

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
      }
      else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _callNumber(LeadsModel lead) async {
    await FlutterPhoneDirectCaller.callNumber(lead.mobileNo);
  }

  void _openWhatsApp(LeadsModel lead) async {
    final url = "https://wa.me/91${lead.mobileNo}";
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
    }
    catch (e) {
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
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: iconColor, size: 18),
        padding: EdgeInsets.zero,
        splashColor: iconColor.withOpacity(0.2),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (_hasFeedback(widget.leadWithInfo.lead.leadStatus)) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.leadWithInfo.callCount > 99 ? '99+' : '${widget.leadWithInfo.callCount}',
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.purple,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.leadWithInfo.lead.leadStatus ?? '',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    else if (widget.leadWithInfo.callCount == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'New',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    else if (widget.leadWithInfo.lastCallDuration == 0) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.leadWithInfo.callCount > 99 ? '99+' : '${widget.leadWithInfo.callCount}',
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'CNR',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    else if (widget.leadWithInfo.callCount > 0 && (widget.leadWithInfo.lastCallDuration ?? 0) > 0 && !_hasFeedback(widget.leadWithInfo.lead.leadStatus)) {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.leadWithInfo.callCount > 99 ? '99+' : '${widget.leadWithInfo.callCount}',
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Pending Feedback',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }
    else {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            widget.leadWithInfo.callCount > 99 ? '99+' : '${widget.leadWithInfo.callCount}',
            style: GoogleFonts.poppins(
              color: Colors.blue,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
  }

  bool _hasFeedback(String? leadStatus) {
    if (leadStatus == null || leadStatus.trim().isEmpty) {
      return false;
    }

    final feedbackStatuses = [
      'IP Approved',
      'IP Decline',
      'Customer Denied',
      'Docs Not Available',
      'Already Carded',
      'Recently Applied',
      'CNR',
      'Follow up'
    ];

    return feedbackStatuses.contains(leadStatus);
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      _toTitleCase(widget.leadWithInfo.lead.customerName),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(),
                ],
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
            padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSmallActionButton(
                  icon: Icons.call,
                  backgroundColor: Colors.green,
                  iconColor: Colors.white,
                  onPressed: () => widget.onCallPressed(widget.leadWithInfo.lead),
                ),
                const SizedBox(width: 32),
                _buildSmallActionButton(
                  icon: FontAwesomeIcons.whatsapp,
                  backgroundColor: Colors.green,
                  iconColor: Colors.white,
                  onPressed: () => _openWhatsApp(widget.leadWithInfo.lead),
                ),
                const SizedBox(width: 32),
                _buildSmallActionButton(
                  icon: Icons.info_outline,
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  iconColor: Colors.purple,
                  onPressed: () {
                    widget.onNavigate();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CustomerDetailsScreen(
                          mobileNo: widget.leadWithInfo.lead.mobileNo,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 32),
_buildSmallActionButton(
  icon: Icons.feedback,
  backgroundColor: Colors.orange.withOpacity(0.1),
  iconColor: Colors.orange,
  onPressed: () {
    widget.onNavigate();
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return FeedbackScreen(mobileNo: widget.leadWithInfo.lead.mobileNo);
        },
      ),
    );
  },
),
                const SizedBox(width: 32),
                _buildSmallActionButton(
                  icon: Icons.history,
                  backgroundColor: Colors.grey.shade600.withOpacity(0.1),
                  iconColor: Colors.grey.shade600,
                  onPressed: () {
                    widget.onNavigate();
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
        return Container(
          decoration: BoxDecoration(
            color: _backgroundColorAnimation.value,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.transparent),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            children: [
              _buildHeader(),
              SizeTransition(
                sizeFactor: _heightFactorAnimation,
                axis: Axis.vertical,
                child: widget.isExpanded ? _buildExpandedSection() : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}
