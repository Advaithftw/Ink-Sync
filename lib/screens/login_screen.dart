import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_sync/repository/auth_repository.dart'; 
import 'package:ink_sync/models/user_model.dart';
import 'package:ink_sync/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart'; // Ensure UserModel is imported

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  Future<void> signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel = await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      
      
      navigator.replace('/');
        
      
    }
    else 
    {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorModel.error!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () => signInWithGoogle(ref, context),
          icon: Image.asset('assets/images/glogo.png',height: 20),
          label: const Text(
            'Sign up with Google',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),


        ),
      ),
    );
  }
}
