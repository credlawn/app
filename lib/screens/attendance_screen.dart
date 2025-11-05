import 'dart:io';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_attendance_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/models/geofence_config.dart';
import 'package:credlawn/screens/attendance_list_widget.dart'; // Added this import
// Added GoogleFonts import
import 'package:credlawn/models/today_attendance_status.dart'; // Added this import


class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _formKey = GlobalKey<FormState>(); // Added for form validation
  final GlobalKey<AttendanceListWidgetState> _attendanceListKey = GlobalKey<AttendanceListWidgetState>(); // Key for AttendanceListWidget
  bool _isButtonLoading = false;
  bool _isScreenLoading = true;
  String _loadingMessage = '';
  TodayAttendanceStatus? _todayAttendanceStatus; // Changed type to TodayAttendanceStatus
  GeofenceConfig? _geofenceConfig; // New state variable for geofence
  DateTime? _officeStartTime;
  DateTime? _officeEndTime;

  // Progress tracking
  bool _showProgressOverlay = false;
  String _currentStep = '';
  double _progressValue = 0.0;
  bool _canCancel = true;

  @override
  void initState() {
    super.initState();
    _fetchInitialStatusAndGeofence();
  }

  Future<void> _fetchInitialStatusAndGeofence() async {
    try {
      final status = await ApiAttendanceHelper.getLastAttendanceForToday(); // Get TodayAttendanceStatus
      final geofence = await ApiAttendanceHelper.fetchActiveGeofence();
      if (mounted) {
        setState(() {
          _todayAttendanceStatus = status; // Assign the new status object
          _geofenceConfig = geofence;
          // Parse office times if available
          if (_geofenceConfig?.officeStartTime != null) {
            _officeStartTime = DateFormat('HH:mm:ss').parse(_geofenceConfig!.officeStartTime!);
          }
          if (_geofenceConfig?.officeEndTime != null) {
            _officeEndTime = DateFormat('HH:mm:ss').parse(_geofenceConfig!.officeEndTime!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        CustomColor.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isScreenLoading = false;
        });
      }
    }
  }

  void _updateProgress(String step, double progress) {
    if (mounted) {
      setState(() {
        _currentStep = step;
        _progressValue = progress;
      });
    }
  }

  void _showProgressDialog() {
    setState(() {
      _showProgressOverlay = true;
      _canCancel = true;
    });
  }

  void _hideProgressDialog() {
    setState(() {
      _showProgressOverlay = false;
      _currentStep = '';
      _progressValue = 0.0;
    });
  }

  Future<void> _handleAttendanceRequest(String logType) async {
    _showProgressDialog();
    _updateProgress('Initializing...', 0.1);

    try {
      // Step 1: Get Location
      _updateProgress('Getting your location...', 0.2);
      Position currentPosition = await _determinePosition();

      // Step 2: Geofence Check
      _updateProgress('Verifying location...', 0.4);
      if (_geofenceConfig != null) {
        if (!_isInsideGeofence(currentPosition)) {
          throw Exception('You are outside the ${_geofenceConfig!.locationName}');
        }
      }

      // Step 3: Open Camera
      _updateProgress('Opening camera...', 0.6);
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front,
      );

      // Step 4: Submit Attendance
      if (image != null) {
        _updateProgress('Processing attendance...', 0.8);
        await _submitAttendanceWithProgress(logType, image.path, currentPosition);
      } else {
        // User cancelled camera
        _hideProgressDialog();
      }
    } catch (e) {
      _hideProgressDialog();
      if (mounted) {
        CustomColor.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _submitAttendanceWithProgress(String logType, String imagePath, Position currentPosition) async {
    try {
      // Step 1: Create Record and get docname
      _updateProgress('Creating attendance record...', 0.85);
      final String docname = await ApiAttendanceHelper.markAttendance(
        logType: logType,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
      );

      // Step 2: Upload Image and get URL
      _updateProgress('Uploading photo...', 0.95);
      final String fileUrl = await ApiAttendanceHelper.uploadImage(
        docname: docname,
        imagePath: imagePath,
      );

      // Step 3: Update the document with the file URL
      _updateProgress('Finalizing...', 1.0);
      await ApiAttendanceHelper.updateImagePath(
        docname: docname,
        filePath: fileUrl,
      );

      _hideProgressDialog();
      HapticFeedback.vibrate();
      CustomColor.showSuccessSnackBar(context, 'Attendance marked successfully!');
      if (mounted) {
        // After successful punch, re-fetch status and refresh list
        await _fetchInitialStatusAndGeofence();
        _attendanceListKey.currentState?.refreshData();
      }
    } catch (e) {
      _hideProgressDialog();
      if (mounted) {
        CustomColor.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  // New function to check if current position is inside geofence
  bool _isInsideGeofence(Position currentPosition) {
    if (_geofenceConfig == null) return true; // No geofence, so always inside

    final double distanceInMeters = Geolocator.distanceBetween(
      _geofenceConfig!.latitude,
      _geofenceConfig!.longitude,
      currentPosition.latitude,
      currentPosition.longitude,
    );

    return distanceInMeters <= _geofenceConfig!.radius;
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: Platform.isAndroid ? true : false,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return Future.error('Failed to get fresh location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CustomColor.MainColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: Stack(
          children: [
            if (_isScreenLoading)
              const Center(child: CircularProgressIndicator())
            else
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _fetchInitialStatusAndGeofence();
                    _attendanceListKey.currentState?.refreshData();
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // Header Section
                      SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                CustomColor.MainColor,
                                CustomColor.MainColor.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Date Display
                              Text(
                                DateFormat('EEEE').format(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('d MMMM yyyy').format(DateTime.now()),
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Office Hours Card
                              if (_officeStartTime != null && _officeEndTime != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.access_time,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${DateFormat('hh:mm a').format(_officeStartTime!)} - ${DateFormat('hh:mm a').format(_officeEndTime!)}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 30),

                              // Status Dashboard
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    // Attendance Status
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildStatusIndicator(
                                          'Check In',
                                          _todayAttendanceStatus?.hasCheckedIn ?? false,
                                          Icons.login,
                                          Colors.green,
                                        ),
                                        Container(
                                          height: 40,
                                          width: 2,
                                          color: Colors.grey.shade300,
                                        ),
                                        _buildStatusIndicator(
                                          'Check Out',
                                          _todayAttendanceStatus?.hasCheckedOut ?? false,
                                          Icons.logout,
                                          Colors.red,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),

                                    // Action Button
                                    Builder(
                                      builder: (context) {
                                        if (_isButtonLoading) {
                                          return Container(
                                            width: 200,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade300,
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                                ),
                                              ),
                                            ),
                                          );
                                        }

                                        String buttonText = '';
                                        IconData buttonIcon = Icons.login;
                                        Color buttonColor = Colors.green;
                                        VoidCallback? onPressedCallback;

                                        if (_todayAttendanceStatus?.hasCheckedOut ?? false) {
                                          buttonText = 'Attendance Complete';
                                          buttonIcon = Icons.check_circle;
                                          buttonColor = Colors.grey;
                                          onPressedCallback = null;
                                        } else if (_todayAttendanceStatus?.hasCheckedIn ?? false) {
                                          buttonText = 'Check Out';
                                          buttonIcon = Icons.logout;
                                          buttonColor = Colors.red;
                                          onPressedCallback = () => _handleAttendanceRequest('Out');
                                        } else {
                                          buttonText = 'Check In';
                                          buttonIcon = Icons.login;
                                          buttonColor = Colors.green;
                                          onPressedCallback = () => _handleAttendanceRequest('In');
                                        }

                                        return ElevatedButton.icon(
                                          onPressed: onPressedCallback,
                                          icon: Icon(buttonIcon, size: 24),
                                          label: Text(
                                            buttonText,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: buttonColor,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 30,
                                              vertical: 15,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            elevation: 5,
                                            shadowColor: buttonColor.withOpacity(0.3),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Attendance List
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Text(
                                  'Recent Attendance',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              AttendanceListWidget(
                                key: _attendanceListKey,
                                officeStartTime: _officeStartTime,
                                officeEndTime: _officeEndTime,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            CustomColor.showFullScreenLoading(isLoading: _isButtonLoading),

            // Progress Overlay
            if (_showProgressOverlay) _buildProgressOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CustomColor.MainColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getProgressIcon(),
                  color: CustomColor.MainColor,
                  size: 32,
                ),
              ),

              const SizedBox(height: 20),

              // Progress Text
              Text(
                _currentStep,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Progress Bar
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _progressValue,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CustomColor.MainColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Progress Percentage
              Text(
                '${(_progressValue * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 20),

              // Cancel Button
              if (_canCancel)
                TextButton(
                  onPressed: () {
                    _hideProgressDialog();
                    CustomColor.showErrorSnackBar(context, 'Attendance process cancelled');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getProgressIcon() {
    if (_progressValue < 0.3) {
      return Icons.location_searching;
    } else if (_progressValue < 0.5) {
      return Icons.location_on;
    } else if (_progressValue < 0.7) {
      return Icons.camera_alt;
    } else if (_progressValue < 0.9) {
      return Icons.cloud_upload;
    } else {
      return Icons.check_circle;
    }
  }

  Widget _buildStatusIndicator(String label, bool isActive, IconData icon, Color activeColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.1) : Colors.grey.shade100,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? activeColor : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: isActive ? activeColor : Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isActive ? activeColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}
