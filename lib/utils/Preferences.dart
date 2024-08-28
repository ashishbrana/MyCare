import 'package:rcare_2/screen/Login/model/LoginResponseModel.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Preferences {
  static const String prefAuthCode = "auth_code";
  static const String prefAccountType = "accountType";
  static const String prefUserID = "userId";
  static const String prefUserFullName = "prefUserFullName";
  static const String prefCompanyCode = "prefComeCode";
  static const String prefEndofServiceDate = "endofServiceDate";
  static const String prefIs2FA = "is2FA";
  static const String prefAuthneticated = "authneticated";
  static const String prefBioAuthneticated = "bioauthneticated";

  void setLoginPreferences(LoginResponseModel responseModel, String companyCode) {
    setPrefString(prefAuthCode, responseModel.authcode ?? "");
    setPrefInt(prefAccountType, responseModel.accountType ?? 0);
    setPrefInt(prefUserID, responseModel.userid ?? 0);
    setPrefString(prefUserFullName, responseModel.fullName ?? "");
    setPrefString(prefCompanyCode, companyCode ?? "");
    setPrefBool(prefIs2FA, responseModel.is2FA ?? false);
    setPrefBool(prefAuthneticated, false);
    setPrefBool(prefBioAuthneticated, false);
  }
  void reset() {
    setPrefString(prefAuthCode, "");
    setPrefInt(prefAccountType, 0);
    setPrefInt(prefUserID, 0);
    setPrefBool(prefIs2FA, false);
    setPrefBool(prefAuthneticated, false);
    setPrefBool(prefBioAuthneticated, false);
  }

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
