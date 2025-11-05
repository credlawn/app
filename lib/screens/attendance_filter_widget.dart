import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceFilterWidget extends StatefulWidget {
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final Function(DateTime?, DateTime?) onFilterApplied;

  const AttendanceFilterWidget({
    super.key,
    this.initialStartDate,
    this.initialEndDate,
    required this.onFilterApplied,
  });

  @override
  State<AttendanceFilterWidget> createState() => _AttendanceFilterWidgetState();
}

class _AttendanceFilterWidgetState extends State<AttendanceFilterWidget> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, adjust it
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _applyFilter() {
    widget.onFilterApplied(_startDate, _endDate);
    Navigator.of(context).pop();
  }

  void _clearFilter() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    widget.onFilterApplied(null, null);
    Navigator.of(context).pop();
  }

  void _setQuickFilter(String filterType) {
    final now = DateTime.now();
    DateTime? start;
    DateTime? end;

    switch (filterType) {
      case 'today':
        start = end = now;
        break;
      case 'yesterday':
        final yesterday = now.subtract(const Duration(days: 1));
        start = end = yesterday;
        break;
      case 'thisWeek':
        start = now.subtract(Duration(days: now.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case 'lastWeek':
        final lastWeekStart = now.subtract(Duration(days: now.weekday + 6));
        start = lastWeekStart;
        end = lastWeekStart.add(const Duration(days: 6));
        break;
      case 'thisMonth':
        start = DateTime(now.year, now.month, 1);
        end = DateTime(now.year, now.month + 1, 0);
        break;
      case 'lastMonth':
        start = DateTime(now.year, now.month - 1, 1);
        end = DateTime(now.year, now.month, 0);
        break;
    }

    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Text(
                'Filter Attendance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                color: Colors.grey,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Quick Filters
          const Text(
            'Quick Filters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildQuickFilterChip('Today', 'today'),
              _buildQuickFilterChip('Yesterday', 'yesterday'),
              _buildQuickFilterChip('This Week', 'thisWeek'),
              _buildQuickFilterChip('Last Week', 'lastWeek'),
              _buildQuickFilterChip('This Month', 'thisMonth'),
              _buildQuickFilterChip('Last Month', 'lastMonth'),
            ],
          ),

          const SizedBox(height: 24),

          // Custom Date Range
          const Text(
            'Custom Date Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 16),

          // Start Date
          InkWell(
            onTap: () => _selectStartDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _startDate != null
                          ? DateFormat('dd MMM yyyy').format(_startDate!)
                          : 'Start Date',
                      style: TextStyle(
                        color: _startDate != null ? Colors.black87 : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // End Date
          InkWell(
            onTap: () => _selectEndDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _endDate != null
                          ? DateFormat('dd MMM yyyy').format(_endDate!)
                          : 'End Date',
                      style: TextStyle(
                        color: _endDate != null ? Colors.black87 : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilter,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Clear Filter',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB), // Blue color
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply Filter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip(String label, String filterType) {
    return InkWell(
      onTap: () => _setQuickFilter(filterType),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
