import 'package:firebase_auth/firebase_auth.dart' as fauth;
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:money_management/service/exception/auth_exception.dart';
import 'package:money_management/service/storage_service_sql.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../firebase_options.dart';

class LoginService {
  static final LoginService _shared = LoginService._sharedInstance();
  LoginService._sharedInstance();

  factory LoginService() => _shared;

  GoogleSignInAccount? googleUser;
  Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  fauth.User? get currentUser {
    return fauth.FirebaseAuth.instance.currentUser;
  }

  Future<GoogleSignInAccount?> get currentAccount async {
    GoogleSignIn googleSignIn =
        GoogleSignIn(scopes: <String>[DriveApi.driveAppdataScope]);

    await googleSignIn.signInSilently();
    // Check if a user is currently signed in
    if (googleSignIn.currentUser != null) {
      // Get the current signed-in user
      GoogleSignInAccount? currentAccount = googleSignIn.currentUser;
      return currentAccount;
    }

    return null;
  }

  Future<fauth.User> googleLogIn() async {
    try {
      // Trigger the authentication flow
      googleUser =
          await GoogleSignIn(scopes: <String>[DriveApi.driveAppdataScope])
              .signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = fauth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      await fauth.FirebaseAuth.instance.signInWithCredential(credential);
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLoggedInAuthException();
      }
    } on fauth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }

  Future<void> logOut() async {
    final docsPath = await getApplicationDocumentsDirectory();
    final dbPath = join(docsPath.path, dbName);
    await StorageService().close();
    await deleteDatabase(dbPath);
    final user = currentUser;
    if (user != null) {
      GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.disconnect();
      await fauth.FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
  }
}
