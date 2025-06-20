// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dendy_app/routes.dart';
import 'package:dendy_app/utils/appcolors.dart';
import 'package:dendy_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' show Client;

class Post {
  final JsonDecoder _decoder = JsonDecoder();
  Client client = Client();

  // post methods data
  Future<dynamic> post(String url, {Map? headers, body}) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    print("connectivityResult$connectivityResult");
    if (connectivityResult.contains(ConnectivityResult.none)) {
      Get.snackbar('Network Error', 'Please check your internet connection!',
          backgroundColor: redColor, colorText: whiteColor);
      return null;
    } else {
      var token = GetStorage().read('access_token');

      print("token$token");
      if (url.contains('signin') ||
          url.contains('forgot_password') ||
          url.contains('reset_password') ||
          token != null) {
        print("yaha tak aaya$baseUrl BBB$url");
        final apiUrl = baseUrl + url;
        print("apiUrl$apiUrl");

        return client
            .post(
          Uri.parse(apiUrl),
          body: body,
          headers: token == null
              ? {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                }
              : {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'Authorization': 'Bearer $token'
                },
        )
            .then((response) async {
          print("response.body${response.body}");
          final dynamic res = response.body;
          final int statusCode = response.statusCode;

          if (statusCode < 200 || statusCode > 400) {
            if (jsonDecode(res) is Map &&
                jsonDecode(res).containsKey('message')) {
              String errorMessage = (jsonDecode(res)['message']).toString();
              if (errorMessage.contains('Unauthenticated')) {
                await GetStorage().erase();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.offAndToNamed(RouteConstant.loginScreen);
                });
              }
              showSnackBar(errorMessage);
            } else {
              showSnackBar(res);
            }
            return 'Error';
          }

          if (response.body.isEmpty) {
            return "1";
          }

          return _decoder.convert(res);
        });
      } else {
        print("jjjj");
        WidgetsBinding.instance.addPostFrameCallback((_) async{
            await GetStorage().erase();
          Get.offAllNamed(RouteConstant.loginScreen);
          // Get.snackbar('Please Login!', 'You are not logged-in!',
          //     backgroundColor: primaryGradient2, colorText: whiteColor);
        });
      }
    }
  }

  Future<dynamic> get(
    String url,
  ) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    print("connectivityResult$connectivityResult");
    if (connectivityResult.contains(ConnectivityResult.none)) {
      Get.snackbar('Network Error', 'Please check your internet connection!',
          backgroundColor: redColor, colorText: whiteColor);
      return null;
    } else {
      var token = GetStorage().read('access_token');

      print("token$token");
      if (url.contains('signin') ||
          url.contains('forgot_password') ||
          url.contains('reset_password') ||
          token != null) {
        print("yaha tak aaya$baseUrl BBB$url");
        final apiUrl = baseUrl + url;

        return client.get(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'
          },
        ).then((response) async {
          print("bbbbhjjj${response.body}");
          final dynamic res = response.body;
          final int statusCode = response.statusCode;
          if (url.contains('logout')) {
            await GetStorage().erase();
          }
          if (statusCode < 200 || statusCode > 400) {
            if (jsonDecode(res) is Map &&
                jsonDecode(res).containsKey('message')) {
              String errorMessage = (jsonDecode(res)['message']).toString();
              if (errorMessage.contains('Unauthenticated')) {
                await GetStorage().erase();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Get.offAndToNamed(RouteConstant.loginScreen);
                });
              }
              showSnackBar(errorMessage);
            } else {
              showSnackBar(res);
            }
            return 'Error';
          }

          if (response.body.isEmpty) {
            return "1";
          }

          return _decoder.convert(res);
        });
      } else {
        print("jjjj");
        WidgetsBinding.instance.addPostFrameCallback((_) async{
            await GetStorage().erase();
          Get.offAllNamed(RouteConstant.loginScreen);
        });
      }
    }
  }
}
