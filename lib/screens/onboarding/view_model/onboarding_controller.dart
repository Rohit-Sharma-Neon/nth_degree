import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_sight_application/repository/web_service_requests/create_resource_request.dart';
import 'package:on_sight_application/repository/web_service_response/create_resource_response.dart';
import 'package:on_sight_application/repository/web_service_response/lead_sheet_response.dart';
import 'package:on_sight_application/repository/web_services/web_service.dart';
import 'package:on_sight_application/routes/app_pages.dart';
import 'package:on_sight_application/screens/onboarding/view_model/onboarding_photos_controller.dart';
import 'package:on_sight_application/screens/onboarding/view_model/onboarding_resource_controller.dart';
import 'package:on_sight_application/utils/connectivity.dart';
import 'package:on_sight_application/utils/constants.dart';
import 'package:on_sight_application/utils/dialogs.dart';
import 'package:on_sight_application/utils/functions/functions.dart';
import 'package:on_sight_application/utils/shared_preferences.dart';
import 'package:on_sight_application/utils/strings.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';


class OnboardingController extends GetxController{
  
  /// Show Number Controller
  TextEditingController showNumberController = TextEditingController();
  /// First Name Controller
  TextEditingController firstNameController = TextEditingController();
  /// last Name Controller
  TextEditingController lastNameController = TextEditingController();
  /// mobile number Controller
  TextEditingController mobileNumberController = TextEditingController();
  /// union Controller
  TextEditingController unionController = TextEditingController();
  /// ssn Controller
  TextEditingController ssnController = TextEditingController();
  /// City Controller
  TextEditingController cityController = TextEditingController();
  /// Classification Controller
  TextEditingController classificationController = TextEditingController();
  /// Note Controller
  TextEditingController noteController = TextEditingController();
  /// check valid first name parameter
  RxBool isValidShowNumber = true.obs;
  /// check valid first name parameter
  RxBool isValidFirstName = true.obs;
  /// check valid last name parameter
  RxBool isValidLastName = true.obs;
  /// check valid mobile number parameter
  RxBool isValidMobileNumber = true.obs;
  /// check valid ssn parameter
  RxBool isValidSSN = true.obs;
  /// Document value
    RxString dropDownDocumentValue = "Document Type".obs;
  /// check valid city parameter
  RxBool isValidCity = true.obs;
  /// Submit button enable / disable
  RxBool enableButton = false.obs;
  /// Submit button enable / disable
  RxBool submitButton = false.obs;
  /// Union Suggestions List
  RxList<String> unionSuggestionsList = <String>[].obs;
  /// checking speech to text status
  final _speechEnabled = false.obs;
  /// instance of speech to text
  Rx<SpeechToText> speechToText = SpeechToText().obs;
  /// Listening variable for comment controller
  RxBool isListening = false.obs;
  /// Selected show number variable
  RxString selectedShow = "".obs;
  /// Webservice Instance to call API Functions
  WebService service = WebService();
  /// variable for selectedOption of entrance type
  RxString selectedOption = selectCategory.obs;
  /// request model for
  Rx<CreateResourceRequest> requestModel = CreateResourceRequest().obs;
  /// variable for show hide suggestion below text field of union number
  RxInt value = 0.obs;


  /// TextInput Validations......................................................

  validateFunc(){
    if (firstNameController.text.isEmpty) {
      enableButton.value = false;
      update();
      return false;
    } else {
      enableButton.value = true;
    }
    if (lastNameController.text.isEmpty) {
      enableButton.value = false;
      update();
      return false;
    } else {
      enableButton.value = true;
    }
    if (ssnController.text.isEmpty) {
      enableButton.value = false;
      update();
      return false;
    } else if(ssnController.text.length<4){
      enableButton.value = false;
      update();
      return false;
    }else {
    enableButton.value = true;
    }
    if(mobileNumberController.text.length < 8){
      enableButton.value = false;
      update();
      return false;
    }else{
      enableButton.value = true;

    }
    if (cityController.text.isEmpty) {
      enableButton.value = false;
      update();
      return false;
    } else {
      enableButton.value = true;
    }
    update();
    return true;
  }

  /// validation on submit button
  validsubmit(){
    if (firstNameController.text.isEmpty) {
      enableButton.value = false;
      isValidFirstName.value = false;
      return false;
    } else {
      enableButton.value = true;
      isValidFirstName.value = true;
    }
    if (lastNameController.text.isEmpty) {
      enableButton.value = false;
      isValidLastName.value = false;
      return false;
    } else {
      isValidLastName.value = true;
      enableButton.value = true;
    }
    if (mobileNumberController.text.length < 8) {
      enableButton.value = false;
      isValidMobileNumber.value = false;
      return false;
    } else {
      isValidLastName.value = true;
      enableButton.value = true;
    }
    if (ssnController.text.isEmpty) {
      enableButton.value = false;
      isValidSSN.value = false;
      return false;
    } else if(ssnController.text.length<4){
      isValidSSN.value = false;
      enableButton.value = false;
      return false;
    }else {
      isValidSSN.value = true;
      enableButton.value = true;
    }
    if (cityController.text.isEmpty) {
      enableButton.value = false;
      isValidCity.value = false;
      return false;
    } else {
      enableButton.value = true;
      isValidCity.value = true;
    }
    update();
  }


