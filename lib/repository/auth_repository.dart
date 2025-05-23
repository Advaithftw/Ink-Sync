import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart'; 
import 'package:ink_sync/constants.dart';
import 'package:ink_sync/models/error_model.dart';
import 'package:ink_sync/models/user_model.dart';
import 'package:ink_sync/repository/local_storage_repository.dart';

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(googleSignIn: GoogleSignIn(), client: Client(), localStorageRepository: LocalStorageRepository()),
);

final userProvider = StateProvider<UserModel?>((ref) => null);
class AuthRepository {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageRepository _localStorageRepository;
  AuthRepository({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageRepository localStorageRepository,
}) : _googleSignIn = googleSignIn,
      _client = client,
      _localStorageRepository = localStorageRepository;
  Future<ErrorModel> signInWithGoogle() async {
  ErrorModel error = ErrorModel(error: 'Something went wrong', data: null);
  try {
    final user = await _googleSignIn.signIn();

    if (user == null) {
      print(' User cancelled Google sign-in.');
      return ErrorModel(error: 'User cancelled sign-in', data: null);
    }

    final userAcc = UserModel(
      email: user.email,
      name: user.displayName ?? 'No Name',
      profilePic: user.photoUrl ?? '',
      uid: '',
      token: '',
    );

    print('Sending signup request with: ${userAcc.toJson()}');

    var res = await _client.post(
      Uri.parse('$host/api/signup'),
      body: userAcc.toJson(), 
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
    );

    print('Response: ${res.statusCode} => ${res.body}');

    switch (res.statusCode) {
      case 200:
        final newUser = userAcc.copyWith(
          uid: jsonDecode(res.body)['user']['_id'],
          token: jsonDecode(res.body)['token'],
        );
        error = ErrorModel(error: null, data: newUser);
        print('User signed in successfully: ${newUser.toJson()}');
        _localStorageRepository.setToken(newUser.token);
        break;

      default:
        error = ErrorModel(
          error: 'HTTP ${res.statusCode}: ${res.body}',
          data: null,
        );
        print('Error response from server: ${res.body}');
    }
  } catch (e) {
    print('Exception during sign-in: $e');
    error = ErrorModel(error: e.toString(), data: null);
  }

  return error;
}

Future<ErrorModel> getUserData() async {
  ErrorModel error = ErrorModel(error: 'Something went wrong', data: null);
  try {
    final token = await _localStorageRepository.getToken();

    if(token!=null)
    {
      var res = await _client.get(
        Uri.parse('$host/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'x-auth-token': token,
        },
      );

      print('Response: ${res.statusCode} => ${res.body}');

      switch (res.statusCode) {
      case 200:
        final newUser = UserModel.fromJson(jsonEncode(jsonDecode(res.body)['user'])).copyWith(token: token);
        error = ErrorModel(error: null, data: newUser);
        print('User signed in successfully: ${newUser.toJson()}');
        _localStorageRepository.setToken(newUser.token);
        break;

      default:
        error = ErrorModel(
          error: 'HTTP ${res.statusCode}: ${res.body}',
          data: null,
        );
        print('Error response from server: ${res.body}');
    }
    }
    

    
  } catch (e) {
    print('Exception during sign-in: $e');
    error = ErrorModel(error: e.toString(), data: null);
  }

  return error;
}

void signOut() async {
  await _googleSignIn.signOut();
 _localStorageRepository.setToken('');
  print('User signed out successfully');



}
}