import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user.dart';

class ManagerCnrLeadScreen extends StatelessWidget {
  final User user;

  ManagerCnrLeadScreen({super.key, required this.user});

  // Sample API URL to fetch employees
  final String apiUrl = 'https://example.com/api/employees'; 

  // Function to fetch employee data
  Future<List<Employee>> fetchEmployees() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Employee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load employees');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Employee List',
          style: GoogleFonts.poppins(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Employee>>(
          future: fetchEmployees(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No employees found.'));
            } else {
              List<Employee> employees = snapshot.data!;

              return SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Position')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: employees
                      .map(
                        (employee) => DataRow(
                          cells: [
                            DataCell(Text(employee.id.toString())),
                            DataCell(Text(employee.name)),
                            DataCell(Text(employee.position)),
                            DataCell(Text(employee.status)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class Employee {
  final int id;
  final String name;
  final String position;
  final String status;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      status: json['status'],
    );
  }
}
