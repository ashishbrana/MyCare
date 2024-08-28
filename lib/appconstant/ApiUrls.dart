import 'package:intl/intl.dart';

String baseUrlWithHttp = "";
String baseUrl = '';
String nestedUrl = '';
String masterURL = "1";
String logoUrl = "";
String deviceType = "";
String appVersion = "";

const String endLogin = 'LoginForm';
const String endTimeSheets = 'timesheets';
const String endSaveTimesheet = 'savetimesheetform';
const String endPickupShift = 'pickupshift';
const String endConfirmShift = 'confirmshift';
const String endAvailableShifts = 'availableshifts';
const String endSaveLocationTime = 'SaveLocationTime';
const String changePass = 'ChangeEmployeePassword';
const String endEmployeeProfile = 'EmployeeProfile';
const String endSaveEmployeeProfile = 'saveEmployeeProfileForm';
const String endClientProfile = 'ClientProfile';
const String endGetDocs = 'getdocs';
const String progressNotesList = 'ProgressNotesList';
const String endClientGroupList = 'ClientGroupList';
const String endCareWorkersList = 'CareWorkersList';
const String endDNSList = 'DSNList';
const String ServiceDetaileByID = 'ServiceDetaileByID';
const String endNoteDetailsByID = 'NoteDetailsByID';
const String endSaveNoteDetails = 'saveNoteDetailsWithConfidential';
const String saveNoteDetailsForGroup = 'saveNoteDetailsForGroup';
const String endSaveNotePicture = 'saveNotePicture';
const String endGetNoteDocs = 'getNotedocs';
const String endDeleteNotePicture = 'DeleteNotePicture';
const String endGetClientSignature = 'getClientSignatureBase64';
const String endGetImageBase64 = 'getNoteImageBase64';
const String endProgressNotesList = 'ProgressNotesList';
const String endsaveDSNDetails = 'saveDSNDetails';
const String updateShiftCommentsAndSendRiskAlert = 'updateShiftCommentsAndSendRiskAlert';


const String endClientFundingDetails = 'ClientFundingDetails';
const String endClientFundingCodeDetails = 'ClientFundingCodeDetails';
const String endClientFundingUsageDetails = 'ClientFundingUsageDetails';
const String getFundingServiceType = 'getFundingServiceType';
const String clientservicetype = 'clientservicetype';
const String endtimesheetsFunding = 'timesheetsFunding';
const String getServiceType = 'getServiceType';
const String getEmployeesLinkedToSS = 'GetEmployeesLinkedToSS';
const String endSaveClientProfile = 'saveClientProfile';
const String createServiceRequest = 'createServiceRequest';
const String updateServiceRequest = 'updateServiceRequest';
const String endDeleteService = 'DeleteService';
const String updateShiftComments = 'updateShiftComments';
const String latestMobileAppVersion = 'LatestMobileAppVersion';

const String twoFactorAuthentication = 'TwoFactorAuthentication';
const String verifyTwoFactorAuthentication = 'VerifyTwoFactorAuthentication';

void setUpAllUrls(String companyCode) {
  baseUrlWithHttp ="https://$companyCode-web.mycaresoftware.com/";
  baseUrl = '$companyCode-web.mycaresoftware.com';
  nestedUrl = 'MobileAPI/v1.asmx/';
  masterURL = "https://$companyCode-web.mycaresoftware.com/MobileAPI/v1.asmx/";
  logoUrl = "https://$companyCode.mycaresoftware.com/Uploads/Organsiation/logo.jpg";

  print(baseUrlWithHttp);
  print(baseUrl);
  print(masterURL);
  print(logoUrl);
}


extension ShortStringDate on DateTime {
  String shortDate(){
    return DateFormat("yyyy/MM/dd").format(this);
  }
}

