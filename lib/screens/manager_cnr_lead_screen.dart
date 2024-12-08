import 'package:flutter/material.dart';
import 'package:credlawn/custom/custom_color.dart'; // Import your custom color
import 'package:google_fonts/google_fonts.dart';
import '../models/user.dart';

class ManagerCnrLeadScreen extends StatelessWidget {
  final User user;

  ManagerCnrLeadScreen({super.key, required this.user});

  // Dummy data for employees and their CNR count and other columns
  final List<Map<String, dynamic>> _dummyData = [
    {'name': 'Arun', 'new': 5, 'ni': 3, 'cnr': 10, 'login': 8, 'follow': 7, 'carded': 2},
    {'name': 'Abhishek', 'new': 8, 'ni': 4, 'cnr': 20, 'login': 12, 'follow': 10, 'carded': 5},
    {'name': 'Ravi', 'new': 6, 'ni': 2, 'cnr': 15, 'login': 9, 'follow': 6, 'carded': 3},
    {'name': 'Priya', 'new': 10, 'ni': 5, 'cnr': 30, 'login': 15, 'follow': 12, 'carded': 7},
    {'name': 'Meena', 'new': 7, 'ni': 3, 'cnr': 25, 'login': 10, 'follow': 9, 'carded': 4},
    {'name': 'Kumar', 'new': 4, 'ni': 3, 'cnr': 12, 'login': 6, 'follow': 5, 'carded': 1},
    {'name': 'Rahul', 'new': 6, 'ni': 4, 'cnr': 18, 'login': 8, 'follow': 7, 'carded': 3},
    {'name': 'Sita', 'new': 7, 'ni': 3, 'cnr': 22, 'login': 11, 'follow': 9, 'carded': 5},
    {'name': 'Neha', 'new': 5, 'ni': 2, 'cnr': 14, 'login': 7, 'follow': 6, 'carded': 2},
    {'name': 'Vikas', 'new': 6, 'ni': 3, 'cnr': 17, 'login': 9, 'follow': 8, 'carded': 4},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CNR Leads',
          style: GoogleFonts.poppins(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: CustomColor.MainColor,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // The Fixed Employee Column Table (Header + Data Rows)
            Container(
              color: Colors.white,
              child: Row(
                children: [
                  // Fixed "Employee" Column (First Column)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Employee header with border
                      Container(
                        width: 150,
                        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          color: Colors.grey[200],
                        ),
                        child: Text(
                          'Employee',
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Employee data rows with border
                      for (var employee in _dummyData)
                        Container(
                          width: 150,
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Text(
                            employee['name'],
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                    ],
                  ),
                  // Scrollable data for other columns
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          // Header Row (Columns: New, NI, CNR, etc.) with borders
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              color: Colors.grey[200],
                            ),
                            child: Row(
                              children: [
                                _buildHeaderCell('New'),
                                _buildHeaderCell('NI'),
                                _buildHeaderCell('CNR'),
                                _buildHeaderCell('Login'),
                                _buildHeaderCell('Follow'),
                                _buildHeaderCell('Carded'),
                              ],
                            ),
                          ),
                          // Data rows for each employee with borders
                          for (var employee in _dummyData)
                            Row(
                              children: [
                                _buildDataCell('${employee['new']}'),
                                _buildDataCell('${employee['ni']}'),
                                _buildDataCell('${employee['cnr']}'),
                                _buildDataCell('${employee['login']}'),
                                _buildDataCell('${employee['follow']}'),
                                _buildDataCell('${employee['carded']}'),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build data cells
  Widget _buildHeaderCell(String title) {
    return Container(
      width: 150,
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper function to build data cells
  Widget _buildDataCell(String value) {
    return Container(
      width: 150,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Text(
        value,
        style: GoogleFonts.poppins(fontSize: 16),
      ),
    );
  }
}
