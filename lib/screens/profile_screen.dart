import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:credlawn/custom/custom_color.dart';

class ProfileScreen extends StatelessWidget {
  final User user;

  const ProfileScreen({super.key, required this.user});

  Widget _buildProfileItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: CustomColor.MainColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: CustomColor.MainColor,
            size: 20,
          ),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          value.isEmpty ? 'Not available' : value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: CustomColor.MainColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: CustomColor.MainColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // Profile Picture
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [CustomColor.MainColor, CustomColor.DrawerItems],
                        ),
                      ),
                      child: SizedBox(
                        height: 100,
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: user.userImage ?? "",
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/image/profileImage.png',
                              fit: BoxFit.cover,
                            ),
                            httpHeaders: {'Cookie': 'sid=${user.sid}'},
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // User Name
                  Text(
                    user.fullName,
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // User Role
                  Text(
                    user.role ?? 'Employee',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Profile Details Section
            Column(
              children: [
                _buildProfileItem('Employee ID', user.employeeCode ?? "", Icons.badge),
                _buildProfileItem('Full Name', user.employeeName ?? "", Icons.person),
                _buildProfileItem('Joining Date', user.joiningDate ?? "", Icons.calendar_today),
                _buildProfileItem('Department', user.department ?? "", Icons.business),
                _buildProfileItem('Designation', user.designation ?? "", Icons.work),
                _buildProfileItem('Mobile Number', user.mobileNo ?? "", Icons.phone),
                _buildProfileItem('Email Address', user.email ?? "", Icons.email),
                _buildProfileItem('Date of Birth', user.dateOfBirth ?? "", Icons.cake),
                _buildProfileItem('Age', user.age ?? "", Icons.accessibility),
                _buildProfileItem('Tenure', user.tenure ?? "", Icons.timeline),
                const SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
