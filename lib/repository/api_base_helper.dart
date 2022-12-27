import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:on_sight_application/repository/web_service_response/error_model.dart';
import 'package:on_sight_application/repository/web_service_response/error_response.dart';
import 'package:on_sight_application/utils/connectivity.dart';
import 'package:on_sight_application/utils/constants.dart';
import 'package:on_sight_application/utils/dialogs.dart';
import 'package:on_sight_application/utils/end_point.dart';
import 'package:on_sight_application/utils/shared_preferences.dart';
import 'package:on_sight_application/utils/strings.dart';
import 'app_exception.dart';

class ApiBaseHelper{


  // post api call method.....................................................................................................
  Future<dynamic> postApiCall(String url, Map<String, dynamic> jsonData,) async {
    var context =  Get.context;
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    var deviceId = await getDeviceId();
    if (isNetActive) {
      showLoader(context);
      var responseJson;

      Map<String, String> apiHeader = {
        EndPointMessages.AUTHORIZATION_KEY:EndPointMessages.BEARER_VALUE+ sp!.getString(Preference.ACCESS_TOKEN).toString(),
        EndPointKeys.acceptKey: 'application/json',
        EndPointKeys.contentType: 'application/json',
        EndPointMessages.USERAGENT_KEY: deviceId,
      };
      print("ApiUrl=========>>>> ${url}");
      print("apiHeader=========>>>> $apiHeader");
      print("request=========>>>> ${jsonEncode(jsonData)}");

      try {
        final http.Response response = await http.post(
          Uri.parse(url),
          headers: apiHeader,
          body: jsonEncode(jsonData),
        ).timeout(const Duration(seconds: 60)).catchError((error) async {
          Get.back();
          Get.snackbar(alert, pleaseCheckInternet);
          return await Future.error(error);
        });
        Get.back();

        print("statusCode=========>>>> ${response.statusCode}");
        print("response=========>>>> ${response.body}");

        try {
          responseJson = _returnResponse(response);

        } catch (e) {}
      } on SocketException {
        //showToastMessage("No Internet connection");
        Get.back();
        throw FetchDataException(noInternet);
      }
      return responseJson;
    } else
    {
      Get.snackbar(alert,noInternet);

     // internetConnectionDialog(context);
    }
  }

  // post api call method.....................................................................................................
  Future<dynamic> deleteApiCall(String url, Map<String, dynamic> jsonData,) async {
    var context =  Get.context;
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    var deviceId = await getDeviceId();
    if (isNetActive) {
      showLoader(context);
      var responseJson;

      Map<String, String> apiHeader = {
        EndPointMessages.AUTHORIZATION_KEY:EndPointMessages.BEARER_VALUE+ sp!.getString(Preference.ACCESS_TOKEN).toString(),
        EndPointKeys.acceptKey: 'application/json',
        EndPointKeys.contentType: 'application/json',
        EndPointMessages.USERAGENT_KEY: deviceId,
      };
      print("ApiUrl=========>>>> ${url}");
      print("apiHeader=========>>>> $apiHeader");
      print("request=========>>>> ${jsonEncode(jsonData)}");

      try {
        final http.Response response = await http.delete(
          Uri.parse(url),
          headers: apiHeader,
          body: jsonEncode(jsonData),
        ).timeout(const Duration(seconds: 120)).catchError((error) async {
          Get.back();
          Get.snackbar(alert, pleaseCheckInternet);
          return await Future.error(error);
        });
        Get.back();

        print("statusCode=========>>>> ${response.statusCode}");
        print("response=========>>>> ${response.body}");

        try {
          responseJson = _returnResponse(response);

        } catch (e) {}
      } on SocketException {
        //showToastMessage("No Internet connection");
        Get.back();
        throw FetchDataException(noInternet);
      }
      return responseJson;
    } else
    {
      Get.snackbar(alert,noInternet);

      // internetConnectionDialog(context);
    }
  }


  // post api call method.....................................................................................................
  Future<dynamic> postApiCallFieldIssue(String url, Map<String, dynamic> jsonData,) async {
    var context =  Get.context;
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    var deviceId = await getDeviceId();
    if (isNetActive) {
      showLoader(context);

      Map<String, String> apiHeader = {
        EndPointMessages.AUTHORIZATION_KEY:EndPointMessages.BEARER_VALUE+ sp!.getString(Preference.ACCESS_TOKEN).toString(),
        EndPointKeys.acceptKey: 'application/json',
        EndPointKeys.contentType: 'application/json',
        EndPointMessages.USERAGENT_KEY: deviceId,
      };
      print("ApiUrl=========>>>> ${url}");
      print("apiHeader=========>>>> $apiHeader");
      print("request=========>>>> ${jsonEncode(jsonData)}");

      try {
        final http.Response response = await http.post(
          Uri.parse(url),
          headers: apiHeader,
          body: jsonEncode(jsonData),
        ).timeout(const Duration(seconds: 60)).catchError((error){
          Get.back();
          Get.snackbar(alert, pleaseCheckInternet);
        });
        Get.back();

        print("statusCode=========>>>> ${response.statusCode}");
        print("response=========>>>> ${response.body}");

        try {
         return response;

        } catch (e) {}
      } on SocketException {
        //showToastMessage("No Internet connection");
        Get.back();
        throw FetchDataException(noInternet);
      }
      return "Error";
    } else
    {
      Get.snackbar(alert,noInternet);

      // internetConnectionDialog(context);
    }
  }

