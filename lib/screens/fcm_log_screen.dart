import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/models/fcm_log_model.dart';
import 'package:credlawn/network/api_fcm_log_helper.dart';
import 'package:credlawn/screens/notification_detail_screen.dart';
import 'package:intl/intl.dart';

class FcmLogScreen extends StatefulWidget {
  const FcmLogScreen({super.key});

  @override
  State<FcmLogScreen> createState() => _FcmLogScreenState();
}

class _FcmLogScreenState extends State<FcmLogScreen> with SingleTickerProviderStateMixin {
  final List<FcmLogModel> _logs = [];
  final _scrollController = ScrollController();
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchTerm = '';
  int _unreadCount = 0;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;
  String _selectedTab = 'All';

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        if (_tabController.index == 0) {
          _selectedTab = 'Unread';
        } else {
          _selectedTab = 'Read';
        }
      });
    });

    // Set initial tab
    _selectedTab = 'Unread';

    _fetchLogs();
    _fetchUnreadCount();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoading) {
        _fetchLogs();
      }
    });

    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (_searchTerm != _searchController.text) {
          _searchTerm = _searchController.text;
          _resetAndFetchLogs();
        }
      });
    });
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final count = await getUnreadFcmLogsCount();
      if (mounted) {
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {}
  }

  Future<void> _fetchLogs() async {
    if (!_hasMore || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final status = _selectedTab == 'All' ? null : _selectedTab;
      final newLogs = await fetchFcmLogs(page: _page, searchTerm: _searchTerm, status: status);
      setState(() {
        _page++;
        _logs.addAll(newLogs);
        _isLoading = false;
        if (newLogs.length < 30) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMore = false; // Stop pagination spinner on error
      });
      if (mounted) {
        CustomColor.showErrorSnackBar(context, 'Error fetching logs: ${e.toString()}');
      }
    }
  }

  void _resetAndFetchLogs() {
    setState(() {
      _page = 1;
      _logs.clear();
      _hasMore = true;
    });
    _fetchLogs();
    _fetchUnreadCount();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search notifications...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close, color: Colors.grey[600], size: 18),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchController.clear();
                      });
                    },
                  ),
                ),
                style: GoogleFonts.inter(color: Colors.grey[800], fontSize: 15),
              ),
            )
          : Text(
              'Notifications',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
      backgroundColor: CustomColor.MainColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        if (!_isSearching)
          IconButton(
            icon: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search, size: 20, color: Colors.white),
            ),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (index) {
              setState(() {
                if (index == 0) {
                  _selectedTab = 'Unread';
                } else {
                  _selectedTab = 'Read';
                }
              });
              _resetAndFetchLogs();
            },
            indicator: BoxDecoration(
              gradient: LinearGradient(
                colors: [CustomColor.MainColor, CustomColor.MainColor.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorPadding: EdgeInsets.all(4),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey[600],
            labelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            unselectedLabelStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Unread'),
                    if (_unreadCount > 0) ...[
                      SizedBox(width: 6),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _unreadCount.toString(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(text: 'Read'),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _resetAndFetchLogs();
            },
            color: CustomColor.MainColor,
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_logs.isEmpty && _isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: CustomColor.MainColor),
            SizedBox(height: 16),
            Text(
              'Loading notifications...',
              style: GoogleFonts.inter(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_logs.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 60,
                color: Colors.grey[300],
              ),
            ),
            SizedBox(height: 24),
            Text(
              _searchTerm.isEmpty 
                  ? _selectedTab == 'Unread' 
                      ? 'No Unread Notifications'
                      : 'No Read Notifications'
                  : 'No Results Found',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              _searchTerm.isEmpty
                  ? _selectedTab == 'Unread'
                      ? 'You\'re all caught up! No unread notifications.'
                      : 'No notifications have been marked as read yet.'
                  : 'No notifications match "$_searchTerm"',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: Colors.grey[500],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            if (_searchTerm.isEmpty && _selectedTab == 'Unread')
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: CustomColor.MainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: CustomColor.MainColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: CustomColor.MainColor,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'All caught up',
                      style: GoogleFonts.inter(
                        color: CustomColor.MainColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _logs.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _logs.length) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: CustomColor.MainColor),
            ),
          );
        }

        final log = _logs[index];
        final isUnread = log.messageStatus == 'Unread';

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NotificationDetailScreen(
                      log: log,
                      onMarkAsRead: () {
                        _resetAndFetchLogs();
                      },
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: isUnread 
                    ? Border.all(color: CustomColor.MainColor.withOpacity(0.2), width: 1.5)
                    : Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  log.title,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800],
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isUnread)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: CustomColor.MainColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            log.body,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[400],
                              ),
                              SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d, yyyy • hh:mm a').format(log.creation),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey[400],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
