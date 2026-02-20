import 'dart:convert';
import 'package:get/get_connect.dart';
import 'package:project_structure/core/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum METHODE { get, post, delete, update }

class ApiBaseHelper extends GetConnect {
  final String baseurl = Constants.apiBaseUrl;
  Map<String, String> defaultHeader({bool isAuthorize = false, String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (isAuthorize && token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<dynamic> onApiRequesting({
    required String endPoint,
    required METHODE methode,
    bool? isAuthorize,
    Map<String, String>? header,
    Map<String, dynamic>? body,
  }) async {
    final fullUrl = baseurl + endPoint;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = defaultHeader(isAuthorize: true, token: token);

    try {
      switch (methode) {
        case METHODE.get:
          final response = await get(fullUrl, headers: header ?? headers);
          return _returnResponse(response);
        case METHODE.post:
          if (body != null) {
            final response =
                await post(fullUrl, json.encode(body), headers: headers);
            return _returnResponse(response);
          }
          return Future.error(
              const ErrorModel(bodyString: 'Body must be included'));

        case METHODE.delete:
          final response = await delete(fullUrl, headers: headers);
          return _returnResponse(response);
        case METHODE.update:
          if (body != null) {
            final response =
                await put(fullUrl, json.encode(body), headers: headers);
            return _returnResponse(response);
          }
          return Future.error(
              const ErrorModel(bodyString: 'Body must be included'));
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  dynamic _returnResponse(Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.bodyString ?? '');
        return responseJson;
      case 201:
        var responseJson = json.decode(response.bodyString ?? '');
        return responseJson;
      case 202:
        var responseJson = json.decode(response.bodyString ?? '');
        return responseJson;
      case 404:
        return Future.error(
          ErrorModel(
            statusCode: response.statusCode,
            bodyString: json.decode(response.bodyString ?? ''),
          ),
        );
      case 400:
        return Future.error(
          ErrorModel(
            statusCode: response.statusCode,
            bodyString: json.decode(response.bodyString ?? ''),
          ),
        );
      case 401:
      case 403:
        return Future.error(
          ErrorModel(
            statusCode: response.statusCode,
            bodyString: json.decode(response.bodyString ?? ''),
          ),
        );
      case 500:
        break;
      default:
        return Future.error(
          ErrorModel(
            statusCode: response.statusCode,
            bodyString: json.decode(response.bodyString ?? ''),
          ),
        );
    }
  }
}

class ErrorModel {
  final int? statusCode;
  final dynamic bodyString;
  const ErrorModel({this.statusCode, this.bodyString});
}
