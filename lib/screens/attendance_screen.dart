import 'dart:io';
import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_attendance_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:credlawn/models/geofence_config.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _remarksController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Added for form validation
  bool _isButtonLoading = false;
  bool _isScreenLoading = true;
  String? _lastLogType;
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
      final lastLog = await ApiAttendanceHelper.getLastAttendanceForToday();
      final geofence = await ApiAttendanceHelper.fetchActiveGeofence();
      if (mounted) {
        setState(() {
          _lastLogType = lastLog;
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

  // New function to determine if remarks should be shown and are mandatory
  bool _shouldShowRemarks(String logType) {
    if (_officeStartTime == null || _officeEndTime == null) {
      return false; // If times are not configured, don't show remarks conditionally
    }

    final now = DateTime.now();
    final currentTime = DateTime(2000, 1, 1, now.hour, now.minute, now.second); // Date part doesn't matter

    if (logType == 'In') {
      // Show if check-in is after office start time
      return currentTime.isAfter(_officeStartTime!); // e.g., after 10:00 AM
    } else if (logType == 'Out') {
      // Show if check-out is before office end time
      return currentTime.isBefore(_officeEndTime!); // e.g., before 18:30 PM
    }
    return false;
  }

  Future<void> _initiateAttendance(String logType) async {
    // Validate remarks if visible and mandatory
    if (_shouldShowRemarks(logType)) {
      if (!_formKey.currentState!.validate()) {
        return; // Stop if remarks are mandatory and empty
      }
    }

    final ImagePicker picker = ImagePicker();
    // Open FRONT Camera
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      preferredCameraDevice: CameraDevice.front,
    );

    // If an image is returned by the camera (i.e., user pressed 'OK' in the native camera UI)
    if (image != null) {
      await _submitAttendance(logType, image.path);
    }
    // If image is null (user cancelled), do nothing.
  }

  Future<void> _submitAttendance(String logType, String imagePath) async {
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

      // Step 1: Create Record and get docname
      final String docname = await ApiAttendanceHelper.markAttendance(
        logType: logType,
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        remarks: _remarksController.text,
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
      _remarksController.clear();
      if (mounted) {
        setState(() {
          _lastLogType = logType; // Update the state immediately
        });
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

    return await Geolocator.getCurrentPosition();
  }

  String _getRemarksLabelText() {
    if (_officeStartTime == null || _officeEndTime == null) {
      return 'Remarks'; // Default if office times are not configured
    }

    final now = DateTime.now();
    final currentTime = DateTime(2000, 1, 1, now.hour, now.minute, now.second);

    // Determine the logType for the *next* action
    final String nextLogType = (_lastLogType == 'In') ? 'Out' : 'In';

    if (nextLogType == 'In' && currentTime.isAfter(_officeStartTime!)) {
      return 'Why you are late?';
    } else if (nextLogType == 'Out' && currentTime.isBefore(_officeEndTime!)) {
      return 'Why you leaving early?';
    }
    return 'Remarks';
  }

  @override
  Widget build(BuildContext context) {
    final bool isCheckInDisabled = _lastLogType == 'In';
    final bool isCheckOutDisabled = _lastLogType == null || _lastLogType == 'Out';
    final bool showRemarksField = _shouldShowRemarks(isCheckInDisabled ? 'Out' : 'In');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mark Attendance'),
        backgroundColor: CustomColor.MainColor,
      ),
      body: Stack(
        children: [
          if (_isScreenLoading)
            const Center(child: CircularProgressIndicator())
          else
            Form(
              key: _formKey,
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
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isButtonLoading || isCheckInDisabled
                                ? null
                                : () => _initiateAttendance('In'),
                            icon: const Icon(Icons.login),
                            label: const Text('CHECK IN'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isButtonLoading || isCheckOutDisabled
                                ? null
                                : () => _initiateAttendance('Out'),
                            icon: const Icon(Icons.logout),
                            label: const Text('CHECK OUT'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Visibility(
                      visible: showRemarksField,
                      child: TextFormField(
                        controller: _remarksController,
                        decoration: InputDecoration(
                          labelText: _getRemarksLabelText(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: Icon(Icons.notes, color: CustomColor.MainColor),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (showRemarksField && (value == null || value.isEmpty)) {
                            return 'Remarks are mandatory for this time.';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          CustomColor.showFullScreenLoading(isLoading: _isButtonLoading),
        ],
      ),
    );
  }
}
