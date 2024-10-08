import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../utils/ConstantStrings.dart';
import '../utils/Preferences.dart';
import '../utils/methods.dart';
import 'ApiUrls.dart';
import 'ConnectionStatusSingleton.dart';
import 'GlobalMethods.dart';

class HttpRequestModel {
  final String urlType = "internal";
  final String url;
  final String method;
  final String? body;
  final String? params;
  final String? headerType;
  final String? authMethod;
  bool isDebug;

  HttpRequestModel(
      {required this.url,
      required this.method,
      this.body = '',
      this.params = '',
      this.headerType = '',
      this.authMethod = '',
      this.isDebug = false});
}

class HttpService {
  static http.Client? client;
  late Map<String, String> headers;

  setHeaders(HttpRequestModel httpRequestModel) async {
    if (httpRequestModel.authMethod == '') {
      headers = {'Content-type': 'application/json'};
    } else {
      String token = await Preferences().getPrefString("Tocken");
      headers = {
        'Content-type': 'application/json',
        'Authorization': "bearer $token"
      };
    }
  }

  static Client getHttpClient() {
    return client ?? http.Client();
  }

  void connectionChanged(dynamic hasConnection) {
    isNetworkConnected = hasConnection;
  }

  Future<String> init(
      HttpRequestModel httpRequestModel, GlobalKey<ScaffoldState> keyScaffold,
      [callback]) async {
    if (keyScaffold.currentContext != null &&
        keyScaffold.currentState != null) {
      client = client ?? http.Client();

      ConnectionStatusSingleton connectionStatus =
          ConnectionStatusSingleton.getInstance();
      await setHeaders(httpRequestModel);

      log("URL : ${httpRequestModel.url} PARAMS : ${httpRequestModel.params}");
      isNetworkConnected = await connectionStatus.checkConnection();

      if (isNetworkConnected == false) {
        showSnackBarWithText(keyScaffold.currentState!, stringErrorNoInterNet);
        return Future(() => "");
      }

      try {
        if (httpRequestModel.method == 'PATCH') {
          var url =
              baseUrl.trim() + nestedUrl.trim() + httpRequestModel.url.trim();

          http.Response response =
              await doPatch(url, httpRequestModel.body!, headers);
          log("API_RESPONSE : ${response.body.toString()}");
          return handleResponse(response, keyScaffold, callback);
        }

        if (httpRequestModel.method == 'POST') {
          var url = baseUrlWithHttp.trim() +
              nestedUrl.trim() +
              httpRequestModel.url.trim();

          log(url);
          http.Response response =
              await doPost(url, httpRequestModel.params!, headers);

          log("API_RESPONSE ${httpRequestModel.url} ${httpRequestModel.body}  $headers: ${response.body.toString()}");
          return handleResponse(response, keyScaffold, callback);
        }

        if (httpRequestModel.method == "GET") {
          var url = httpRequestModel.url.trim();

          log(url);

          http.Response response = await callGetMethod(url);
          log("API_RESPONSE : ${response.body.toString()}");
          return await handleResponse(response, keyScaffold, callback);
        }

        if (httpRequestModel.method == "DELETE") {
          var url = baseUrl.trim() + httpRequestModel.url.trim();

          http.Response response = await doDelete(url, headers);
          log("API_RESPONSE : ${response.body.toString()}");
          return handleResponse(response, keyScaffold, callback);
        }
      } catch (e) {
        log("API : ${e.toString()}");
      }
    } else {
      log("ERROR : Scaffold state/Context is null ${httpRequestModel.url}");
    }

    return Future(() => "");
  }

  showServerConnectionRefuseError(GlobalKey<ScaffoldState> keyScaffoldState) {
    showSnackBarWithText(
        keyScaffoldState.currentState!, "Could not connect to the server");
  }

  Future<String> handleResponse(
      Response response, GlobalKey<ScaffoldState> keyScaffoldState,
      [callback]) async {
    if (callback != null) {
      callback();
    }
    switch (response.statusCode) {
      case 200:
        {
          return Future(() => stripHtmlIfNeeded(response.body));
        }
      case 201:
        {
          return Future(() => stripHtmlIfNeeded(response.body));
        }

      case 400:
        {
          try {
            var jsonRes = jsonDecode(response.body);
            Map<String, dynamic> result = jsonRes["errors"];
            String msg = result.values.last;
            showSnackBarWithText(keyScaffoldState.currentState!, msg);
          } catch (e) {
            showSnackBarWithText(keyScaffoldState.currentState!, "Bad Request");
          }
          return Future(() => "");
        }

      case 401:
        {
          showSnackBarWithText(keyScaffoldState.currentState!, "Unauthorized!");
          return Future(() => "");
        }

      case 404:
        {
          showSnackBarWithText(keyScaffoldState.currentState!, "Not Found!");
          return Future(() => "");
        }

      case 405:
        {
          showSnackBarWithText(
              keyScaffoldState.currentState!, "Method Not Allowed!");
          return Future(() => "");
        }

      case 500:
        {
          // showSnackBarWithText(
          //     keyScaffoldState.currentState!, "Internal Server Error!");
          return Future(() => "");
        }

      default:
        {
          try {
            var jsonRes = jsonDecode(response.body);
            Map<String, dynamic> result = jsonRes["errors"];
            String msg = result["detail"];
            log(msg);
            showSnackBarWithText(keyScaffoldState.currentState!, msg);
          } catch (e) {
            showSnackBarWithText(
                keyScaffoldState.currentState!, "Something went wrong!");
          }
          return Future(() => "");
        }
    }
  }



  Future<http.Response> callGetMethod(String subUrl) {
    return getHttpClient()
        .get(Uri.parse(subUrl))
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw TimeoutException('The connection has timed out, Please try again!');
    });
  }

  Future<http.Response> doPatch(
      String subUrl, String body, Map<String, String> headerType) {
    return getHttpClient()
        .patch(Uri.parse(subUrl), headers: headerType, body: body)
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw TimeoutException('The connection has timed out, Please try again!');
    });
  }

  Future<http.Response> doPost(
      String subUrl, String body, Map<String, String> headerType) {
    log("DOPOST $subUrl $headerType $body");
    return getHttpClient()
        .post(Uri.parse(subUrl), headers: headerType, body: body)
        .timeout(const Duration(seconds: 30), onTimeout: () {
      throw TimeoutException('The connection has timed out, Please try again!');
    });
  }

  Future<http.Response> doDelete(
      String subUrl, Map<String, String> headerType) {
    return getHttpClient()
        .delete(Uri.parse(subUrl), headers: headerType)
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw TimeoutException('The connection has timed out, Please try again!');
    });
  }
}

String stripHtmlIfNeeded(String text) {
  return text.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ');
}