  //Get api call method...............................................................................
  Future<dynamic> getApiCall(String url,{isLoading = true}) async {
    var context =  Get.context;
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    var deviceId = await getDeviceId();
    if (isNetActive) {
      if(isLoading) {
        showLoader(context);
      }
      var responseJson;

      Map<String, String> apiHeader = {
        EndPointMessages.AUTHORIZATION_KEY:EndPointMessages.BEARER_VALUE+ sp!.getString(Preference.ACCESS_TOKEN).toString(),
        EndPointKeys.acceptKey: 'application/json',
        EndPointKeys.contentType: 'application/json',
        EndPointMessages.USERAGENT_KEY: deviceId,
      };
      print("ApiUrl=========>>>> ${url}");
      print("apiHeader=========>>>> $apiHeader");

      try {
        final http.Response response = await http.get(
          Uri.parse(url),
          headers: apiHeader,
        ).timeout(const Duration(seconds: 60)).catchError((error) async {
          if(isLoading) {
            Get.closeAllSnackbars();
          Get.back();
          }
          Get.snackbar(alert, pleaseCheckInternet);
          return await Future.error(error);
        });
        if(isLoading) {
          Get.closeAllSnackbars();
          Get.back();
        }

        print("statusCode=========>>>> ${response.statusCode}");
        print("response=========>>>> ${response.body}");

        try {
          responseJson = _returnResponse(response);


        } catch (e) {if(isLoading) {
          Get.closeAllSnackbars();
          Get.back();
        }}
      } on SocketException {
        if(isLoading) {
          Get.closeAllSnackbars();
          Get.back();
        }
        return "No Internet";
      }
      return responseJson;
    } else
    {
      Get.closeAllSnackbars();
      Get.closeCurrentSnackbar();
      Get.snackbar(alert, noInternet);
      return "No Internet";
    }
  }

  //Get api call method Field Issue...........................................................................................
  Future<dynamic> getApiCallFieldIssue(String url,{isLoading = true}) async {
    var context =  Get.context;
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    var deviceId = await getDeviceId();
    if (isNetActive) {
      if(isLoading) {
        showLoader(context);
      }
      var responseJson;

      Map<String, String> apiHeader = {
        EndPointMessages.AUTHORIZATION_KEY:EndPointMessages.BEARER_VALUE+ sp!.getString(Preference.ACCESS_TOKEN).toString(),
        EndPointKeys.acceptKey: 'application/json',
        EndPointKeys.contentType: 'application/json',
        EndPointMessages.USERAGENT_KEY: deviceId,
      };
      print("ApiUrl=========>>>> ${url}");
      print("apiHeader=========>>>> $apiHeader");

      try {
        final http.Response response = await http.get(
          Uri.parse(url),
          headers: apiHeader,
        ).timeout(const Duration(seconds: 60)).catchError((error){
          if(isLoading) {
            Get.closeAllSnackbars();
            Get.back();
          }
          Get.snackbar(alert, pleaseCheckInternet);
        });
        if(isLoading) {
          Get.closeAllSnackbars();
          Get.back();
        }

        print("statusCode=========>>>> ${response.statusCode}");
        print("response=========>>>> ${response.body}");

        try {
          return response;


        } catch (e) {if(isLoading) {
          Get.closeAllSnackbars();
          Get.back();
        }}
      } on SocketException {
        if(isLoading) {
          Get.closeAllSnackbars();
          Get.back();
        }
        return "No Internet";
      }
      return responseJson;
    } else
    {
      Get.closeCurrentSnackbar();
      Get.closeAllSnackbars();
      Get.snackbar(alert, noInternet);
      return "No Internet";
    }
  }




  //MultipartRequest api call method..........................................................................................

  Future<dynamic> multiPartRequest(String url, Map<String, String>fieldMap, List<http.MultipartFile> listImage, token) async {
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    var deviceId = await getDeviceId();
    if (isNetActive) {

      var response;
      var responseJson;

      print("ApiUrl=========>>>> ${url}");
      print("Token=========>>>> ${token}");

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse(url)
        );
        request.headers[EndPointMessages.AUTHORIZATION_KEY] = EndPointMessages.BEARER_VALUE+ token.toString();
        request.headers[EndPointKeys.contentType] = 'multipart/form-data';
        request.headers[EndPointMessages.USERAGENT_KEY] = deviceId;
        request.fields.addAll(fieldMap);
        request.files.addAll(listImage);
        print(request.fields);
        print(request.files.first.field.toString() +" "+request.files.first.filename.toString());
        response = await request.send();
        var res =  await response.stream.bytesToString();
        print("statusCode=========>>>> ${response.statusCode}");
        print("response=========>>>> ${res}");

        try {

            final JsonDecoder _decoder = new JsonDecoder();
            return _decoder.convert(res.toString());

        } catch (e) {

        }
      }


