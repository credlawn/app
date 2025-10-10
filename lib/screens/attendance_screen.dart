import 'package:credlawn/custom/custom_color.dart';
import 'package:credlawn/network/api_attendance_helper.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _remarksController = TextEditingController();
  bool _isButtonLoading = false;
  bool _isScreenLoading = true;
  String? _lastLogType;

  @override
  void initState() {
    super.initState();
    _fetchInitialStatus();
  }

  Future<void> _fetchInitialStatus() async {
    try {
      final lastLog = await ApiAttendanceHelper.getLastAttendanceForToday();
      setState(() {
        _lastLogType = lastLog;
      });
    } catch (e) {
      if (mounted) {
        CustomColor.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      setState(() {
        _isScreenLoading = false;
      });
    }
  }

  Future<void> _markAttendance(String logType) async {
    setState(() {
      _isButtonLoading = true;
    });

    try {
      Position position = await _determinePosition();

      final response = await ApiAttendanceHelper.markAttendance(
        logType: logType,
        latitude: position.latitude,
        longitude: position.longitude,
        remarks: _remarksController.text,
      );

      CustomColor.showSuccessSnackBar(context, response.message);
      _remarksController.clear();
      setState(() {
        _lastLogType = logType; // Update the state immediately
      });

    } catch (e) {
      CustomColor.showErrorSnackBar(context, e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() {
        _isButtonLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    final bool isCheckInDisabled = _lastLogType == 'In';
    final bool isCheckOutDisabled = _lastLogType == null || _lastLogType == 'Out';

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
            Padding(
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
                  TextField(
                    controller: _remarksController,
                    decoration: const InputDecoration(
                      labelText: 'Remarks',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.notes),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isButtonLoading || isCheckInDisabled
                              ? null
                              : () => _markAttendance('In'),
                          icon: const Icon(Icons.login),
                          label: const Text('CHECK IN'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isButtonLoading || isCheckOutDisabled
                              ? null
                              : () => _markAttendance('Out'),
                          icon: const Icon(Icons.logout),
                          label: const Text('CHECK OUT'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          CustomColor.showFullScreenLoading(isLoading: _isButtonLoading),
        ],
      ),
    );
  }
}
