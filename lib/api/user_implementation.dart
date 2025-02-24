import 'dart:async';
import 'dart:developer';
import 'dart:ffi';

import 'package:vikunja_app/api/client.dart';
import 'package:vikunja_app/api/service.dart';
import 'package:vikunja_app/models/user.dart';
import 'package:vikunja_app/service/services.dart';

class UserAPIService extends APIService implements UserService {
  UserAPIService(Client client) : super(client);

  @override
  Future<UserTokenPair> login(String username, password, {bool rememberMe = false, String? totp}) async {
    var token = await client.post('/login', body: {
      'long_token': rememberMe,
      'password': password,
      'totp_passcode': totp,
      'username': username,
    }).then((response) => response.body['token']);
    client.configure(token: token);
    return UserAPIService(client)
        .getCurrentUser()
        .then((user) => UserTokenPair(user, token));
  }

  @override
  Future<UserTokenPair> register(String username, email, password) async {
    var newUser = await client.post('/register', body: {
      'username': username,
      'email': email,
      'password': password
    }).then((resp) => resp.body['username']);
    return login(newUser, password);
  }

  @override
  Future<User> getCurrentUser() {
    return client.get('/user').then((map) => User.fromJson(map.body));
  }
}
