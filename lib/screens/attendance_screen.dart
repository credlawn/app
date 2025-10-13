import 'dart:io';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_attendance_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/models/geofence_config.dart';
import 'package:credlawn/screens/attendance_list_widget.dart'; // Added this import
import 'package:google_fonts/google_fonts.dart'; // Added GoogleFonts import
import 'package:credlawn/models/today_attendance_status.dart'; // Added this import


class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _formKey = GlobalKey<FormState>(); // Added for form validation
  final GlobalKey<AttendanceListWidgetState> _attendanceListKey = GlobalKey<AttendanceListWidgetState>(); // Key for AttendanceListWidget
  bool _isButtonLoading = false;
  bool _isScreenLoading = true;
  TodayAttendanceStatus? _todayAttendanceStatus; // Changed type to TodayAttendanceStatus
  GeofenceConfig? _geofenceConfig; // New state variable for geofence
  DateTime? _officeStartTime;
  DateTime? _officeEndTime;

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

  Future<void> _handleAttendanceRequest(String logType) async {
    setState(() {
      _isButtonLoading = true;
    });

    try {
      // Get Location
      Position currentPosition = await _determinePosition();

      // Geofence Check
      if (_geofenceConfig != null) {
        if (!_isInsideGeofence(currentPosition)) {
          throw Exception('You are outside the ${_geofenceConfig!.locationName}');
        }
      }

      // If inside geofence, open camera
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        preferredCameraDevice: CameraDevice.front,
      );

      // If an image is taken, submit attendance
      if (image != null) {
        await _submitAttendance(logType, image.path, currentPosition);
      } else {
        // If user cancels camera, stop loading
        setState(() {
          _isButtonLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        CustomColor.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
      setState(() {
        _isButtonLoading = false;
      });
    }
    // No finally block needed here for setting _isButtonLoading to false,
    // as it's handled in the success path of _submitAttendance or in the catch/cancel paths.
  }

  Future<void> _submitAttendance(String logType, String imagePath, Position currentPosition) async {
    // Button loading is already true from _handleAttendanceRequest
    try {
      // Step 1: Create Record and get docname
      final String docname = await ApiAttendanceHelper.markAttendance(
        logType: logType,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
      );

      // Step 2: Upload Image and get URL
      final String fileUrl = await ApiAttendanceHelper.uploadImage(
        docname: docname,
        imagePath: imagePath,
      );

      // Step 3: Update the document with the file URL
      await ApiAttendanceHelper.updateImagePath(
        docname: docname,
        filePath: fileUrl,
      );

      CustomColor.showSuccessSnackBar(context, 'Attendance marked successfully!');
      if (mounted) {
        // After successful punch, re-fetch status and refresh list
        await _fetchInitialStatusAndGeofence();
        _attendanceListKey.currentState?.refreshData();
      }
    } catch (e) {
      if (mounted) {
        CustomColor.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isButtonLoading = false;
        });
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
    // No need for isCheckInDisabled and isCheckOutDisabled here anymore

    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance', style: TextStyle(color: Colors.white)),
        backgroundColor: CustomColor.MainColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Builder(
              builder: (context) {
                if (_isScreenLoading) {
                  return ElevatedButton.icon(
                    onPressed: null, // Disabled
                    icon: const Icon(Icons.hourglass_empty, color: Colors.white),
                    label: const Text('Checking...', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  );
                }

                String buttonText = '';
                IconData buttonIcon = Icons.login;
                Color buttonColor = Colors.green;
                VoidCallback? onPressedCallback;

                // Case 1: Already Checked Out for today
                if (_todayAttendanceStatus?.hasCheckedOut ?? false) {
                  buttonText = 'MARKED';
                  buttonIcon = Icons.check_circle;
                  buttonColor = Colors.grey;
                  onPressedCallback = null; // Disabled
                }
                // Case 2: Checked In, but not yet Checked Out
                else if (_todayAttendanceStatus?.hasCheckedIn ?? false) {
                  buttonText = 'CHECK OUT';
                  buttonIcon = Icons.logout;
                  buttonColor = Colors.red;
                  onPressedCallback = _isButtonLoading ? null : () => _handleAttendanceRequest('Out');
                }
                // Case 3: No punches for today (or only 'Out' which is invalid)
                else {
                  buttonText = 'CHECK IN';
                  buttonIcon = Icons.login;
                  buttonColor = Colors.green;
                  onPressedCallback = _isButtonLoading ? null : () => _handleAttendanceRequest('In');
                }

                return ElevatedButton.icon(
                  onPressed: onPressedCallback,
                  icon: Icon(buttonIcon, color: Colors.white),
                  label: Text(buttonText, style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isScreenLoading)
            const Center(child: CircularProgressIndicator())
          else
            RefreshIndicator(
              onRefresh: () async {
                await _fetchInitialStatusAndGeofence();
                _attendanceListKey.currentState?.refreshData();
              },
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(), // Explicitly set physics
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: CustomColor.MainColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        AttendanceListWidget(key: _attendanceListKey), // Assign key to AttendanceListWidget
                      ],
                    ),
                  ),
                ),
              ),
            ),
          CustomColor.showFullScreenLoading(isLoading: _isButtonLoading),
        ],
      ),
    );
  }
}
