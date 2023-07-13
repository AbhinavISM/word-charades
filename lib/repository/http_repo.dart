import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'http_repo_impl.dart';

String baseUrl = 'http://localhost:3000';
final httpRepoProvider = Provider((ref) => HttpRepoImpl());

abstract class HttpRepo {
  Future post(String uri, dynamic object);
  Future put(String uri, dynamic object);
  Future get(String uri);
  Future delete(String uri);
}
