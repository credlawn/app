
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
  final String selectedLeadGroup;

  const LeadListItem({
    super.key,
    required this.leadWithInfo,
    required this.isExpanded,
    required this.onTap,
    required this.onNavigate,
    required this.onCallPressed,
    required this.selectedLeadGroup,
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
      width: 40,
      height: 40,
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
    final status = widget.leadWithInfo.lead.leadStatus;
    final callCount = widget.leadWithInfo.callCount;
    final lead = widget.leadWithInfo.lead;

    String text = '';
    Color backgroundColor = Colors.grey;
    Color textColor = Colors.white;

    // Special handling for Follow Up tab - show date/time instead of status
    if (widget.selectedLeadGroup == 'Follow Up' && status == 'Follow up') {
      String followUpText = '';
      if (lead.followUpDate != null && lead.followUpDate!.isNotEmpty) {
        try {
          final date = DateTime.parse(lead.followUpDate!);
          followUpText = DateFormat('dd/MM').format(date);
        } catch (e) {
          followUpText = lead.followUpDate!;
        }
      }
      if (lead.followUpTime != null && lead.followUpTime!.isNotEmpty) {
        followUpText += followUpText.isNotEmpty ? ' ${lead.followUpTime!}' : lead.followUpTime!;
      }
      if (followUpText.isNotEmpty) {
        text = followUpText;
        backgroundColor = Colors.blue;
      } else {
        text = 'Follow Up';
        backgroundColor = Colors.blue;
      }
    } else {
      switch (status) {
        case 'New':
          text = 'New';
          backgroundColor = Colors.green;
          break;
        case 'Called':
          text = 'Called';
          backgroundColor = Colors.teal;
          break;
        case 'CNR':
          text = 'CNR';
          backgroundColor = Colors.orange;
          break;
        case 'Inactive':
          text = 'Inactive';
          backgroundColor = Colors.red.shade400;
          break;
        case 'IP Approved':
          text = 'IP Approved';
          backgroundColor = Colors.green.shade600;
          break;
        case 'IP Decline':
          text = 'IP Decline';
          backgroundColor = Colors.red.shade700;
          break;
        case 'Customer Denied':
          text = 'Customer Denied';
          backgroundColor = Colors.red.shade600;
          break;
        case 'Docs Not Available':
          text = 'Docs Not Available';
          backgroundColor = Colors.orange.shade600;
          break;
        case 'Already Carded':
          text = 'Already Carded';
          backgroundColor = Colors.purple.shade600;
          break;
        case 'Recently Applied':
          text = 'Recently Applied';
          backgroundColor = Colors.blue.shade600;
          break;
        case 'Follow up':
          text = 'Follow Up';
          backgroundColor = Colors.cyan.shade700;
          break;
        case 'Voicemail':
          text = 'Voicemail';
          backgroundColor = Colors.cyan.shade600;
          break;
        case 'Hold':
          text = 'Hold';
          backgroundColor = Colors.amber.shade600;
          break;
        default:
          if (callCount == 0) {
            text = 'New';
            backgroundColor = Colors.green;
          }
          // If status is null or empty, we don't show a specific status badge,
          // but we might still show the call count.
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Always show call count if not a new lead
          if (status != 'New' && callCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                callCount > 99 ? '99+' : '$callCount',
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
        padding: const EdgeInsets.only(left: 8, right: 4, top: 12, bottom: 12),
        child: Row(
          children: [
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
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
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
                  backgroundColor: Colors.blue,
                  iconColor: Colors.white,
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
                if (widget.selectedLeadGroup != 'New Leads') ...[
                  if (!['IP Approved', 'IP Decline', 'CNR'].contains(widget.leadWithInfo.lead.leadStatus)) ...[
                    _buildSmallActionButton(
                      icon: Icons.feedback,
                      backgroundColor: Colors.orange,
                      iconColor: Colors.white,
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
                  ],
                  _buildSmallActionButton(
                    icon: Icons.history,
                    backgroundColor: Colors.grey.shade600,
                    iconColor: Colors.white,
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
