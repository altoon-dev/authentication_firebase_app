import 'package:firebase_app/auth/auth_error.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AppState{
  final bool isLoading;
  final AuthError? authError;

  const AppState({
      required this.isLoading,
      required this.authError
  });
}

@immutable
class AppStateLoggedIn extends AppState{
  final User user;
  final Iterable<Reference> images;
  const AppStateLoggedIn({
    required super.isLoading,
    required super.authError,
    required this.user,
    required this.images,
  });


  @override
  bool operator == (other){
    final otherClass = other;
    if(otherClass is AppStateLoggedIn){
      return isLoading == otherClass.isLoading &&
    user.uid == otherClass.user.uid &&
    images.length == otherClass.images.length;
    }else {
      return false;
    }
  }

  @override
  int get hashCode => Object.hash(user.uid, images);

}
