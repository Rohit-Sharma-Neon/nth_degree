import 'package:get/get.dart';
import 'package:on_sight_application/repository/database_managers/app_internet_manager.dart';
import 'package:on_sight_application/repository/web_service_response/verify_otp_response.dart';
import 'package:on_sight_application/repository/web_services/web_service.dart';
import 'package:on_sight_application/routes/app_pages.dart';
import 'package:on_sight_application/screens/update_profile/view_model/profile_controller.dart';
import 'package:on_sight_application/utils/constants.dart';
import 'package:on_sight_application/utils/functions/functions.dart';
import 'package:on_sight_application/utils/secure_storage.dart';
import 'package:on_sight_application/utils/shared_preferences.dart';
import 'package:on_sight_application/utils/strings.dart';

class VerifyScreenController extends GetxController{

  //Api service variable for api call........
  WebService service = WebService();
  //phonevalidation check...........
  RxBool isValidphone= true.obs;
  //otpvalidation check.............
  RxBool isValidOtp= true.obs;
  //button show hide................
  RxBool enableButton = false.obs;




// Api for Verify Otp.......................

  Future<dynamic> verifyOtp(otp) async{
    var response = await service.verifyOtpRequest(otp);
    if(response!=null) {
      if (response.containsKey(error)) {
        return response;
      }
      VerifyOtpResponse responseModel = VerifyOtpResponse.fromJson(response);
      sp!.putString(Preference.ACCESS_TOKEN, responseModel.accessToken.toString());
      SecureStorage().addNewItem("auth_token",responseModel.accessToken.toString());

      ProfileController profileController = ProfileController();
      await profileController.getProfile();
      if(responseModel.signInStatus==RequiredRegistration){
        AnalyticsFireEvent(LoginOrSignUp,
            input: {
              type: "SignUp",
              // user:sp?.getString(Preference.FIRST_NAME)??""/* +" "+sp?.getString(Preference.LAST_NAME)??""*/
            });
        Get.offNamed(Routes.userDetailScreen, arguments: responseModel.asclientId);
      }else{
        AnalyticsFireEvent(LoginOrSignUp,
            input: {
          type: login,
          user:sp?.getString(Preference.FIRST_NAME)??""/* +" "+sp?.getString(Preference.LAST_NAME)??""*/
        });
        sp!.putBool(Preference.IS_LOGGED_IN, true);
        Get.offAllNamed(Routes.dashboardScreen);
        // AppInternetManager appInternetManager = AppInternetManager();
        // var isAsked = await appInternetManager.getAuthPop();
        // if(isAsked!=1){
        //   Get.offAllNamed(Routes.IntroductionTwoStep);
        // }else {
        //   Get.offAllNamed(Routes.dashboardScreen);
        // }
      }
    }
    return response;
  }

  //Api for resend otp......................................

  Future<dynamic> resendOtp(phoneNumber, countryCode) async{
    var response = await service.resendOtpRequest(phoneNumber, countryCode);
    if(response!=null) {
      Get.showSnackbar(const GetSnackBar(message: codeSentSuccessfully,duration: Duration(seconds: 2),));
    }
    return response;
  }



//Validations on Text input field...............
  validate(phoneNumber, otp) {
    if (phoneNumber.isEmpty) {
        isValidphone.value = false;
        enableButton.value = false;
        update();
      return false;
    } else {
        isValidphone.value = true;
        enableButton.value = true;
        update();
    }

    if (otp.isEmpty) {
      isValidOtp.value = false;
      enableButton.value = false;
      update();
      return false;
    }else if(otp.length<4){
      isValidOtp.value = false;
      enableButton.value = false;
      update();
      return false;
    } else {
        isValidOtp.value = true;
        enableButton.value = true;
        update();
    }
    return true;
  }
}