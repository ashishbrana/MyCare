/*
*
* ---- NOTE : Payment Constants are located in PaymentConstants.dart File : NOTE ----
*
* */
// https://demo-wexfordbooking.tmpanel.co.uk/MobileAPI/MobileBooking


// test WexFord
String baseUrlWithHttp = "https://demo-wexfordbooking.tmpanel.co.uk/";
String baseUrl = 'demo-wexfordbooking.tmpanel.co.uk';
String nestedUrl = 'MobileAPI/MobileBooking/';
String handleFileJsonUrl =
    'https://pro.tmpanel.co.uk/SyncserviceAPI/tracking/HandleFileJson';

// live WexFord
// String baseUrlWithHttp = "https://ticketbooking.dublincoach.ie/";
// String baseUrl = 'ticketbooking.dublincoach.ie';
// String nestedUrl = 'MobileAPI/MobileBooking/';
// String handleFileJsonUrl =
//     "https://tmpanel.co.uk/SyncserviceAPI/tracking/HandleFileJson";



//LoginModule
/// * [endCurrentVersion] = GetMobileBookingAppVersion.
const String endCurrentVersion = 'GetMobileBookingAppVersion';
/// * [endLogin] = Login.
const String endLogin = 'Login';
/// * [endLogOut] = UserLogout.
const String endLogOut = 'UserLogout';
/// * [endSignUp] = PassengerRegistration.
const String endSignUp = 'PassengerRegistration';
/// * [endRemoveAccount] = RemoveAccount.
const String endRemoveAccount = 'RemoveAccount';
/// * [endForgot] = ForgotPassword.
const String endForgot = 'ForgotPassword';
/// * [endChangePassword] = ChangePassword.
const String endChangePassword = 'ChangePassword';

//MyProfile
/// * [endUpdateCustomerDetails] = UpdateCustomerDetails.
const String endUpdateCustomerDetails = 'UpdateCustomerDetails';
/// * [endCustomerDetails] = GetCustomerDetails.
const String endCustomerDetails = 'GetCustomerDetails';

//OLD TrackingModule
/// * [endNearestStops] = GetNearestStops.
const String endNearestStops = "GetNearestStops";
/// * [endGetTrackToStageName] = GetTrackToStageName.
const String endGetTrackToStageName = 'GetTrackToStageName';
/// * [endGetDirection] = GetJourneyDirection.
const String endGetDirection = 'GetJourneyDirection';
/// * [endGetJourneyList] = GetJourneyList_V1.
const String endGetJourneyList = 'GetJourneyList_V1'; //'GetJourneyList';
/// * [endGetJourneyStopsList] = GetJourneyStopsList.
const String endGetJourneyStopsList = 'GetJourneyStopsList';


//New TrackingModule
/// * [endGetRouteStage] = GetRouteStage.
const String endGetRouteStage = "GetRouteStage";
/// * [endGetStageByRoute] = GetStageByRoute.
const String endGetStageByRoute = 'GetStageByRoute';
/// * [endGetJourney] = GetJourney.
const String endGetJourney = 'GetJourney';
/// * [endGetJourneyTracking] = GetJourneyTraking.
const String endGetJourneyTracking = 'GetJourneyTraking'; //'GetJourneyList';




//Booking EndNodes
/// * [endGetAllFromStages] = GetStageName.
const String endGetAllFromStages = "GetStageName";
/// * [endGetToStageName] = GetToStageName.
const String endGetToStageName = "GetToStageName";
/// * [endGetTicketType] = GetTicketType.
const String endGetTicketType = "GetTicketType";
/// * [endGetPassengerType] = GetPassengerType.
const String endGetPassengerType = "GetPassengerType";
/// * [endGetSearchJourney] = GetSearchJourneyV2.
const String endGetSearchJourney = "GetSearchJourneyV2";
/// * [endApplyPromoCode] = CalculatePromoDisc.
const String endApplyPromoCode = "CalculatePromoDisc";
/// * [endSaveBooking] = SaveBookingInfo.
const String endSaveBooking = "SaveBookingInfo";
/// * [endUpdateBookingDetails] = UpdateBookingDetailStatusV2.
const String endUpdateBookingDetails = "UpdateBookingDetailStatusV2";


// Booking History
/// * [endMyBookingHistory] = GetMyBookingHistory.
const String endMyBookingHistory = "GetMyBookingHistory";
/// * [endSendTicketMail] = SendMailTicket.
const String endSendTicketMail = "SendMailTicket";
/// * [endDownloadTicket] = DownloadTicket.
const String endDownloadTicket = "DownloadTicket";


// Change(Manage) Journey
/// * [endChangeVerifyBooking] = VerifyBooking.
const String endChangeVerifyBooking = "VerifyBooking";
/// * [endGetOurChangeJourneyList] = ChangeTicketJourney.
const String endGetOurChangeJourneyList = "ChangeTicketJourney";
/// * [endChangeJourneyList] = GetOutwardSearchResult.
const String endChangeJourneyList = "GetOutwardSearchResult";
/// * [endSaveChangeTicketBookingInfo] = SaveChangeTicketBookingInfo.
const String endSaveChangeTicketBookingInfo = "SaveChangeTicketBookingInfo";
/// * [endUpdateChangeBooking] = UpdateChangeBookingDetailStatusV1.
const String endUpdateChangeBooking = "UpdateChangeBookingDetailStatusV1";


/// * [endSendLogRecord] LogRecord endpoint for upload logs
const String endSendLogRecord = "LogRecord";
