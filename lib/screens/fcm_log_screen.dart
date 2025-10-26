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

class _FcmLogScreenState extends State<FcmLogScreen> {
  final List<FcmLogModel> _logs = [];
  final _scrollController = ScrollController();
  int _page = 1;
  bool _isLoading = false;
  bool _hasMore = true;
  String _searchTerm = '';

  // Search related
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchLogs();

    _scrollController.addListener(() {
      // If scrolled to the bottom and not currently loading, load more
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
        // If we receive fewer logs than the page size, we've reached the end
        if (newLogs.length < 30) {
          _hasMore = false;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching logs: ${e.toString()}')),
        );
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search Notifications...',
                border: InputBorder.none, // This removes the underline
              ),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
            )
          : Text('Notification History', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20)),
      backgroundColor: CustomColor.MainColor,
      elevation: 0.5,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: Icon(_isSearching ? Icons.close : Icons.search),
          onPressed: () {
            setState(() {
              _isSearching = !_isSearching;
              if (!_isSearching) {
                // If search was cancelled, clear search and reload all logs
                _searchController.clear();
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      onRefresh: () async {
        _resetAndFetchLogs();
      },
      color: CustomColor.MainColor,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_logs.isEmpty && _isLoading) {
      return Center(child: CircularProgressIndicator(color: CustomColor.MainColor));
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

    return ListView.builder(
      controller: _scrollController,
      itemCount: _logs.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _logs.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final log = _logs[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationDetailScreen(
                    title: log.title,
                    body: log.body,
                  ),
                ),
              );
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            title: Text(
              log.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
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
          ),
        );
      },
    );
  }
}
