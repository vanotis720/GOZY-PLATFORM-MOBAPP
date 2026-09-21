import 'dart:async';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:gozy/constant.dart';

final GoogleSignIn signIn = GoogleSignIn.instance;
GoogleSignInAccount? loginAccount;

class GoogleSigninSetup {
  static void init() {
    String client = Platform.isAndroid ? ANDROID_FIREBASE_CLIENT_ID : IOS_FIREBASE_CLIENT_ID;
    unawaited(signIn.initialize(serverClientId: client).then((_) {
      signIn.authenticationEvents.listen(_handleAuthenticationEvent).onError((e) {
        String errorMessage = e is GoogleSignInException
            ? 'GoogleSignInException ${e.code}: ${e.description}'
            : 'Unknown error: $e';
        print("google signin error: $errorMessage");
      });
    }),
    );
  }

  static Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => loginAccount = event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };
    final GoogleSignInClientAuthorization? authorization =
        await user?.authorizationClient.authorizationForScopes(<String>[
      'email',
      'profile',
    ]);

    print("googel signin user: $user --- $authorization");
  }

  static Future<GoogleSignInAccount?> signin() async {
    print(
        "GoogleSignInAccount: support ${signIn.supportsAuthenticate()} --- ${signIn.authorizationRequiresUserInteraction()}");
    if (signIn.supportsAuthenticate()) {
      if (Platform.isAndroid) {
        loginAccount = await signIn.attemptLightweightAuthentication();
      } else {
        loginAccount = await signIn.authenticate();
      }

      print("GoogleSignInAccount: $loginAccount");
      signIn.signOut().then((value) {
        signIn.disconnect();
      });
    } else {
      print(" google sign in not supported");
    }
    return loginAccount;
  }
}