import 'package:a_chat/features/auth/presentation/screen/signin.dart';
import 'package:a_chat/features/auth/presentation/screen/signup.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home Screen',
          style: TextStyle(color: Colors.white), // ตั้งค่าสีข้อความเป็นสีขาวเพื่อให้เข้ากับพื้นหลังสีเขียว
        ),
        backgroundColor: Colors.green[500], // ตั้งค่าสีพื้นหลัง AppBar ให้เป็นสีเขียว 500
        elevation: 0, // ลบเงาของ AppBar ออกเพื่อความเรียบง่าย
      ),
      body: Container( // ใช้ Container เพื่อให้สามารถกำหนดสีพื้นหลังได้หากต้องการ
        color: Colors.white, // กำหนดสีพื้นหลังของ body เป็นสีขาว (ตามภาพตัวอย่าง)
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 50.0), // ปรับ padding ด้านข้างและด้านบน/ล่าง
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // จัดตำแหน่ง Column ให้อยู่กึ่งกลางแนวตั้ง
              crossAxisAlignment: CrossAxisAlignment.center, // จัดตำแหน่งเนื้อหาใน Column ให้อยู่กึ่งกลางแนวนอน
              children: [
                Image.asset("lib/assets/images/icon-g.png"), //
                SizedBox(height: 50), // เพิ่มระยะห่างหลังรูปภาพ
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.add, color: Colors.white), // ตั้งค่าสีไอคอนเป็นสีขาว
                    label:
                        Text("Register", style: TextStyle(fontSize: 20, color: Colors.white)), // ตั้งค่าสีข้อความเป็นสีขาว
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // ตั้งค่าสีปุ่มเป็นสีเขียว
                      padding: EdgeInsets.symmetric(vertical: 15), // เพิ่ม padding แนวตั้ง
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // เพิ่มมุมโค้งมน
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context){
                          return SignUpScreen();
                        })
                      );
                    },
                  ),
                ),
                SizedBox(height: 20), // เพิ่มระยะห่างระหว่างปุ่ม
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.login, color: Colors.white), // ตั้งค่าสีไอคอนเป็นสีขาว
                    label: Text("Login", style: TextStyle(fontSize: 20, color: Colors.white)), // ตั้งค่าสีข้อความเป็นสีขาว
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // ตั้งค่าสีปุ่มเป็นสีเขียว
                      padding: EdgeInsets.symmetric(vertical: 15), // เพิ่ม padding แนวตั้ง
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10), // เพิ่มมุมโค้งมน
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context){
                          return SignInScreen();
                        })
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}