  ///Validate Show Number
  validate(){
    if(showNumberController.text.isEmpty){
      submitButton.value = false;
    }else if(showNumberController.text.length<5){
      submitButton.value = false;
    }else{
      submitButton.value = true;
    }
    update();
  }


  /// This has to happen only once per app
  void initSpeech() async {
    _speechEnabled.value = await speechToText.value.initialize();
    update();
  }



  /// Each time to start a speech recognition session
  void startListening() async {
    isListening.value = true;
    update();

    await speechToText.value.listen(onResult: (result) {
      stopListening();
      onSpeechResult(result);
    }).catchError((onError) {
      stopListening();
      log(onError.toString());
      isListening.value = false;
      update();
    });

    update();
  }

  /// Manually stop the active speech recognition session
  void stopListening() async {
    isListening.value = false;
    await speechToText.value.stop();
    update();
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  onSpeechResult(SpeechRecognitionResult result) {
    isListening.value = false;
    noteController.text = result.recognizedWords;
    update();
  }


  Future<dynamic> getSheetDetails(show, isLoading) async {

    OnboardingResourceController onboardingResourceController = Get.find<OnboardingResourceController>();
    selectedShow.value = show;
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    if(isNetActive){
      var response = await service.getLeadSheetDetails(show, isLoading);
      if(response!=null) {
        if (!response.toString().contains(error)) {

          LeadSheetResponse leadSheetResponse = LeadSheetResponse.fromJson(response);

          if(leadSheetResponse.showDetails!=null) {
            cityController.text = leadSheetResponse.showDetails!.showCity.toString();
            update();
          }

          if(selectedOption==fileDocuments){
            onboardingResourceController.getOasisResourcesApi();
          }else{
            Get.toNamed(Routes.onboardingRegistration);
          }
        }else{
          if(response.toString().contains(showNumberNotFound)){
            isValidShowNumber.value = false;
            update();
          }
        }

      }
      submitButton.value = true;
      update();
      return response;
    }else{
      Get.snackbar(alert,noInternet);
    }
  }

  /// API function for creating resource
  Future<dynamic> createResourceApi() async {

    OnBoardingPhotosController onBoardingPhotosController;
    requestModel.value.firstName = firstNameController.text.trim();
    requestModel.value.lastName = lastNameController.text.trim();
    try {
      requestModel.value.mobilePhone = mobileNumberController.text;
    }catch(e){
      requestModel.value.mobilePhone = '';
    }
    requestModel.value.union = unionController.text.trim();
    requestModel.value.ssn = ssnController.text.trim();
    requestModel.value.city = cityController.text.trim();
    requestModel.value.classification = classificationController.text.trim();
    requestModel.value.notes = noteController.text.trim();
    requestModel.value.show = selectedShow.value;
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    if(isNetActive){
      var response = await service.createResourceOnboarding(requestModel.toJson());
      if(response!=null) {

        if (response.toString().contains("ItemId")) {
        CreateResourceResponse createResourceResponse = CreateResourceResponse.fromJson(response);
        AnalyticsFireEvent(OasisResourceCreated, input: {
          "ssn":createResourceResponse.ssn??"",
          user:sp?.getString(Preference.FIRST_NAME)??"" /*+" "+sp?.getString(Preference.LAST_NAME)??""*/
        });
        requestModel.value.itemId = num.parse(createResourceResponse.itemId.toString());
        sp?.putInt(Preference.ACTIVITY_TRACKER, ((sp?.getInt(Preference.ACTIVITY_TRACKER)??0)+1));
          dialogAction(Get.context!, alert: resourceCreatedSuccessfully,
              title: doYouWantToAddDocument,
              onTapYes: () {
                firstNameController.clear();
                lastNameController.clear();
                mobileNumberController.clear();
                unionController.clear();
                ssnController.clear();
                cityController.clear();
                classificationController.clear();
                noteController.clear();
                enableButton.value = false;
                update();
                Get.back();
                if(Get.isRegistered<OnBoardingPhotosController>()){
                  onBoardingPhotosController = Get.find<OnBoardingPhotosController>();
                }else{
                  onBoardingPhotosController = Get.put(OnBoardingPhotosController());
                }
                onBoardingPhotosController.getCategory(itemId: createResourceResponse.itemId);
                },
              onTapNo: () {
                firstNameController.clear();
                lastNameController.clear();
                mobileNumberController.clear();
                unionController.clear();
                ssnController.clear();
                cityController.clear();
                classificationController.clear();
                noteController.clear();
                enableButton.value = false;
                update();
                Get.back();
                Get.back();
              });

        }else{
          if(response.toString().contains(showNumberNotFound)){
            isValidShowNumber.value = false;
            update();
          }
        }

      }
      update();
      return response;
    }else{
      Get.snackbar(alert,noInternet);
    }
  }

  /// API function for getting Union Suggestions
  Future<dynamic> getUnionSuggestions() async {
    bool isNetActive = await ConnectionStatus.getInstance().checkConnection();
    if(isNetActive){
      var response = await service.getUnionSuggestionsList()as List;
      if (!response.toString().contains(error)) {
        List<String> localList = [];
        response.forEach((element) {
          localList.add(element);
        });
        localList.sort((a, b) => a.toString().compareTo(b.toString()));
        if (localList.length > 0) {
          unionSuggestionsList.value = localList;
          unionSuggestionsList.refresh();
          update();
        }
      }
      update();
      return response;
    }
  }
}