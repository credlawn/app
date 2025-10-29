
import 'package:flutter/material.dart';
import 'package:credlawn/helpers/lead_data_helper.dart';
import 'package:credlawn/models/calling_data_model.dart';
import 'package:credlawn/screens/customer_details_screen.dart';
import 'package:credlawn/screens/call_history_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, color: color, size: 20),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Column(
          children: [
            InkWell(
              onTap: widget.onTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),                child: Row(
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
                                                if (widget.leadWithInfo.callCount > 0)
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 8.0),
                                                    child: Chip(
                                                      label: Text('${widget.leadWithInfo.callCount}'),
                                                      visualDensity: VisualDensity.compact,
                                                      padding: EdgeInsets.zero,
                                                      labelPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                                                      backgroundColor: Colors.blueGrey.withOpacity(0.2),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                  ),
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
                                  ),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    child: widget.isExpanded
                                        ? Container(
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
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    _buildSmallActionButton(
                                                      icon: Icons.call,
                                                      color: Colors.green,
                                                      onPressed: () => _callNumber(widget.leadWithInfo.lead.mobileNo),
                                                    ),
                                                    _buildSmallActionButton(
                                                      icon: Icons.chat,
                                                      color: Colors.blue,
                                                      onPressed: () => _openWhatsApp(widget.leadWithInfo.lead.mobileNo),
                                                    ),
                                                                                  _buildSmallActionButton(
                                                                                    icon: Icons.history,
                                                                                    color: Colors.grey.shade600,
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
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : const SizedBox.shrink(),
                                                                ),            Container(
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
