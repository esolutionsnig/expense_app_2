import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CallApi {
  // Local URL
  // final String _url = 'http://10.1.93.6:8001/api/v1/';
  // Live URL
  final String _url = 'https://xlafricagroup.com/icmsportal/api/v1/';

  getBaseUrl() {
    var fullUrl = _url;
    return fullUrl;
  }

  // Post Request
  postData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.post(fullUrl,
        body: jsonEncode(data), headers: _setHeaders());
  }

  // Retrieve Data
  getData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    return await http.get(fullUrl, headers: _setHeaders());
  }

  // Post Authenticated Request
  postAuthData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    var userToken = await _getToken();
    var authHeader = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + userToken
    };
    return await http.post(fullUrl,
        body: jsonEncode(data), headers: authHeader);
  }

  // Post Authenticated Request
  putAuthData(data, apiUrl) async {
    var fullUrl = _url + apiUrl;
    var userToken = await _getToken();
    var authHeader = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + userToken
    };
    return await http.put(fullUrl,
        body: jsonEncode(data), headers: authHeader);
  }

  // Retrieve Authentication Data
  getAuthData(apiUrl) async {
    var fullUrl = _url + apiUrl;
    var userToken = await _getToken();
    var authHeader = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ' + userToken
    };
    return await http.get(fullUrl, headers: authHeader);
  }

  // Set Headers
  _setHeaders() =>
      {'Content-type': 'application/json', 'Accept': 'application/json'};

  // Get authentication tokken
  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var tokenJson = localStorage.getString('token');
    var token = json.decode(tokenJson);
    return token;
  }
}
