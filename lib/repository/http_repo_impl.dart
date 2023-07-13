import 'package:http/http.dart' as http;

import 'http_repo.dart';

class HttpRepoImpl extends HttpRepo {
  @override
  Future delete(String uri) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future get(String uri) async {
    try {
      var url = Uri.parse(baseUrl + uri);
      http.Response response = await http.get(url);
      print('get call for $uri');
      print('get response body : ${response.body}');
      if (response.statusCode == 200) {
        print('get success for $uri');
        return response.body;
      } else {
        print('get galat code : ${response.statusCode}');
      }
    } catch (e) {
      print('get error : $e');
      return;
    }
  }

  @override
  Future post(String uri, object) async {
    try {
      if (object == null) {
        return;
      }
      var url = Uri.parse(baseUrl + uri);
      var payload;
      try {
        payload = object.toJson();
      } catch (e) {
        payload = object;
      }
      print('maine ye post krne bola : $payload');
      http.Response response = await http.post(url, body: payload, headers: {
        'Content-type': 'application/json',
      });
      print('post call for $uri');
      print('post response body : ${response.body}');
      if (response.statusCode == 200) {
        print('post success for $uri');
        return response.body;
      } else {
        print('post galat code : ${response.statusCode}');
      }
    } catch (e) {
      print('post error : $e');
      return 'error';
    }
  }

  @override
  Future put(String uri, object) async {
    try {
      var url = Uri.parse(baseUrl + uri);
      http.Response response =
          await http.put(url, body: object.toJson(), headers: {
        'Content-type': 'application/json',
      });
      print('put call for $uri');
      print('put response body : ${response.body}');
      if (response.statusCode == 200) {
        print('put success for $uri');
        return;
      } else {
        print('put galat code : ${response.statusCode}');
      }
    } catch (e) {
      print('put error : $e');
      return;
    }
  }
}
