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

    // Initial filtering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        if (_tabController.index == 0) {
          _selectedTab = 'Unread';
        } else {
          _selectedTab = 'Read';
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
      final newLogs = await fetchFcmLogs(page: _page, searchTerm: _searchTerm);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search Notifications...',
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                prefixIcon: Icon(Icons.search, color: Colors.grey[700]),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[700]),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchController.clear();
                    });
                  },
                ),
              ),
              style: GoogleFonts.poppins(color: Colors.black87, fontSize: 16),
            )
          : Text('Notification History', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.blueAccent,
      elevation: 0.5,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                _searchController.clear();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        TabBar(
          onTap: (index) {
            setState(() {
              if (index == 0) {
                _selectedTab = 'Unread';
              } else {
                _selectedTab = 'Read';
              }
            });
          },
          indicatorColor: Colors.blueAccent,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(
              text: 'Unread ($_unreadCount)',
            ),
            Tab(text: 'Read'),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              _resetAndFetchLogs();
            },
            color: Colors.blueAccent,
            child: _buildContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_logs.isEmpty && _isLoading) {
      return Center(child: CircularProgressIndicator(color: Colors.blueAccent));
    }
    if (_logs.isEmpty && !_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No Notifications Yet',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              _searchTerm.isEmpty
                  ? 'New notifications will appear here.'
                  : 'No results found for \"$_searchTerm\"',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    List<FcmLogModel> filteredLogs = _logs;

    if (_searchTerm.isEmpty) {
      filteredLogs = filteredLogs.where((log) {
        if (_selectedTab == 'All') {
          return true;
        } else if (_selectedTab == 'Unread') {
          return log.messageStatus == 'Unread';
        } else {
          return log.messageStatus == 'Read';
        }
      }).toList();
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: filteredLogs.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == filteredLogs.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final log = filteredLogs[index];
        final isUnread = log.messageStatus == 'Unread';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          color: isUnread ? Colors.blue.shade50 : Colors.white,
          child: ListTile(
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            title: Text(
              log.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  log.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  DateFormat('MMM d, yyyy hh:mm a').format(log.creation),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            isThreeLine: true,
            trailing: isUnread
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
