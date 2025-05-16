import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink_sync/models/error_model.dart';
import 'package:ink_sync/repository/auth_repository.dart';
import 'package:ink_sync/router.dart';
import 'package:ink_sync/screens/home_screen.dart';
import 'package:ink_sync/screens/login_screen.dart';
import 'package:routemaster/routemaster.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  ErrorModel? errorModel; 
  @override

  void initState() {
    super.initState();
    getUserData();
  }
  void getUserData() async {
    errorModel = await ref.read(authRepositoryProvider).getUserData();
    if (errorModel != null && errorModel!.data != null) {
      ref.read(userProvider.notifier).update((state) => errorModel!.data);
    }
  }
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return MaterialApp.router(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerDelegate: RoutemasterDelegate(routesBuilder: (context) {
        final user = ref.watch(userProvider);
        if(user!=null && user.token.isNotEmpty) {
          return loggedInRoute;
        }
        return loggedOutRoute;
      }),
      routeInformationParser: 
          const RoutemasterParser(), // Use Uri for route information
      
    );
  }
}
