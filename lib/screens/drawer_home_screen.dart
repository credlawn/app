import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../custom/custom_color.dart';
import '../helpers/session_manager.dart'; 
import 'login_screen.dart'; 
import '../models/user.dart'; 
import 'profile_screen.dart';  
import 'package:cached_network_image/cached_network_image.dart';  

class DrawerHomeScreen extends StatelessWidget {
  final User user;

  const DrawerHomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25), 
          bottomRight: Radius.circular(25),
        ),
      ),
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/bg_img2.jpg'),
                  fit: BoxFit.cover
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 90,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: user.userImage?.isNotEmpty ?? false
                            ? CachedNetworkImage(
                                imageUrl: user.userImage!,
                                httpHeaders: {'Cookie': 'sid=${user.sid}'}, 
                                fit: BoxFit.fill, 
                                progressIndicatorBuilder: (context, url, downloadProgress) {
                                  return Center(child: CircularProgressIndicator(value: downloadProgress.progress));  
                                },
                                errorWidget: (context, url, error) {
                                  return Image.asset('assets/image/errorImage.png');  
                                },
                              )
                            : Image.asset('assets/image/profileImage.png', fit: BoxFit.fill),  
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.fullName,  
                      style: GoogleFonts.poppins(
                        fontSize: 20, 
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: Icon(CupertinoIcons.person, color: CustomColor.MainColor, size: 30),
              title: Text('Profile', style: GoogleFonts.poppins(color: CustomColor.MainColor, fontSize: 18)),
              onTap: () {
                Navigator.pop(context); 
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen(user: user)),
                );
              },
            ),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  leading: Icon(Icons.logout, color: CustomColor.MainColor, size: 30),
                  title: Text('Logout', style: GoogleFonts.poppins(color: CustomColor.MainColor, fontSize: 18)),
                  onTap: () async {
                    await SessionManager.logout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()), 
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
