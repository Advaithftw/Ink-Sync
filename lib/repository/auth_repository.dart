import 'package:google_sign_in/google_sign_in.dart';
import'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_sync/models/user_model.dart';
 
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(googleSignIn: GoogleSignIn(),),
);
class AuthRepository {
  final GoogleSignIn _googleSignIn;
  AuthRepository({
    required GoogleSignIn googleSignIn,
}) : _googleSignIn = googleSignIn;
  void signInWithGoogle() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user!=null)
      {
        final userAcc = UserModel(
          email: user.email, 
          name: user.displayName!, 
          profilePic: user.photoUrl!, 
          uid: ' ', 
          token: '');
      }
    } catch (e) {
      print(e);
    }
  }

  
}