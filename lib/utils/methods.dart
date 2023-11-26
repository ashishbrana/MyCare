import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

// import 'package:geolocator/geolocator.dart';
// import 'package:platform_maps_flutter/platform_maps_flutter.dart';
import 'dart:ui' as ui;
import '../Network/ApiUrls.dart';

Future<bool> isConnected() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return true;
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return true;
  }
  return false;
}

showSnackBarWithText(ScaffoldState? scaffoldState, String strText,
    {Color color = Colors.redAccent,
    int duration = 2,
    void Function()? onPressOfOk}) {
  final snackBar = SnackBar(
    // behavior: SnackBarBehavior.floating,
    backgroundColor: color,
    content: Text(
      strText,
      style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontFamily: 'Poppins'),
    ),
    action: SnackBarAction(
      label: 'OK',
      textColor: Colors.white,
      onPressed: onPressOfOk ?? () {},
    ),
    duration: Duration(seconds: duration),
  );
  if (scaffoldState != null && scaffoldState.context != null) {
    ScaffoldMessenger.of(scaffoldState.context).showSnackBar(snackBar);
  }
}

DateTime getDateTime(String date) {
  try {
    return (DateFormat("yyyy-MM-dd HH:mm:ss")
            .parse(date.replaceAll("/", ""), true))
        .toLocal();
  } catch (e) {
    print(e);
    return DateTime.now();
  }
}

DateTime? getDateTimeFromEpochTime(String date) {
  try {
    return DateTime.fromMillisecondsSinceEpoch(
            int.parse(date.replaceAll("/Date(", "").replaceAll(")/", "")),
            isUtc: true)
        .toLocal();
  } catch (e) {
    print(e);
    return null;
  }
}

Uri getUrl(String apiName, {Map<String, dynamic>? params}) {
  var uri = Uri.https(baseUrl, nestedUrl + apiName, params);
  return uri;
}

bool _isLoading = false;
final OverlayEntry overlayEntry = OverlayEntry(
  builder: (context) => Container(
    color: Colors.black.withOpacity(0.5),
    child: Center(
      child: Container(
        height: 45.0,
        width: 45.0,
        decoration:
            const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
        child: Container(
          margin: const EdgeInsets.all(5.0),
          child: const CircularProgressIndicator(
            backgroundColor: Colors.green,
            strokeWidth: 5.0,
          ),
        ),
      ),
    ),
  ),
);
OverlayState? overlayStates;

getOverlay(BuildContext context) {
  overlayStates = Overlay.of(context);

  if (overlayEntry != null && !_isLoading && overlayStates != null) {
    overlayStates!.insert(overlayEntry);
    _isLoading = true;
  }
}

removeOverlay() {
  print("_isLoading : $_isLoading && ${overlayEntry != null}");
  if (_isLoading && overlayEntry != null) {
    _isLoading = false;
    overlayEntry.remove();
  }
}

// Future<BitmapDescriptor> getBitmapDescriptorFormAsset(
//     String path, int width) async {
//   ByteData data = await rootBundle.load(path);
//   ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
//       targetWidth: width);
//   ui.FrameInfo fi = await codec.getNextFrame();
//   final Uint8List markerIcon =
//       (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
//           .buffer
//           .asUint8List();
//   return BitmapDescriptor.fromBytes(markerIcon);
// }

closeKeyboard() {
  if (FocusManager.instance.primaryFocus != null) {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

// Future<bool> isLocationEnable() async {
//   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   print("Location enable : $serviceEnabled");
//   if (!serviceEnabled) {
//     // Location services are not enabled don't continue
//     // accessing the position and request users of the
//     // App to enable the location services.
//     // return Future.error('Location services are disabled.');
//     print("Location Is not enable");
//     //await Geolocator.openLocationSettings();
//
//     return await Geolocator.isLocationServiceEnabled();
//   }
//   return Future(() => true);
// }

// Future<bool> isLocationPermissionGiven() async {
//   LocationPermission permission;
//
//   permission = await Geolocator.checkPermission();
//   print("Location Permission : denied1$permission");
//   if (permission == LocationPermission.always ||
//       permission == LocationPermission.whileInUse) {
//     print("Location Permission : granted");
//     return Future(() => true);
//   }
//
//   if (permission == LocationPermission.denied) {
//     print("Location Permission : denied1");
//     permission = await Geolocator.requestPermission();
//     print("Location Permission : denied1$permission");
//     if (permission == LocationPermission.whileInUse ||
//         permission == LocationPermission.always) {
//       print("Location Permission : granted");
//       return Future(() => true);
//     }
//     if (permission == LocationPermission.denied) {
//       return Future(() => false);
//     }
//     if (permission == LocationPermission.deniedForever) {
//       await Geolocator.openAppSettings();
//       permission = await Geolocator.checkPermission();
//
//       print(
//           "Location Permission : granted ${permission == LocationPermission.whileInUse || permission == LocationPermission.always}");
//       return Future(() =>
//           permission == LocationPermission.whileInUse ||
//           permission == LocationPermission.always);
//     }
//     return Future(() => false);
//   }
//
//   if (permission == LocationPermission.deniedForever) {
//     print("Location Permission : grantedForever");
//     // Permissions are denied forever, handle appropriately.
//
//     //opening location setting
//     await Geolocator.openAppSettings();
//     permission = await Geolocator.checkPermission();
//
//     print(
//         "Location Permission : granted ${permission == LocationPermission.whileInUse || permission == LocationPermission.always}");
//     return Future(() =>
//         permission == LocationPermission.whileInUse ||
//         permission == LocationPermission.always);
//
//     return Future(() => false);
//     // return Future.error('Location permissions are permanently denied, we cannot request permissions.');
//   }
//   return Future(() => false);
// }

// Future<BitmapDescriptor> getBitmapDescriptorFormAsset(String assetPath) async {
//   return BitmapDescriptor.fromAssetImage(
//     const ImageConfiguration(devicePixelRatio: 5.5),
//     assetPath,
//   );
// }

makeFirstLetterCapital(TextEditingController controller) {
  String? value = controller.text;
  if (value.isNotEmpty) {
    if (value.length > 1) {
      controller.text =
          "${value[0].toUpperCase()}${value.length > 1 ? value.substring(1) : ""}";
    } else {
      controller.text = value[0].toUpperCase();
    }
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
    return;
  }
  return;
}