  /*    on SocketException {
        Get.snackbar(alert, noInternet);
        return "No Internet";
      }*/
      catch (error){
        print(error);
        return "error";
      }
      return responseJson;
    } else
    {
      return "error";
    }
  }


  //MultipartRequest api call method..........................................................................................

  Future<dynamic> multiPartRequestPromopictures(String url, Map<String, String>fieldMap, List<http.MultipartFile> listImage, token) async {
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    var deviceId = await getDeviceId();
    if (isNetActive) {

      var response;
      var responseJson;

      print("ApiUrl=========>>>> ${url}");
      print("Token=========>>>> ${token}");

      try {
        var request = http.MultipartRequest(
            'POST',
            Uri.parse(url)
        );
        request.headers[EndPointMessages.AUTHORIZATION_KEY] = EndPointMessages.BEARER_VALUE+ token.toString();
        request.headers[EndPointKeys.contentType] = 'multipart/form-data';
        request.headers[EndPointMessages.USERAGENT_KEY] = deviceId;
        request.fields.addAll(fieldMap);
        request.files.addAll(listImage);
        print(request.fields);
        print(request.files.first.field.toString() +" "+request.files.first.filename.toString());
        response = await request.send();
        var res =  await response.stream.bytesToString();
        print("statusCode=========>>>> ${response.statusCode}");
        print("response=========>>>> ${res}");

        try {
          if(response.statusCode.toString()=="200"){
            return response.statusCode.toString();

          }else if(response.statusCode.toString()=="401"){

            if(response!=null){
              final JsonDecoder _decoder = new JsonDecoder();
              responseJson = _decoder.convert(res.toString());
              Get.showSnackbar(GetSnackBar(message: responseJson["Error"]["Message"].toString(),duration: Duration(seconds: 2),));
              return responseJson;
            }
          }else if(response.statusCode.toString()=="500"){
            if(response!=null){
              var responseJson = json.decode(response.body.toString());
              ErrorResponse errorModel =  ErrorResponse.fromJson(responseJson);
              Get.showSnackbar(GetSnackBar(message: errorModel.errorDescription.toString(),duration: Duration(seconds: 2),));
              return responseJson;
            }
          }


        } catch (e) {

        }
      }


      /*    on SocketException {
        Get.snackbar(alert, noInternet);
        return "No Internet";
      }*/
      catch (error){
        print(error);
        return "error";
      }
      return responseJson;
    } else
    {
      Get.snackbar(alert, noInternet);
      return "error";
    }
  }

  // Return Reponse Method....................................................................................................
  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        return responseJson;
        case 201:
          var responseJson = json.decode(response.body.toString());
          ErrorResponse errorModel =  ErrorResponse.fromJson(responseJson);
          Get.showSnackbar(GetSnackBar(message: errorModel.errorDescription,duration: Duration(seconds: 2),));
          return responseJson;
      case 400:
        var responseJson = json.decode(response.body.toString());
        ErrorResponse errorModel =  ErrorResponse.fromJson(responseJson);
        Get.showSnackbar(GetSnackBar(message: errorModel.errorDescription,duration: Duration(seconds: 2),));
        return responseJson;
      case 401:
        var responseJson = json.decode(response.body.toString());
        ErrorModel errorModel =  ErrorModel.fromJson(responseJson);
        Get.showSnackbar(GetSnackBar(message: errorModel.error?.message,duration: Duration(seconds: 2),));
        return responseJson;
      case 403:
        var responseJson = json.decode(response.body.toString());
        ErrorResponse errorModel =  ErrorResponse.fromJson(responseJson);
        Get.showSnackbar(GetSnackBar(message: errorModel.errorDescription,duration: Duration(seconds: 2),));
        return responseJson;
      case 404:
        var responseJson = json.decode(response.body.toString());
        ErrorResponse errorModel =  ErrorResponse.fromJson(responseJson);
        Get.showSnackbar(GetSnackBar(message: errorModel.errorDescription,duration: Duration(seconds: 2),));
        return responseJson;
      case 500:
        var responseJson = json.decode(response.body.toString());
        ErrorResponse errorModel =  ErrorResponse.fromJson(responseJson);
        Get.showSnackbar(GetSnackBar(message: errorModel.errorDescription.toString(),duration: Duration(seconds: 2),));
        return responseJson;


      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }

  // For getting device id which will be added in header of each request...................
  getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
  }
}