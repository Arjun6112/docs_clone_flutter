import 'package:docs_clone_flutter/repository/auth_repository.dart';
import 'package:docs_clone_flutter/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final nNavigator = Routemaster.of(context);
    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      nNavigator.push('/');
    } else {
      sMessenger.showSnackBar(SnackBar(content: Text(errorModel.error!)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 100),
            child: Text("Live Document Editor",
                style: GoogleFonts.poppins(
                    color: Colors.deepPurple[400],
                    fontWeight: FontWeight.bold,
                    fontSize: 34)),
          ),
          Center(
            child: ElevatedButton.icon(
                onPressed: () {
                  signInWithGoogle(ref, context);
                },
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/g-logo-2.png',
                    height: 35,
                  ),
                ),
                label: Text(
                  'Sign in with Google',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500, fontSize: 27),
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Made by Arjun 💜",
                    style: GoogleFonts.poppins(
                        color: Colors.deepPurple[200],
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
