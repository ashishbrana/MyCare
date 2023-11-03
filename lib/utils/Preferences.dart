import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String prefToken = "token";
  static const String prefLastLatitude = "lastLatitude";
  static const String prefLastLongitude = "lastLongitude";
  static const String prefLogLevel = 'LogLevel';

  //booking
  static const String prefTransactionStartTime = 'TransactionStartTime';
  static const String prefTransactionTimeBookingId = 'TransactionTimeBookingId';
  static const String prefBookingId = 'bookingId';
  static const String prefVendorTnxCode = 'vendorTnxCode';

  //Device
  static const String prefDeviceBundleIdentifier = 'deviceBundleIdentifier';
  static const String prefDeviceOS = 'DeviceOS';
  static const String prefAppVersion = 'appVersion';

  // Users
  static const String prefIsLoggedInForFirstTime = 'isLoggedInForFirstTime';
  static const String prefIsLoggedIn = 'is_loggedIn';
  static const String prefIsGuestData= 'is_guestData';
  static const String prefUsername = 'username';
  static const String prefCustomerId = 'custId';
  static const String prefUserIdStripe = 'custIdStripe';
  static const String prefEmailCustomer = 'customerEmail';
  static const String prefFirstName = 'firstName';
  static const String prefLastName = 'lastName';
  static const String prefPassword = 'password';
  static const String prefAddressOne= 'addressOne';
  static const String prefAddressTwo= 'addressTwo';
  static const String prefCity= 'city';
  static const String prefPostCode= 'postCode';
  static const String prefState= 'state';
  static const String prefCountry= 'country';
  static const String prefPhone= 'phone';
  static const String prefDeviceType = 'device_type';
  static const String prefFirebaseToken = 'firebasetoken';

  setPrefString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<String> getPrefString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? "";
  }

  setPrefInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  Future<int> getPrefInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  setPrefDouble(String key, double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value);
  }

  Future<double> getPrefDouble(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? 0.0;
  }

  setPrefBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<bool> getPrefBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }
}
