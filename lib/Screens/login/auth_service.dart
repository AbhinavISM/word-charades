import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yayscribbl/models/user.dart';

import '../../auth_response_sealed.dart';

final authServiceProvider =
    Provider.autoDispose<AuthService>((ref) => AuthService());

class AuthService {
  Future<AuthResponse<User>> logInwithIDAndPassword(
      String employeeID, String password) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedEmplyeeid = prefs.getString('employeeId');
      String? savedPassword = prefs.getString('password');
      print("$savedEmplyeeid $savedPassword");
      if (savedEmplyeeid == null ||
          savedPassword == null ||
          employeeID != savedEmplyeeid ||
          password != savedPassword) {
        // final response = await FirebaseFirestore.instance
        //     .collection("userTable")
        //     .doc(employeeID.trim())
        //     .get();
        late dynamic response = "";
        Map<String, dynamic>? data = response.data();
        if (data == null) {
          return AuthFail(message: "Fill correct Employee Id");
        } else {
          await prefs.setString('employeeId', data['employeeId']);
          await prefs.setString('password', data['password']);
          await prefs.setString('department', data['department']);
          await prefs.setString('designation', data['designation']);
          await prefs.setStringList(
              'children', List<String>.from(data['children']));
          await prefs.setStringList(
              'parent', List<String>.from(data['parent']));
          await prefs.setString('email', data['email']);
          await prefs.setString('fatherName', data['fatherName']);
          await prefs.setString('name', data['name']);
          await prefs.setString('sex', data['sex']);
          await prefs.setString('zone', data['zone']);
          await prefs.setString('phoneNumber', data['phoneNumber']);
          await prefs.setString('image', data['image']);
          await prefs.setString('postLocation', data['postLocation']);
          await prefs.setString(
              'totalTaskTable', jsonEncode(data['totalTaskTable']));
        }
        print("Data=> $data");
        String regpass = data['password'];
        if (regpass == password) {
          return AuthPass(
              message: "Successfully logged in", User.fromJson(data));
        } else {
          return AuthFail(message: "Wrong Password");
        }
      } else {
        if (employeeID.trim() == savedEmplyeeid && password == savedPassword) {
          Map<String, dynamic> data = {
            'employeeId': prefs.getString('employeeId'),
            'password': prefs.getString('password'),
            'department': prefs.getString('department'),
            'designation': prefs.getString('designation'),
            'children': prefs.getStringList('children'),
            'parent': prefs.getStringList('parent'),
            'email': prefs.getString('email'),
            'fatherName': prefs.getString('fatherName'),
            'name': prefs.getString('name'),
            'sex': prefs.getString('sex'),
            'zone': prefs.getString('zone'),
            'phoneNumber': prefs.getString('phoneNumber'),
            'image': prefs.getString('image'),
            'postLocation': prefs.getString('postLocation'),
            'totalTaskTable':
                jsonDecode(prefs.getString('totalTaskTable').toString()),
          };
          return AuthPass(
              message: "Successfully logged in", User.fromJson(data));
        } else {
          return AuthFail(message: "Wrong Password");
        }
      }
    } catch (e) {
      return AuthFail(message: "Some error occured");
    }
  }
}
